package com.lib.flutter_blue_ultra_example.wear.ble

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.cancel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.emitAll
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import java.util.ArrayDeque
import java.util.Collections
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicReference

/**
 * BluetoothLeScanner + BluetoothGatt, exposed through coroutines and Flow.
 * The caller must hold the runtime permissions (see BlePermissions) before scanning or connecting.
 *
 * Threading: GATT callbacks arrive on a Binder thread, so every value they share with coroutines is either
 * volatile or an AtomicReference, and each continuation is completed exactly once (getAndSet(null)).
 * Ordering: disconnect() is always followed by close() only after the stack reports STATE_DISCONNECTED
 * (or a short fallback timeout), because closing right after disconnect() can drop the disconnect.
 */
@SuppressLint("MissingPermission")
class AndroidBleClient(private val context: Context) : BleClient {

    private val adapter: BluetoothAdapter? =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val mainHandler = Handler(Looper.getMainLooper())

    private val _state = MutableStateFlow<BleConnectionState>(BleConnectionState.Disconnected)
    override val connectionState: StateFlow<BleConnectionState> = _state.asStateFlow()

    private val _services = MutableStateFlow<List<BleService>>(emptyList())
    override val services: StateFlow<List<BleService>> = _services.asStateFlow()

    @Volatile private var gatt: BluetoothGatt? = null
    private val discoverResult = AtomicReference<CompletableDeferred<Unit>?>(null)
    private val connectResult = AtomicReference<CompletableDeferred<Unit>?>(null)
    @Volatile private var userDisconnected = false
    @Volatile private var reconnectJob: Job? = null
    // Gatt objects that were disconnected but not closed yet; closeOnce() is idempotent.
    private val closing: MutableSet<BluetoothGatt> = Collections.newSetFromMap(ConcurrentHashMap())

    override fun scan(): Flow<BleDevice> = callbackFlow {
        val bluetooth = adapter
        if (bluetooth == null) {
            close(BleException("Bluetooth is not available on this watch", BleError.BluetoothOff))
            return@callbackFlow
        }
        if (!bluetooth.isEnabled) {
            close(BleException("Bluetooth is off", BleError.BluetoothOff))
            return@callbackFlow
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S && !isLocationEnabled()) {
            close(BleException("Location is off; this Wear OS version needs it for Bluetooth scanning", BleError.LocationOff))
            return@callbackFlow
        }
        val scanner = bluetooth.bluetoothLeScanner
        if (scanner == null) {
            close(BleException("Bluetooth scanner unavailable; toggle Bluetooth and retry", BleError.ScanFailed))
            return@callbackFlow
        }
        throttleCheck()?.let { waitSeconds ->
            close(BleException("Scanning too often; wait ${waitSeconds}s and retry", BleError.ScanThrottled))
            return@callbackFlow
        }
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                val name = result.scanRecord?.deviceName ?: runCatching { result.device.name }.getOrNull()
                val manufacturers = result.scanRecord?.manufacturerSpecificData
                val manufacturerId = if (manufacturers != null && manufacturers.size() > 0) manufacturers.keyAt(0) else null
                trySend(BleDevice(result.device.address, name, result.rssi, manufacturerId))
            }

            override fun onScanFailed(errorCode: Int) {
                close(scanError(errorCode))
            }
        }
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setReportDelay(0)
            .build()
        try {
            scanner.startScan(null, settings, callback)
        } catch (e: SecurityException) {
            close(BleException("Bluetooth permission was denied", BleError.PermissionDenied))
            return@callbackFlow
        } catch (e: IllegalStateException) {
            close(BleException("Bluetooth turned off while starting the scan", BleError.BluetoothOff))
            return@callbackFlow
        } catch (e: RuntimeException) {
            close(BleException("Could not start scanning (${e.message})", BleError.ScanFailed))
            return@callbackFlow
        }
        awaitClose { runCatching { scanner.stopScan(callback) } }
    }

    private fun scanError(code: Int): BleException = when (code) {
        ScanCallback.SCAN_FAILED_ALREADY_STARTED -> BleException("A scan is already running", BleError.ScanFailed)
        ScanCallback.SCAN_FAILED_APPLICATION_REGISTRATION_FAILED ->
            BleException("Bluetooth could not register the scan; toggle Bluetooth and retry", BleError.ScanFailed)
        ScanCallback.SCAN_FAILED_INTERNAL_ERROR -> BleException("Bluetooth had an internal error; retry", BleError.ScanFailed)
        ScanCallback.SCAN_FAILED_FEATURE_UNSUPPORTED -> BleException("This watch does not support BLE scanning", BleError.ScanFailed)
        ScanCallback.SCAN_FAILED_OUT_OF_HARDWARE_RESOURCES -> BleException("Bluetooth is busy; retry in a moment", BleError.ScanFailed)
        6 /* SCAN_FAILED_SCANNING_TOO_FREQUENTLY */ -> BleException("Scanning too often; wait 30s and retry", BleError.ScanThrottled)
        else -> BleException("Scan failed (error $code)", BleError.ScanFailed)
    }

    private fun isLocationEnabled(): Boolean {
        val manager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return true
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) manager.isLocationEnabled
        else runCatching { manager.isProviderEnabled(LocationManager.GPS_PROVIDER) || manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER) }
            .getOrDefault(true)
    }

    override suspend fun connect(deviceId: String) {
        reconnectJob?.cancel()
        releaseGatt()
        userDisconnected = false
        _state.value = BleConnectionState.Connecting
        try {
            connectOnce(deviceId)
        } catch (e: CancellationException) {
            // Cancelled while connecting (the user left or pressed Disconnect): tear down instead of hanging.
            releaseGatt()
            _state.value = BleConnectionState.Disconnected
            throw e
        } catch (e: BleException) {
            _state.value = if (userDisconnected) BleConnectionState.Disconnected else BleConnectionState.Failed(e.message ?: "Connection failed")
            throw e
        }
    }

    private suspend fun connectOnce(deviceId: String) {
        val bluetooth = adapter?.takeIf { it.isEnabled } ?: throw BleException("Bluetooth is off", BleError.BluetoothOff)
        val device: BluetoothDevice = try {
            bluetooth.getRemoteDevice(deviceId)
        } catch (e: IllegalArgumentException) {
            throw BleException("Invalid device address")
        }
        val result = CompletableDeferred<Unit>()
        connectResult.set(result)
        gatt = try {
            device.connectGatt(context, false, callback, BluetoothDevice.TRANSPORT_LE)
        } catch (e: SecurityException) {
            connectResult.compareAndSet(result, null)
            throw BleException("Bluetooth permission was denied", BleError.PermissionDenied)
        }
        try {
            withTimeout(CONNECT_TIMEOUT_MS) { result.await() }
        } catch (e: TimeoutCancellationException) {
            // GATT 133 and friends never call back; fail instead of staying on "Connecting" forever.
            connectResult.compareAndSet(result, null)
            releaseGatt()
            throw BleException("Connection timed out", BleError.Timeout)
        } finally {
            connectResult.compareAndSet(result, null)
        }
        discoverServices()
    }

    /** Runs after the link is up: Discovering -> Connected, or throws (and releases the gatt) on failure. */
    private suspend fun discoverServices() {
        val g = gatt ?: throw BleException("Disconnected")
        val result = CompletableDeferred<Unit>()
        discoverResult.set(result)
        _services.value = emptyList()
        _state.value = BleConnectionState.Discovering
        try {
            if (!g.discoverServices()) throw BleException("Could not start service discovery")
            withTimeout(DISCOVERY_TIMEOUT_MS) { result.await() }
        } catch (e: TimeoutCancellationException) {
            releaseGatt()
            throw BleException("Service discovery timed out", BleError.Timeout)
        } catch (e: BleException) {
            releaseGatt()
            throw e
        } finally {
            discoverResult.compareAndSet(result, null)
        }
        _state.value = BleConnectionState.Connected
    }


    override fun disconnect() {
        userDisconnected = true
        reconnectJob?.cancel()
        // A connect() that is still waiting must not hang: fail it now.
        connectResult.getAndSet(null)?.completeExceptionally(BleException("Disconnected"))
        discoverResult.getAndSet(null)?.completeExceptionally(BleException("Disconnected"))
        releaseGatt()
        _services.value = emptyList()
        _state.value = BleConnectionState.Disconnected
    }

    override fun close() {
        disconnect()
        // The fallback close for any gatt still waiting for STATE_DISCONNECTED runs on the main handler,
        // so cancelling the scope here cannot strand it.
        scope.cancel()
    }


    /** disconnect() now; close() when the stack confirms (callback) or after a short timeout, whichever is first. */
    private fun releaseGatt() {
        val g = gatt ?: return
        gatt = null
        closing.add(g)
        runCatching { g.disconnect() }
        mainHandler.postDelayed({ closeOnce(g) }, DISCONNECT_CLOSE_TIMEOUT_MS)
    }

    private fun closeOnce(g: BluetoothGatt) {
        if (closing.remove(g)) runCatching { g.close() }
    }


    private fun scheduleReconnect(deviceId: String) {
        reconnectJob = scope.launch {
            for (attempt in 1..MAX_RECONNECT_ATTEMPTS) {
                _state.value = BleConnectionState.Reconnecting(attempt)
                delay(attempt * RECONNECT_BACKOFF_MS)
                if (!isActive || userDisconnected) return@launch
                try {
                    connectOnce(deviceId)
                    return@launch
                } catch (e: CancellationException) {
                    throw e
                } catch (e: BleException) {
                    // Try again until attempts run out.
                }
            }
            if (!userDisconnected) _state.value = BleConnectionState.Failed("Could not reconnect")
        }
    }

    private val callback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(g: BluetoothGatt, status: Int, newState: Int) {
            // Late callback from a gatt that was already released: only close it, never touch current state.
            if (isStale(g)) {
                closeOnce(g)
                return
            }
            if (newState == BluetoothProfile.STATE_CONNECTED && status == BluetoothGatt.GATT_SUCCESS) {
                connectResult.getAndSet(null)?.complete(Unit)
                return
            }
            // Disconnected (or failed): this is the safe moment to close the gatt object.
            val wasConnected = _state.value is BleConnectionState.Connected
            val deviceId = g.device.address
            closing.add(g)
            closeOnce(g)
            if (gatt === g) gatt = null
            val failure = BleException(disconnectMessage(status))
            connectResult.getAndSet(null)?.completeExceptionally(failure)
            discoverResult.getAndSet(null)?.completeExceptionally(failure)
            if (!userDisconnected) _services.value = emptyList()
            when {
                userDisconnected -> _state.value = BleConnectionState.Disconnected
                wasConnected -> scheduleReconnect(deviceId)
                reconnectJob?.isActive == true -> Unit
                else -> _state.value = BleConnectionState.Failed(failure.message ?: "Connection failed")
            }
        }

        override fun onServicesDiscovered(g: BluetoothGatt, status: Int) {
            if (isStale(g)) return
            val pending = discoverResult.getAndSet(null) ?: return
            if (status != BluetoothGatt.GATT_SUCCESS) {
                pending.completeExceptionally(BleException("Service discovery failed (GATT status $status)"))
                return
            }
            _services.value = g.services.map { it.toBleService() }
            pending.complete(Unit)
        }

    }

    private fun isStale(g: BluetoothGatt): Boolean {
        val current = gatt
        return if (current != null) current !== g else closing.contains(g)
    }

    private fun BluetoothGattService.toBleService(): BleService {
        val serviceUuid = BleUuid.short(uuid)
        return BleService(
            serviceUuid,
            characteristics.map { BleCharacteristic(BleUuid.short(it.uuid), serviceUuid, BleProperty.fromMask(it.properties)) },
        )
    }

    private fun disconnectMessage(status: Int): String = when (status) {
        BluetoothGatt.GATT_SUCCESS -> "Disconnected"
        8 -> "Connection lost (timeout)"
        19 -> "Device ended the connection"
        133 -> "Could not connect (GATT 133); retry"
        else -> "Disconnected (GATT status $status)"
    }

    private companion object {
        const val CONNECT_TIMEOUT_MS = 15_000L
        const val DISCOVERY_TIMEOUT_MS = 10_000L
        const val DISCONNECT_CLOSE_TIMEOUT_MS = 2_000L
        const val MAX_RECONNECT_ATTEMPTS = 3
        const val RECONNECT_BACKOFF_MS = 2_000L

        // Android allows 5 scan starts per 30 s per app; more are silently dropped (SCANNING_TOO_FREQUENTLY).
        const val SCAN_WINDOW_MS = 30_000L
        const val SCAN_MAX_STARTS = 5
        private val scanStarts = ArrayDeque<Long>()

        /** Records a scan start; returns the seconds to wait when the 5-per-30s budget is used up, else null. */
        @Synchronized
        fun throttleCheck(): Long? {
            val now = System.currentTimeMillis()
            while (scanStarts.isNotEmpty() && now - scanStarts.first() > SCAN_WINDOW_MS) scanStarts.removeFirst()
            if (scanStarts.size >= SCAN_MAX_STARTS) {
                return ((SCAN_WINDOW_MS - (now - scanStarts.first())) / 1000L) + 1
            }
            scanStarts.addLast(now)
            return null
        }
    }
}
