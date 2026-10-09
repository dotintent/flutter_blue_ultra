package com.lib.flutter_blue_ultra_example.wear.ble.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.LinkOff
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.rememberScalingLazyListState
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.PositionIndicator
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import androidx.wear.compose.material.Vignette
import androidx.wear.compose.material.VignettePosition
import com.lib.flutter_blue_ultra_example.wear.ble.BleConnectionState
import com.lib.flutter_blue_ultra_example.wear.ble.BleService
import com.lib.flutter_blue_ultra_example.wear.ble.BleViewModel
import com.lib.flutter_blue_ultra_example.wear.ble.displayUuid
import com.lib.flutter_blue_ultra_example.wear.design.DesignTokens

@Composable
fun BleDeviceDetailScreen(viewModel: BleViewModel) {
    val state by viewModel.state.collectAsState()
    val listState = rememberScalingLazyListState()
    var expanded by rememberSaveable { mutableStateOf(emptySet<Int>()) }
    val device = state.selected
    val colors = DesignTokens.Colors

    // Leaving the screen (back swipe) closes the GATT connection.
    DisposableEffect(Unit) { onDispose { viewModel.closeDevice() } }

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
            item {
                Text(
                    device?.displayName() ?: "Device",
                    style = DesignTokens.Fonts.titleLarge,
                    textAlign = TextAlign.Center,
                    maxLines = 2,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
            item {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally), verticalAlignment = Alignment.CenterVertically) {
                    Text(device?.shortId().orEmpty(), style = DesignTokens.Fonts.monoSmall, color = colors.textDimDark)
                    if (device != null) RssiBars(device.rssi)
                }
            }
            item {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterHorizontally), verticalAlignment = Alignment.CenterVertically) {
                    ConnectionDot(state.connection)
                    Text(state.connection.label(), style = DesignTokens.Fonts.bodySmall)
                }
            }
            val failed = state.connection is BleConnectionState.Failed || state.error != null
            if (failed) {
                item {
                    Text(
                        state.error ?: (state.connection as? BleConnectionState.Failed)?.message.orEmpty(),
                        style = DesignTokens.Fonts.bodySmall,
                        color = colors.accent,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }
            item {
                when (state.connection) {
                    BleConnectionState.Disconnected -> ActionChip("Connect", Icons.Filled.Link, primary = true) {
                        device?.let(viewModel::connect)
                    }
                    is BleConnectionState.Failed -> ActionChip("Retry", Icons.Filled.Refresh, primary = true) {
                        device?.let(viewModel::connect)
                    }
                    else -> ActionChip("Disconnect", Icons.Filled.LinkOff, primary = false, onClick = viewModel::disconnect)
                }
            }
            if (state.connection == BleConnectionState.Connected) {
                if (state.services.isEmpty()) {
                    item { Text("No services found", style = DesignTokens.Fonts.bodySmall, color = colors.textDimDark, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth()) }
                } else {
                    item { Text("Services", style = DesignTokens.Fonts.titleSmall, color = colors.textDimDark, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth()) }
                    state.services.forEachIndexed { index, service ->
                        val open = index in expanded
                        item(key = "service-$index") {
                            ServiceChip(service, open) { expanded = if (open) expanded - index else expanded + index }
                        }
                        if (open) {
                            if (service.characteristics.isEmpty()) {
                                item(key = "empty-$index") {
                                    Text("No characteristics", style = DesignTokens.Fonts.bodySmall, color = colors.textDimDark, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth())
                                }
                            }
                            service.characteristics.forEachIndexed { cIndex, characteristic ->
                                item(key = "char-$index-$cIndex") {
                                    Column(
                                        Modifier.fillMaxWidth().padding(horizontal = 8.dp),
                                        verticalArrangement = Arrangement.spacedBy(2.dp),
                                        horizontalAlignment = Alignment.CenterHorizontally,
                                    ) {
                                        Text(
                                            characteristic.name ?: "Characteristic",
                                            style = DesignTokens.Fonts.bodySmall,
                                            maxLines = 1,
                                        )
                                        Text(
                                            characteristic.uuid.displayUuid(),
                                            style = DesignTokens.Fonts.monoSmall,
                                            color = colors.textDimDark,
                                            maxLines = 2,
                                        )
                                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(3.dp, Alignment.CenterHorizontally)) {
                                            characteristic.properties.forEach { PropertyChip(it) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ActionChip(label: String, icon: androidx.compose.ui.graphics.vector.ImageVector, primary: Boolean, onClick: () -> Unit) {
    Chip(
        label = { Text(label) },
        icon = { Icon(icon, contentDescription = null, modifier = Modifier.size(DesignTokens.Dimens.iconSmall)) },
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        colors = if (primary) ChipDefaults.primaryChipColors() else ChipDefaults.secondaryChipColors(),
    )
}

@Composable
private fun ServiceChip(service: BleService, open: Boolean, onToggle: () -> Unit) {
    Chip(
        label = { Text(service.name ?: service.uuid.displayUuid(), maxLines = 2) },
        secondaryLabel = if (service.name != null) ({ Text(service.uuid.displayUuid(), style = DesignTokens.Fonts.monoSmall, maxLines = 1) }) else null,
        icon = {
            Icon(
                if (open) Icons.Filled.ExpandMore else Icons.Filled.ChevronRight,
                contentDescription = if (open) "Collapse" else "Expand",
                modifier = Modifier.size(DesignTokens.Dimens.iconSmall),
            )
        },
        onClick = onToggle,
        modifier = Modifier.fillMaxWidth(),
        colors = ChipDefaults.secondaryChipColors(),
    )
}
