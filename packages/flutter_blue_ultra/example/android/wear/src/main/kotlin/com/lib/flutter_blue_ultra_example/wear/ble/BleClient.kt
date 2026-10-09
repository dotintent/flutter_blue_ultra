package com.lib.flutter_blue_ultra_example.wear.ble

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow

/** One BLE connection at a time. Implemented by AndroidBleClient (real radio) and MockBleClient. */
interface BleClient {
    val connectionState: StateFlow<BleConnectionState>

    /** GATT services of the connected device; empty until discovery finishes and after disconnect. */
    val services: StateFlow<List<BleService>>

    /** Cold flow: scanning runs while collected. Fails with BleException when Bluetooth is unavailable. */
    fun scan(): Flow<BleDevice>

    /**
     * Connects and discovers services; returns when [connectionState] is Connected, or throws BleException
     * (connect error, discovery error or timeout).
     */
    suspend fun connect(deviceId: String)

    fun disconnect()

    fun close()
}
