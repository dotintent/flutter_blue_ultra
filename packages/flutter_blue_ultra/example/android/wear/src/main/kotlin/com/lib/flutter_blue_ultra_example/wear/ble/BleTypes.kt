package com.lib.flutter_blue_ultra_example.wear.ble

import java.util.UUID

/** [manufacturerId] is the Bluetooth SIG company id from the advertisement, when present. */
data class BleDevice(val id: String, val name: String?, val rssi: Int, val manufacturerId: Int? = null) {
    /** Advertised name, else "<Manufacturer> device", else a short address such as "Device 5E:F1". */
    fun displayName(): String = BleDeviceNames.displayName(name, manufacturerId, id)
}

object BleDeviceNames {
    fun manufacturer(companyId: Int?): String? = when (companyId) {
        0x004C -> "Apple"
        0x0006 -> "Microsoft"
        0x0075 -> "Samsung"
        0x00E0 -> "Google"
        0x0087 -> "Garmin"
        0x000F -> "Broadcom"
        0x0059 -> "Nordic"
        0x000D -> "Texas Instruments"
        0x0002 -> "Intel"
        0x001D -> "Qualcomm"
        0x000A -> "Qualcomm"
        0x0046 -> "MediaTek"
        0x0057 -> "Harman"
        0x0078 -> "Nike"
        0x006B -> "Polar"
        0x00D2 -> "Dialog"
        0x0131 -> "Cypress"
        0x0157 -> "Huami (Amazfit)"
        0x0171 -> "Amazon"
        0x012D -> "Sony"
        0x00C4 -> "LG"
        0x0030 -> "STMicroelectronics"
        0x0025 -> "NXP"
        0x0036 -> "Renesas"
        0x0009 -> "Infineon"
        0x0008 -> "Motorola"
        0x0001 -> "Nokia"
        0x0003 -> "IBM"
        0x0004 -> "Toshiba"
        0x0000 -> "Ericsson"
        0x0067 -> "GN Netcom (Jabra)"
        0x009E -> "Bose"
        0x01DA -> "Logitech"
        0x00CD -> "Microchip"
        0x02E5 -> "Espressif"
        0x0499 -> "Ruuvi"
        0x0822 -> "Adafruit"
        0x038F -> "Xiaomi"
        0x027D -> "Huawei"
        0x0118 -> "Radius Networks"
        0x015D -> "Estimote"
        0x0022 -> "NEC"
        0x003A -> "Matsushita (Panasonic)"
        0x0029 -> "Hitachi"
        0x0010 -> "Mitel"
        0x0013 -> "Atmel"
        0x0031 -> "Synopsys"
        0x003C -> "BlackBerry"
        0x00EA -> "Fossil"
        0x000B -> "Silicon Wave"
        else -> null
    }

    fun displayName(name: String?, companyId: Int?, id: String): String {
        name?.trim()?.takeIf { it.isNotEmpty() }?.let { return it }
        manufacturer(companyId)?.let { return "${it} device" }
        val tail = id.filter { it.isLetterOrDigit() }.takeLast(4).uppercase()
        return if (tail.isEmpty()) "Device" else "Device ${tail}"
    }
}

/** GATT characteristic properties shown as chips; [label] is the short form (R, W, WnR, N, I). */
enum class BleProperty(val label: String) {
    Read("R"), Write("W"), WriteNoResponse("WnR"), Notify("N"), Indicate("I");

    companion object {
        // Bit values of BluetoothGattCharacteristic.PROPERTY_*; literals keep this class JVM-testable.
        fun fromMask(mask: Int): List<BleProperty> = buildList {
            if (mask and 0x02 != 0) add(Read)
            if (mask and 0x08 != 0) add(Write)
            if (mask and 0x04 != 0) add(WriteNoResponse)
            if (mask and 0x10 != 0) add(Notify)
            if (mask and 0x20 != 0) add(Indicate)
        }
    }
}

/** [uuid] and [serviceUuid] use [BleUuid.short] (16-bit alias for SIG UUIDs, else the full 128-bit string). */
data class BleCharacteristic(
    val uuid: String,
    val serviceUuid: String,
    val properties: List<BleProperty>,
) {
    /** Known GATT name, else null. */
    val name: String? get() = GattNames.characteristic(uuid)
}

data class BleService(val uuid: String, val characteristics: List<BleCharacteristic>) {
    val name: String? get() = GattNames.service(uuid)
}

/** Short, upper-case form of a UUID for display, e.g. "180F". */
fun String.displayUuid(): String = if (length == 4) uppercase() else lowercase()

sealed interface BleConnectionState {
    data object Disconnected : BleConnectionState
    data object Connecting : BleConnectionState
    data object Discovering : BleConnectionState
    data class Reconnecting(val attempt: Int) : BleConnectionState
    data object Connected : BleConnectionState
    data class Failed(val message: String) : BleConnectionState
}

/** Why a BLE call failed, so the UI can show the right state instead of a generic error. */
enum class BleError { Other, BluetoothOff, PermissionDenied, LocationOff, ScanThrottled, ScanFailed, Timeout }

class BleException(message: String, val kind: BleError = BleError.Other) : Exception(message)

object BleUuid {
    private const val BASE_SUFFIX = "-0000-1000-8000-00805f9b34fb"

    /** Accepts a 16-bit short form ("180f") or a full 128-bit UUID. */
    fun parse(value: String): UUID {
        val v = value.trim().lowercase()
        return if (v.length == 4) UUID.fromString("0000$v$BASE_SUFFIX") else UUID.fromString(v)
    }

    /** Lowercase 16-bit short form for Bluetooth-base UUIDs, else the full 128-bit string. */
    fun short(uuid: UUID): String {
        val s = uuid.toString().lowercase()
        return if (s.startsWith("0000") && s.endsWith(BASE_SUFFIX)) s.substring(4, 8) else s
    }
}
