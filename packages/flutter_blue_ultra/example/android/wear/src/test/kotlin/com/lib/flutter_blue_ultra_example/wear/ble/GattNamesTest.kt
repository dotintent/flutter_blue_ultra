package com.lib.flutter_blue_ultra_example.wear.ble

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class GattNamesTest {
    @Test
    fun knownServicesResolveFromShortAndFullUuid() {
        assertEquals("Battery Service", GattNames.service("180f"))
        assertEquals("Battery Service", GattNames.service("180F"))
        assertEquals("Heart Rate", GattNames.service("0000180d-0000-1000-8000-00805f9b34fb"))
    }

    @Test
    fun knownCharacteristicsResolve() {
        assertEquals("Battery Level", GattNames.characteristic("2a19"))
        assertEquals("Heart Rate Measurement", GattNames.characteristic("00002A37-0000-1000-8000-00805F9B34FB"))
    }

    @Test
    fun unknownAndCustomUuidsReturnNull() {
        assertNull(GattNames.service("ffff"))
        assertNull(GattNames.characteristic("6e400002-b5a3-f393-e0a9-e50e24dcca9e"))
        assertNull(GattNames.service("0000180f-1234-1000-8000-00805f9b34fb"))
    }

    @Test
    fun propertiesMapFromGattMask() {
        // READ | WRITE_NO_RESPONSE | WRITE | NOTIFY | INDICATE
        val all = BleProperty.fromMask(0x02 or 0x04 or 0x08 or 0x10 or 0x20)
        assertEquals(
            listOf(BleProperty.Read, BleProperty.Write, BleProperty.WriteNoResponse, BleProperty.Notify, BleProperty.Indicate),
            all,
        )
        assertEquals(emptyList<BleProperty>(), BleProperty.fromMask(0x40))
        assertEquals(listOf("R", "N"), BleProperty.fromMask(0x12).map { it.label })
    }

    @Test
    fun uuidShortFormOnlyForSigBase() {
        assertEquals("180f", BleUuid.short(BleUuid.parse("180F")))
        val custom = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
        assertEquals(custom, BleUuid.short(BleUuid.parse(custom)))
    }

    @Test
    fun deviceDisplayNameFallbacks() {
        assertEquals("Watch", BleDeviceNames.displayName(" Watch ", null, "AA:BB:CC:DD:5E:F1"))
        assertEquals("Apple device", BleDeviceNames.displayName(null, 0x004C, "AA:BB:CC:DD:5E:F1"))
        assertEquals("Device 5EF1", BleDeviceNames.displayName("", null, "AA:BB:CC:DD:5E:F1"))
    }
}
