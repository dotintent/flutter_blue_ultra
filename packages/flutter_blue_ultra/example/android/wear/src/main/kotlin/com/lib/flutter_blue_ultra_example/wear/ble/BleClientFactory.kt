package com.lib.flutter_blue_ultra_example.wear.ble

import android.content.Context
import android.os.Build
import com.lib.flutter_blue_ultra_example.wear.BuildConfig

object BleClientFactory {
    /** Mock when forced by the USE_MOCK_BLE BuildConfig field or when running on an emulator (no radio). */
    val defaultUseMock: Boolean = BuildConfig.USE_MOCK_BLE || isEmulator()

    fun create(context: Context, useMock: Boolean): BleClient =
        if (useMock) MockBleClient() else AndroidBleClient(context.applicationContext)

    private fun isEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT.orEmpty()
        val product = Build.PRODUCT.orEmpty()
        val hardware = Build.HARDWARE.orEmpty()
        val emulatorHardware = hardware == "goldfish" || hardware == "ranchu"
        val emulatorImage = fingerprint.contains("emulator") || fingerprint.startsWith("generic") ||
            product.contains("sdk") || product.contains("emulator")
        // Require hardware plus an image signal so a real watch never matches on one loose string.
        return emulatorHardware && emulatorImage
    }
}
