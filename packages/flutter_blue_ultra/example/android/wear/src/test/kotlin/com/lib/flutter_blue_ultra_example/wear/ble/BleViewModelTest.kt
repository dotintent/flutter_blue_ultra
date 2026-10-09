package com.lib.flutter_blue_ultra_example.wear.ble

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class BleViewModelTest {
    private val dispatcher = StandardTestDispatcher()
    private lateinit var vm: BleViewModel

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        vm = BleViewModel({ MockBleClient() }, defaultUseMock = true)
    }

    @After
    fun tearDown() {
        vm.stopScan()
        Dispatchers.resetMain()
    }

    private fun TestScope.scanAll() {
        vm.startScan()
        advanceTimeBy(2_500)
        runCurrent()
    }

    @Test
    fun scanSortsDevicesByRssiDescending() = kotlinx.coroutines.test.runTest(dispatcher) {
        scanAll()
        val state = vm.state.value
        assertTrue(state.scanning)
        assertEquals(listOf(-52, -67, -74, -80, -90), state.devices.map { it.rssi })
        assertEquals("Mock Sensor", state.devices.first().displayName())
    }

    @Test
    fun scanStopsAfterScanWindow() = kotlinx.coroutines.test.runTest(dispatcher) {
        vm.startScan()
        advanceTimeBy(BleViewModel.SCAN_WINDOW_MS + 100)
        runCurrent()
        assertFalse(vm.state.value.scanning)
    }

    @Test
    fun stopScanClearsScanningFlag() = kotlinx.coroutines.test.runTest(dispatcher) {
        scanAll()
        vm.stopScan()
        assertFalse(vm.state.value.scanning)
    }

    @Test
    fun withDeviceReplacesExistingEntryAndResorts() {
        val a = BleDevice("A", "a", -80)
        val b = BleDevice("B", "b", -60)
        val list = listOf(a, b).fold(emptyList<BleDevice>()) { acc, d -> acc.withDevice(d) }
        assertEquals(listOf("B", "A"), list.map { it.id })
        val updated = list.withDevice(BleDevice("A", "a", -40))
        assertEquals(listOf("A", "B"), updated.map { it.id })
        assertEquals(2, updated.size)
    }

    @Test
    fun connectGoesThroughDiscoveringToConnectedWithServices() = kotlinx.coroutines.test.runTest(dispatcher) {
        scanAll()
        val sensor = vm.state.value.devices.first { it.name == "Mock Sensor" }
        vm.connect(sensor)
        runCurrent()
        assertEquals(BleConnectionState.Connecting, vm.state.value.connection)
        advanceTimeBy(700)
        runCurrent()
        assertEquals(BleConnectionState.Discovering, vm.state.value.connection)
        advanceUntilIdle()
        val state = vm.state.value
        assertEquals(BleConnectionState.Connected, state.connection)
        assertEquals(sensor, state.selected)
        assertEquals(listOf("1800", "180f", "180a"), state.services.map { it.uuid })
        assertFalse(state.scanning)
        vm.disconnect()
    }

    @Test
    fun failedConnectExposesErrorAndRetryClearsIt() = kotlinx.coroutines.test.runTest(dispatcher) {
        val flaky = BleDevice("00:00:00:00:00:03", "Mock Flaky", -80)
        vm.connect(flaky)
        advanceUntilIdle()
        assertTrue(vm.state.value.connection is BleConnectionState.Failed)
        assertNotNull(vm.state.value.error)
        vm.connect(flaky)
        runCurrent()
        assertNull(vm.state.value.error)
        assertEquals(BleConnectionState.Connecting, vm.state.value.connection)
        advanceUntilIdle()
    }

    @Test
    fun deviceWithoutServicesConnectsWithEmptyList() = kotlinx.coroutines.test.runTest(dispatcher) {
        vm.connect(BleDevice("00:00:00:00:00:05", "Mock Bare", -90))
        advanceUntilIdle()
        assertEquals(BleConnectionState.Connected, vm.state.value.connection)
        assertTrue(vm.state.value.services.isEmpty())
    }

    @Test
    fun disconnectKeepsSelectionAndCloseDeviceClearsIt() = kotlinx.coroutines.test.runTest(dispatcher) {
        val sensor = BleDevice("00:00:00:00:00:01", "Mock Sensor", -52)
        vm.connect(sensor)
        advanceUntilIdle()
        vm.disconnect()
        runCurrent()
        assertEquals(BleConnectionState.Disconnected, vm.state.value.connection)
        assertTrue(vm.state.value.services.isEmpty())
        assertEquals(sensor, vm.state.value.selected)
        vm.closeDevice()
        assertNull(vm.state.value.selected)
    }

    @Test
    fun disconnectWhileConnectingCancelsConnect() = kotlinx.coroutines.test.runTest(dispatcher) {
        vm.connect(BleDevice("00:00:00:00:00:01", "Mock Sensor", -52))
        runCurrent()
        vm.disconnect()
        advanceUntilIdle()
        assertEquals(BleConnectionState.Disconnected, vm.state.value.connection)
    }
}
