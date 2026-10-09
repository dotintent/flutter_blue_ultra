package com.lib.flutter_blue_ultra_example.wear.design

import androidx.compose.runtime.Composable
import androidx.wear.compose.material.Colors
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Typography

/** Dark theme only. */
@Composable
fun WatchTheme(content: @Composable () -> Unit) {
    val c = DesignTokens.Colors
    val colors = Colors(
        primary = c.accent,
        primaryVariant = c.accent,
        secondary = c.successDark,
        secondaryVariant = c.successDark,
        background = c.bgDark,
        surface = c.surfaceAltDark,
        error = c.accent,
        onPrimary = c.textDark,
        onSecondary = c.bgDark,
        onBackground = c.textDark,
        onSurface = c.textDark,
        onSurfaceVariant = c.textDimDark,
        onError = c.textDark,
    )
    val f = DesignTokens.Fonts
    val typography = Typography(
        defaultFontFamily = f.body,
        display1 = f.display, display2 = f.display, display3 = f.display,
        title1 = f.titleLarge, title2 = f.titleLarge, title3 = f.titleSmall,
        body1 = f.bodyLarge, body2 = f.bodySmall,
        button = f.button,
        caption1 = f.bodySmall, caption2 = f.caption, caption3 = f.caption,
    )
    MaterialTheme(colors = colors, typography = typography, content = content)
}
