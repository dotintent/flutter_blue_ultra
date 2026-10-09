import Foundation

/// Abstraction over the Bluetooth stack. All callbacks are delivered on the main queue.
protocol BleClient: AnyObject {
    var onEvent: ((BleEvent) -> Void)? { get set }
    /// Creates the central (which triggers the system permission prompt when undetermined) and reports radio state.
    func activate()
    func startScan()
    func stopScan()
    /// Connects, then discovers services and characteristics, reporting progress via events.
    func connect(_ deviceId: UUID)
    func disconnect()
}

enum BleClientFactory {
    /// Simulator has no Bluetooth: use fake peripherals there, real CoreBluetooth on device.
    static func make() -> BleClient {
        #if targetEnvironment(simulator)
        return MockBleClient()
        #else
        return CoreBluetoothClient()
        #endif
    }
}
