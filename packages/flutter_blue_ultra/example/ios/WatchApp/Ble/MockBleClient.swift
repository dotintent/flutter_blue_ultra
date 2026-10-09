import Foundation

/// Fake peripherals for the Simulator.
/// "Mock Flaky" always fails to connect; "Mock Bare" exposes no services.
final class MockBleClient: BleClient {
    var onEvent: ((BleEvent) -> Void)?

    private struct Mock { let device: BleDevice; let services: [BleService] }
    private var scanTask: Task<Void, Never>?
    private var connectTask: Task<Void, Never>?

    private static func id(_ n: Int) -> UUID { UUID(uuidString: "00000000-0000-0000-0000-0000000000\(String(format: "%02d", n))")! }
    private static func ch(_ uuid: String, _ props: BleProperty...) -> BleCharacteristic { BleCharacteristic(uuid: uuid, properties: props) }

    private let genericAccess = BleService(uuid: "1800", characteristics: [ch("2a00", .read), ch("2a01", .read)])
    private let battery = BleService(uuid: "180f", characteristics: [ch("2a19", .read, .notify)])
    private let deviceInfo = BleService(uuid: "180a", characteristics: [ch("2a29", .read), ch("2a24", .read), ch("2a26", .read)])
    private let heartRate = BleService(uuid: "180d", characteristics: [ch("2a37", .notify), ch("2a38", .read), ch("2a39", .write)])
    private let custom = BleService(uuid: "6e400001-b5a3-f393-e0a9-e50e24dcca9e", characteristics: [
        ch("6e400002-b5a3-f393-e0a9-e50e24dcca9e", .write, .writeNoResponse),
        ch("6e400003-b5a3-f393-e0a9-e50e24dcca9e", .read, .notify, .indicate),
    ])

    private lazy var mocks: [Mock] = [
        Mock(device: BleDevice(id: Self.id(1), name: "Mock Sensor", rssi: -52), services: [genericAccess, battery, deviceInfo]),
        Mock(device: BleDevice(id: Self.id(2), name: "Mock Tracker", rssi: -67), services: [genericAccess, heartRate, custom]),
        Mock(device: BleDevice(id: Self.id(3), name: "Mock Flaky", rssi: -80), services: []),
        Mock(device: BleDevice(id: Self.id(4), name: nil, rssi: -74), services: [genericAccess]),
        Mock(device: BleDevice(id: Self.id(5), name: "Mock Bare", rssi: -90), services: []),
    ]

    func activate() { onEvent?(.radio(.ready)) }

    func startScan() {
        scanTask?.cancel()
        scanTask = Task { @MainActor [weak self] in
            guard let mocks = self?.mocks else { return }
            for m in mocks {
                try? await Task.sleep(for: .milliseconds(400))
                if Task.isCancelled { return }
                self?.onEvent?(.discovered(m.device))
            }
        }
    }

    func stopScan() { scanTask?.cancel() }

    func connect(_ deviceId: UUID) {
        connectTask?.cancel()
        guard let target = mocks.first(where: { $0.device.id == deviceId }) else { return }
        connectTask = Task { @MainActor [weak self] in
            self?.onEvent?(.connection(.connecting))
            try? await Task.sleep(for: .milliseconds(600))
            if Task.isCancelled { return }
            if target.device.name == "Mock Flaky" {
                self?.onEvent?(.connection(.failed("Connection failed (mock)")))
                return
            }
            self?.onEvent?(.connection(.discovering))
            try? await Task.sleep(for: .milliseconds(500))
            if Task.isCancelled { return }
            self?.onEvent?(.services(target.services))
            self?.onEvent?(.connection(.connected))
        }
    }

    func disconnect() {
        connectTask?.cancel()
    }
}
