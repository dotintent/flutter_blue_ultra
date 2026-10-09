package com.lib.flutter_blue_ultra_example.wear.ble

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow

/**
 * Fake peripherals for emulators and demos.
 * "Mock Flaky" always fails to connect, to exercise the error state; "Mock Bare" exposes no services.
 */
class MockBleClient : BleClient {
    private class MockDevice(val device: BleDevice, val services: List<BleService>)

    private val _state = MutableStateFlow<BleConnectionState>(BleConnectionState.Disconnected)
    override val connectionState: StateFlow<BleConnectionState> = _state.asStateFlow()

    private val _services = MutableStateFlow<List<BleService>>(emptyList())
    override val services: StateFlow<List<BleService>> = _services.asStateFlow()

    private fun characteristic(service: String, uuid: String, vararg props: BleProperty) =
        BleCharacteristic(uuid, service, props.toList())

    private val genericAccess = BleService(
        "1800",
        listOf(
            characteristic("1800", "2a00", BleProperty.Read),
            characteristic("1800", "2a01", BleProperty.Read),
        ),
    )
    private val battery = BleService(
        "180f",
        listOf(characteristic("180f", "2a19", BleProperty.Read, BleProperty.Notify)),
    )
    private val deviceInfo = BleService(
        "180a",
        listOf(
            characteristic("180a", "2a29", BleProperty.Read),
            characteristic("180a", "2a24", BleProperty.Read),
            characteristic("180a", "2a26", BleProperty.Read),
        ),
    )
    private val heartRate = BleService(
        "180d",
        listOf(
            characteristic("180d", "2a37", BleProperty.Notify),
            characteristic("180d", "2a38", BleProperty.Read),
            characteristic("180d", "2a39", BleProperty.Write),
        ),
    )
    private val custom = BleService(
        "6e400001-b5a3-f393-e0a9-e50e24dcca9e",
        listOf(
            characteristic(
                "6e400001-b5a3-f393-e0a9-e50e24dcca9e", "6e400002-b5a3-f393-e0a9-e50e24dcca9e",
                BleProperty.Write, BleProperty.WriteNoResponse,
            ),
            characteristic(
                "6e400001-b5a3-f393-e0a9-e50e24dcca9e", "6e400003-b5a3-f393-e0a9-e50e24dcca9e",
                BleProperty.Read, BleProperty.Notify, BleProperty.Indicate,
            ),
        ),
    )

    private val devices = listOf(
        MockDevice(BleDevice("00:00:00:00:00:01", "Mock Sensor", -52), listOf(genericAccess, battery, deviceInfo)),
        MockDevice(BleDevice("00:00:00:00:00:02", "Mock Tracker", -67), listOf(genericAccess, heartRate, custom)),
        MockDevice(BleDevice("00:00:00:00:00:03", "Mock Flaky", -80), emptyList()),
        // Advertises no name, like most phones/earbuds: shows the manufacturer fallback.
        MockDevice(BleDevice("00:00:00:00:00:04", null, -74, manufacturerId = 0x004C), listOf(genericAccess)),
        MockDevice(BleDevice("00:00:00:00:00:05", "Mock Bare", -90), emptyList()),
    )

    override fun scan(): Flow<BleDevice> = flow {
        for (d in devices) {
            delay(400)
            emit(d.device)
        }
        while (true) delay(1_000)
    }

    override suspend fun connect(deviceId: String) {
        val target = devices.firstOrNull { it.device.id == deviceId } ?: throw BleException("Unknown device")
        _services.value = emptyList()
        _state.value = BleConnectionState.Connecting
        delay(600)
        if (target.device.name == "Mock Flaky") {
            val message = "Connection failed (mock)"
            _state.value = BleConnectionState.Failed(message)
            throw BleException(message)
        }
        _state.value = BleConnectionState.Discovering
        delay(500)
        _services.value = target.services
        _state.value = BleConnectionState.Connected
    }

    override fun disconnect() {
        _services.value = emptyList()
        _state.value = BleConnectionState.Disconnected
    }

    override fun close() = disconnect()
}
