package com.lib.flutter_blue_ultra_example.wear.ble

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.ActivityNotFoundException
import android.content.BroadcastReceiver
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner

/** API 31+ uses BLUETOOTH_SCAN/CONNECT; older watches need (fine and coarse) location for scanning. */
object BlePermissions {
    fun required(): Array<String> =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)
        }

    fun hasAll(context: Context): Boolean =
        required().all { ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED }

    /** True when this watch has its own BLE radio; without one Bluetooth/Location state is irrelevant to the UI. */
    fun radioRequired(context: Context): Boolean =
        context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE) ||
            BluetoothAdapter.getDefaultAdapter() != null
}

/**
 * [permanentlyDenied] is true after a request was refused with "Don't ask again": the dialog will not show
 * again, so the UI offers [openSettings] (this app's system settings page) instead of [request].
 * [refresh] re-reads the grant state (call on ON_RESUME: the user may have changed it in Settings).
 */
class BlePermissionState(
    val granted: Boolean,
    val permanentlyDenied: Boolean,
    val request: () -> Unit,
    val openSettings: () -> Unit,
    val refresh: () -> Unit,
)

private const val PREFS = "ble_permissions"
private const val KEY_ASKED = "asked"

private fun Context.findActivity(): Activity? {
    var c: Context? = this
    while (c is ContextWrapper) {
        if (c is Activity) return c
        c = c.baseContext
    }
    return null
}

@Composable
fun rememberBlePermissionState(): BlePermissionState {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    var granted by remember { mutableStateOf(BlePermissions.hasAll(context)) }
    // "No rationale and still denied" only means "Don't ask again" after we asked at least once (persisted).
    fun blocked(): Boolean {
        val activity = context.findActivity() ?: return false
        val asked = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY_ASKED, false)
        return asked && BlePermissions.required().any {
            ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED &&
                !activity.shouldShowRequestPermissionRationale(it)
        }
    }
    var permanentlyDenied by remember { mutableStateOf(!granted && blocked()) }
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY_ASKED, true).apply()
        granted = BlePermissions.hasAll(context)
        permanentlyDenied = !granted && blocked()
    }
    val refresh = {
        granted = BlePermissions.hasAll(context)
        permanentlyDenied = !granted && blocked()
    }
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event -> if (event == Lifecycle.Event.ON_RESUME) refresh() }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }
    return BlePermissionState(
        granted = granted,
        permanentlyDenied = permanentlyDenied,
        request = { launcher.launch(BlePermissions.required()) },
        openSettings = {
            context.startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", context.packageName, null))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        },
        refresh = refresh,
    )
}

/**
 * Live Bluetooth (and, before API 31, Location) on/off state.
 * [enableBluetooth] asks the system to turn Bluetooth on (falls back to Bluetooth settings).
 */
class BleRadioState(
    val bluetoothOn: Boolean,
    val locationOn: Boolean,
    val enableBluetooth: () -> Unit = {},
    val openLocationSettings: () -> Unit = {},
)

@Composable
fun rememberBleRadioState(): BleRadioState {
    val context = LocalContext.current
    val required = BlePermissions.radioRequired(context)
    val enableLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { }
    var bluetoothOn by remember { mutableStateOf(readBluetoothOn()) }
    var locationOn by remember { mutableStateOf(readLocationOn(context)) }
    // The receiver is registered and unregistered in matching pairs by the effect's lifetime.
    DisposableEffect(required) {
        if (!required) return@DisposableEffect onDispose { }
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(c: Context, intent: Intent) {
                bluetoothOn = readBluetoothOn()
                locationOn = readLocationOn(c)
            }
        }
        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(LocationManager.MODE_CHANGED_ACTION)
        }
        ContextCompat.registerReceiver(context, receiver, filter, ContextCompat.RECEIVER_EXPORTED)
        bluetoothOn = readBluetoothOn()
        locationOn = readLocationOn(context)
        onDispose { runCatching { context.unregisterReceiver(receiver) } }
    }
    if (!required) return BleRadioState(true, true)
    return BleRadioState(
        bluetoothOn = bluetoothOn,
        locationOn = locationOn,
        enableBluetooth = {
            try {
                enableLauncher.launch(Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE))
            } catch (e: ActivityNotFoundException) {
                context.startSettings(Settings.ACTION_BLUETOOTH_SETTINGS)
            }
        },
        openLocationSettings = { context.startSettings(Settings.ACTION_LOCATION_SOURCE_SETTINGS) },
    )
}

private fun Context.startSettings(action: String) {
    runCatching { startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }
}

@Suppress("MissingPermission")
private fun readBluetoothOn(): Boolean = runCatching { BluetoothAdapter.getDefaultAdapter()?.isEnabled == true }.getOrDefault(false)

private fun readLocationOn(context: Context): Boolean {
    // API 31+ scans without location (BLUETOOTH_SCAN neverForLocation), so it never blocks there.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) return true
    val manager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return true
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) manager.isLocationEnabled
    else runCatching { manager.isProviderEnabled(LocationManager.GPS_PROVIDER) || manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER) }
        .getOrDefault(true)
}
