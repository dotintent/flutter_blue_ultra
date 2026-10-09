package com.lib.flutter_blue_ultra_example.wear.ble

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

data class BleUiState(
    val useMock: Boolean,
    val scanning: Boolean = false,
    /** Sorted by RSSI, strongest first. */
    val devices: List<BleDevice> = emptyList(),
    val selected: BleDevice? = null,
    val connection: BleConnectionState = BleConnectionState.Disconnected,
    val services: List<BleService> = emptyList(),
    val error: String? = null,
    val errorKind: BleError? = null,
)

class BleViewModel(
    private val clientFactory: (useMock: Boolean) -> BleClient,
    defaultUseMock: Boolean,
) : ViewModel() {
    private var client: BleClient = clientFactory(defaultUseMock)
    private val _state = MutableStateFlow(BleUiState(useMock = defaultUseMock))
    val state: StateFlow<BleUiState> = _state.asStateFlow()

    private var scanJob: Job? = null
    private var stateJob: Job? = null
    private var servicesJob: Job? = null
    private var connectJob: Job? = null

    init {
        observeClient()
    }

    private fun observeClient() {
        stateJob?.cancel()
        servicesJob?.cancel()
        val current = client
        stateJob = viewModelScope.launch {
            current.connectionState.collect { connection ->
                _state.update { it.copy(connection = connection) }
                if (connection is BleConnectionState.Failed) {
                    _state.update { it.copy(error = connection.message) }
                }
            }
        }
        servicesJob = viewModelScope.launch {
            current.services.collect { services -> _state.update { it.copy(services = services) } }
        }
    }

    fun setMock(useMock: Boolean) {
        if (useMock == _state.value.useMock) return
        stopScan()
        connectJob?.cancel()
        connectJob = null
        client.close()
        client = clientFactory(useMock)
        _state.value = BleUiState(useMock = useMock)
        observeClient()
    }

    fun startScan() {
        if (scanJob?.isActive == true) return
        _state.update { it.copy(scanning = true, devices = emptyList(), error = null, errorKind = null) }
        scanJob = viewModelScope.launch {
            // The scan stops by itself after SCAN_WINDOW_MS (Android throttles repeated scan starts).
            withTimeoutOrNull(SCAN_WINDOW_MS) {
                client.scan()
                    .catch { e ->
                        if (e is CancellationException) throw e
                        val kind = (e as? BleException)?.kind ?: BleError.ScanFailed
                        _state.update { it.copy(error = e.message ?: "Scan failed", errorKind = kind) }
                    }
                    .collect { device -> _state.update { it.copy(devices = it.devices.withDevice(device)) } }
            }
            _state.update { it.copy(scanning = false) }
        }
    }

    fun stopScan() {
        scanJob?.cancel()
        scanJob = null
        _state.update { it.copy(scanning = false) }
    }

    /** Selects [device], connects and discovers its services. Safe to call again as "Retry". */
    fun connect(device: BleDevice) {
        stopScan()
        connectJob?.cancel()
        resetConnection()
        _state.update { it.copy(selected = device) }
        connectJob = viewModelScope.launch {
            try {
                client.connect(device.id)
            } catch (e: CancellationException) {
                throw e
            } catch (e: BleException) {
                _state.update { it.copy(error = e.message, errorKind = e.kind) }
            }
        }
    }

    /** Drops the link but keeps the device selected, so the detail screen can offer Connect again. */
    fun disconnect() {
        // Cancel a connect that is still waiting first, so the coroutine ends instead of hanging.
        connectJob?.cancel()
        connectJob = null
        client.disconnect()
        resetConnection()
    }

    /** Leaving the device screen: close the GATT connection and forget the selection. */
    fun closeDevice() {
        disconnect()
        _state.update { it.copy(selected = null) }
    }

    private fun resetConnection() {
        _state.update {
            it.copy(connection = BleConnectionState.Disconnected, services = emptyList(), error = null, errorKind = null)
        }
    }

    fun clearError() {
        _state.update { it.copy(error = null, errorKind = null) }
    }

    override fun onCleared() {
        client.close()
    }

    companion object {
        const val SCAN_WINDOW_MS = 30_000L

        fun factory(context: Context): ViewModelProvider.Factory {
            val app = context.applicationContext
            return viewModelFactory {
                initializer { BleViewModel({ mock -> BleClientFactory.create(app, mock) }, BleClientFactory.defaultUseMock) }
            }
        }
    }
}

/** Replaces any entry with the same id, then sorts strongest signal first (ties by id for a stable order). */
internal fun List<BleDevice>.withDevice(device: BleDevice): List<BleDevice> =
    (filterNot { it.id == device.id } + device).sortedWith(compareByDescending<BleDevice> { it.rssi }.thenBy { it.id })
