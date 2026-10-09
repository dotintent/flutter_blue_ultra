package com.lib.flutter_blue_ultra_example.wear.ble.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bluetooth
import androidx.compose.material.icons.filled.BluetoothDisabled
import androidx.compose.material.icons.filled.LocationOff
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Stop
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.items
import androidx.wear.compose.foundation.lazy.rememberScalingLazyListState
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.PositionIndicator
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import androidx.wear.compose.material.ToggleChip
import androidx.wear.compose.material.ToggleChipDefaults
import androidx.wear.compose.material.Vignette
import androidx.wear.compose.material.VignettePosition
import com.lib.flutter_blue_ultra_example.wear.BuildConfig
import com.lib.flutter_blue_ultra_example.wear.ble.BleDevice
import com.lib.flutter_blue_ultra_example.wear.ble.BleViewModel
import com.lib.flutter_blue_ultra_example.wear.ble.rememberBlePermissionState
import com.lib.flutter_blue_ultra_example.wear.ble.rememberBleRadioState
import com.lib.flutter_blue_ultra_example.wear.design.DesignTokens

/** Entry screen: permission and Bluetooth gating, then the scan list. */
@Composable
fun BleDeviceListScreen(viewModel: BleViewModel, onDeviceSelected: (BleDevice) -> Unit) {
    val state by viewModel.state.collectAsState()
    val permissions = rememberBlePermissionState()
    val radio = rememberBleRadioState()
    val lifecycleOwner = LocalLifecycleOwner.current
    var resumes by remember { mutableIntStateOf(0) }
    val listState = rememberScalingLazyListState()

    // Never scan while this screen is inactive (ON_PAUSE: background or another screen on top), and
    // re-evaluate everything on return (ON_RESUME): permissions, Bluetooth and Location may have changed.
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_PAUSE -> viewModel.stopScan()
                Lifecycle.Event.ON_RESUME -> {
                    permissions.refresh()
                    resumes++
                }
                else -> Unit
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    val ready = state.useMock || (permissions.granted && radio.bluetoothOn && radio.locationOn)
    DisposableEffect(ready, state.useMock, resumes) {
        if (ready) viewModel.startScan()
        onDispose { viewModel.stopScan() }
    }

    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = { PositionIndicator(scalingLazyListState = listState) },
    ) {
        ScalingLazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = WatchListPadding,
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(DesignTokens.Dimens.gap, Alignment.CenterVertically),
        ) {
            when {
                ready -> scanContent(state, viewModel, onDeviceSelected)
                !permissions.granted -> item {
                    if (permissions.permanentlyDenied) {
                        StatusMessage(
                            Icons.Filled.Bluetooth, "Permission blocked",
                            "Allow Nearby devices in app settings", "Open Settings", permissions.openSettings,
                        )
                    } else {
                        StatusMessage(
                            Icons.Filled.Bluetooth, "Allow Bluetooth",
                            "Needed to find nearby devices", "Allow", permissions.request,
                        )
                    }
                }
                !radio.bluetoothOn -> item {
                    StatusMessage(
                        Icons.Filled.BluetoothDisabled, "Bluetooth is off",
                        "Turn it on to find devices", "Turn on", radio.enableBluetooth,
                    )
                }
                else -> item {
                    StatusMessage(
                        Icons.Filled.LocationOff, "Location is off",
                        "This Wear OS version needs Location to scan", "Open Settings", radio.openLocationSettings,
                    )
                }
            }
            if (BuildConfig.DEBUG) {
                item {
                    ToggleChip(
                        label = { Text("Mock devices") },
                        checked = state.useMock,
                        onCheckedChange = { viewModel.setMock(it) },
                        modifier = Modifier.fillMaxWidth(),
                        toggleControl = { ToggleChipDefaults.switchIcon(checked = state.useMock) },
                    )
                }
            }
        }
    }
}

private fun androidx.wear.compose.foundation.lazy.ScalingLazyListScope.scanContent(
    state: com.lib.flutter_blue_ultra_example.wear.ble.BleUiState,
    viewModel: BleViewModel,
    onDeviceSelected: (BleDevice) -> Unit,
) {
    item { Text("Nearby", style = DesignTokens.Fonts.titleLarge, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth()) }
    state.error?.let { message -> item { ErrorChip(message, onDismiss = viewModel::clearError) } }
    item {
        Chip(
            label = { Text(if (state.scanning) "Stop" else if (state.devices.isEmpty()) "Scan again" else "Scan") },
            icon = {
                if (state.scanning) ScanRipple() else Icon(
                    Icons.Filled.Refresh, contentDescription = null, modifier = Modifier.size(DesignTokens.Dimens.iconSmall),
                )
            },
            secondaryLabel = if (state.scanning && state.devices.isEmpty()) ({ Text("Searching...") }) else null,
            onClick = { if (state.scanning) viewModel.stopScan() else viewModel.startScan() },
            modifier = Modifier.fillMaxWidth(),
            colors = ChipDefaults.secondaryChipColors(),
        )
    }
    if (state.devices.isEmpty() && !state.scanning && state.error == null) {
        item {
            Text("No devices found", style = DesignTokens.Fonts.bodySmall, color = DesignTokens.Colors.textDimDark, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth())
        }
    }
    items(state.devices.size, key = { state.devices[it].id }) { index ->
        val device = state.devices[index]
        Chip(
            label = { Text(device.displayName(), maxLines = 1) },
            secondaryLabel = { Text(device.shortId(), style = DesignTokens.Fonts.monoSmall, maxLines = 1) },
            icon = { RssiBars(device.rssi) },
            onClick = { onDeviceSelected(device) },
            modifier = Modifier.fillMaxWidth(),
            colors = ChipDefaults.secondaryChipColors(),
        )
    }
}

/** Last four hex digits of the address (or id), e.g. "5E:F1". */
fun BleDevice.shortId(): String = id.takeLast(5)
