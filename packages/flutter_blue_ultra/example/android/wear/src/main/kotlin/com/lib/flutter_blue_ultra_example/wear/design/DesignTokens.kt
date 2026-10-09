package com.lib.flutter_blue_ultra_example.wear.design

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/** Generated from the phone app's detected theme. Style mood: match-app. */
object DesignTokens {
    object Colors {
        val accent = Color(0xFFFF3B5C)
        val accentSoftDark = Color(0xFFFF3B5C)
        val accentSoftLight = Color(0xFFFF3B5C)
        val bgDark = Color(0xFF0A0A0A)
        val surfaceDark = Color(0xFF141414)
        val surfaceAltDark = Color(0xFF1C1C1C)
        val surfaceHiDark = Color(0xFF262626)
        val borderDark = Color(0xFFFFFFFF)
        val borderHiDark = Color(0xFFFFFFFF)
        val textDark = Color(0xFFFFFFFF)
        val textDimDark = Color(0xFF9A9A9A)
        val textFaintDark = Color(0xFF5A5A5A)
        val successDark = Color(0xFF7CE0A8)
        val warnDark = Color(0xFFF5C66F)
        val chipBgDark = Color(0xFFFFFFFF)
        val bgLight = Color(0xFFE8E8E8)
        val surfaceAltLight = Color(0xFFF1F1F1)
        val surfaceHiLight = Color(0xFFDCDCDC)
        val borderLight = Color(0xFF000000)
        val borderHiLight = Color(0xFF000000)
        val textDimLight = Color(0xFF6A6A6A)
        val successLight = Color(0xFF1CA86A)
        val warnLight = Color(0xFFC8842A)
        val chipBgLight = Color(0xFF000000)
        val background = Color(0xFF000000)
        val foreground = Color(0xFFFFFFFF)
    }

    /** Font families (Google Fonts via Play services, system fallback) and the minimal Wear type scale. */
    object Fonts {
        val title: FontFamily = WatchFonts.crimsonPro
        val body: FontFamily = WatchFonts.inter
        val mono: FontFamily = WatchFonts.jetBrainsMono

        val display = TextStyle(fontFamily = title, fontSize = 22.sp, fontWeight = FontWeight.SemiBold)
        val titleLarge = TextStyle(fontFamily = title, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
        val titleSmall = TextStyle(fontFamily = title, fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
        val bodyLarge = TextStyle(fontFamily = body, fontSize = 14.sp)
        val bodySmall = TextStyle(fontFamily = body, fontSize = 12.sp)
        val button = TextStyle(fontFamily = body, fontSize = 14.sp, fontWeight = FontWeight.Medium)
        val caption = TextStyle(fontFamily = body, fontSize = 11.sp)
        val monoSmall = TextStyle(fontFamily = mono, fontSize = 10.sp)
    }

    object Dimens {
        val dot = 8.dp
        val iconSmall = 16.dp
        val iconLarge = 32.dp
        val chipRadius = 6.dp
        val gap = 4.dp
    }
}
