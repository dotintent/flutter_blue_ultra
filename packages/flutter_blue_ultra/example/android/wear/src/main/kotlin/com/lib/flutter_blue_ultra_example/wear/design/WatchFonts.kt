package com.lib.flutter_blue_ultra_example.wear.design

import androidx.compose.ui.text.font.DeviceFontFamilyName
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.googlefonts.Font as GoogleFontEntry
import androidx.compose.ui.text.googlefonts.GoogleFont
import com.lib.flutter_blue_ultra_example.wear.R

/**
 * Downloadable Google Fonts. Each family lists the web font first and a system family as fallback, which
 * Compose uses while the font loads or when the provider is unavailable (no font files ship in the APK).
 */
internal object WatchFonts {
    private val provider = GoogleFont.Provider(
        providerAuthority = "com.google.android.gms.fonts",
        providerPackage = "com.google.android.gms",
        certificates = R.array.com_google_android_gms_fonts_certs,
    )

    private fun family(name: String, fallback: String, weights: List<FontWeight>): FontFamily =
        FontFamily(
            weights.flatMap { weight ->
                listOf(
                    GoogleFontEntry(googleFont = GoogleFont(name), fontProvider = provider, weight = weight),
                    Font(DeviceFontFamilyName(fallback), weight),
                )
            },
        )

    val crimsonPro = family("Crimson Pro", "serif", listOf(FontWeight.Normal, FontWeight.SemiBold))
    val inter = family("Inter", "sans-serif", listOf(FontWeight.Normal, FontWeight.Medium))
    val jetBrainsMono = family("JetBrains Mono", "monospace", listOf(FontWeight.Normal))
}
