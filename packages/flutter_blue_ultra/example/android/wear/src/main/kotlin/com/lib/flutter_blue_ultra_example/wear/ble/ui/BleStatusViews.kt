package com.lib.flutter_blue_ultra_example.wear.ble.ui

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import com.lib.flutter_blue_ultra_example.wear.ble.BleConnectionState
import com.lib.flutter_blue_ultra_example.wear.ble.BleProperty
import com.lib.flutter_blue_ultra_example.wear.design.DesignTokens

private val tokens = DesignTokens.Colors

fun BleConnectionState.label(): String = when (this) {
    BleConnectionState.Disconnected -> "Not connected"
    BleConnectionState.Connecting -> "Connecting..."
    BleConnectionState.Discovering -> "Discovering services..."
    is BleConnectionState.Reconnecting -> "Reconnecting (attempt $attempt)..."
    BleConnectionState.Connected -> "Connected"
    is BleConnectionState.Failed -> "Connection failed"
}

/** Number of lit bars (1..5) for an RSSI in dBm; matches the phone app's RSSIBars. */
fun rssiBars(rssi: Int): Int = (((rssi + 100) / 10.0).let { Math.round(it).toInt() }).coerceIn(1, 5)

@Composable
fun RssiBars(rssi: Int, modifier: Modifier = Modifier) {
    val lit = rssiBars(rssi)
    Row(modifier, horizontalArrangement = Arrangement.spacedBy(2.dp), verticalAlignment = Alignment.Bottom) {
        for (i in 0 until 5) {
            Box(
                Modifier
                    .width(3.dp)
                    .height((3 + (i + 1) * 2).dp)
                    .clip(RoundedCornerShape(1.dp))
                    .background(if (i < lit) tokens.textDark else tokens.surfaceHiDark),
            )
        }
    }
}

@Composable
fun ConnectionDot(state: BleConnectionState, modifier: Modifier = Modifier) {
    val color = when (state) {
        BleConnectionState.Connected -> tokens.successDark
        BleConnectionState.Connecting, BleConnectionState.Discovering, is BleConnectionState.Reconnecting -> tokens.warnDark
        is BleConnectionState.Failed -> tokens.accent
        BleConnectionState.Disconnected -> tokens.textFaintDark
    }
    Box(modifier.size(DesignTokens.Dimens.dot).clip(CircleShape).background(color))
}

/** Two expanding rings; shown while scanning. */
@Composable
fun ScanRipple(modifier: Modifier = Modifier, size: androidx.compose.ui.unit.Dp = 24.dp) {
    val transition = rememberInfiniteTransition(label = "ripple")
    val phase by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(1600, easing = LinearEasing), RepeatMode.Restart),
        label = "phase",
    )
    Canvas(modifier.size(size)) {
        val max = this.size.minDimension / 2
        for (offset in floatArrayOf(0f, 0.5f)) {
            val p = (phase + offset) % 1f
            drawCircle(
                color = tokens.accent.copy(alpha = 1f - p),
                radius = max * p,
                center = Offset(this.size.width / 2, this.size.height / 2),
                style = Stroke(width = 1.5.dp.toPx()),
            )
        }
        drawCircle(tokens.accent, radius = max * 0.2f, center = Offset(this.size.width / 2, this.size.height / 2))
    }
}

@Composable
fun PropertyChip(property: BleProperty) {
    Text(
        text = property.label,
        style = DesignTokens.Fonts.monoSmall,
        color = tokens.textDark,
        modifier = Modifier
            .clip(RoundedCornerShape(DesignTokens.Dimens.chipRadius))
            .background(tokens.surfaceHiDark)
            .padding(horizontal = 5.dp, vertical = 1.dp),
    )
}

/** Symmetric padding that keeps content clear of TimeText (top) and the bezel (sides) on round screens. */
val WatchListPadding = androidx.compose.foundation.layout.PaddingValues(
    start = 12.dp, end = 12.dp, top = 40.dp, bottom = 32.dp,
)

/** Centered full-screen notice with an icon and an optional action (permission, Bluetooth off...). */
@Composable
fun StatusMessage(
    icon: ImageVector,
    title: String,
    detail: String,
    actionLabel: String? = null,
    onAction: () -> Unit = {},
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(DesignTokens.Dimens.gap),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Icon(icon, contentDescription = null, tint = tokens.accent, modifier = Modifier.size(DesignTokens.Dimens.iconLarge))
        Text(title, style = DesignTokens.Fonts.titleLarge, textAlign = TextAlign.Center)
        Text(detail, style = DesignTokens.Fonts.bodySmall, color = tokens.textDimDark, textAlign = TextAlign.Center)
        if (actionLabel != null) {
            Chip(
                label = { Text(actionLabel) },
                onClick = onAction,
                modifier = Modifier.fillMaxWidth(),
                colors = ChipDefaults.primaryChipColors(),
            )
        }
    }
}

/** Tap to dismiss. */
@Composable
fun ErrorChip(message: String, onDismiss: () -> Unit) {
    Chip(
        label = { Text(message, color = MaterialTheme.colors.error, maxLines = 3) },
        secondaryLabel = { Text("Tap to dismiss") },
        onClick = onDismiss,
        modifier = Modifier.fillMaxWidth(),
        colors = ChipDefaults.secondaryChipColors(),
    )
}

