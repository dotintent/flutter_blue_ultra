package com.lib.flutter_blue_ultra_example.wear.ble

/** Bluetooth SIG assigned-number names, ported from the phone app's gatt_names.dart. */
object GattNames {
    private val services = mapOf(
        "1800" to "Generic Access",
        "1801" to "Generic Attribute",
        "180A" to "Device Information",
        "180F" to "Battery Service",
        "180D" to "Heart Rate",
        "181A" to "Environmental Sensing",
        "1818" to "Cycling Power",
    )

    private val characteristics = mapOf(
        "2A00" to "Device Name",
        "2A01" to "Appearance",
        "2A19" to "Battery Level",
        "2A24" to "Model Number",
        "2A25" to "Serial Number",
        "2A26" to "Firmware Revision",
        "2A27" to "Hardware Revision",
        "2A29" to "Manufacturer Name",
        "2A37" to "Heart Rate Measurement",
        "2A38" to "Body Sensor Location",
        "2A39" to "HR Control Point",
        "2A6D" to "Pressure",
        "2A6E" to "Temperature",
        "2A6F" to "Humidity",
    )

    /** Accepts a 16-bit alias ("180f") or a full UUID on the SIG base; null for unknown/custom UUIDs. */
    fun service(uuid: String): String? = services[alias(uuid)]

    fun characteristic(uuid: String): String? = characteristics[alias(uuid)]

    private val sigBase = Regex("^0000([0-9a-fA-F]{4})-0000-1000-8000-00805f9b34fb$", RegexOption.IGNORE_CASE)

    private fun alias(uuid: String): String? {
        val v = uuid.trim()
        if (v.length == 4) return v.uppercase()
        return sigBase.find(v)?.groupValues?.get(1)?.uppercase()
    }
}
