import CoreBluetooth
import Foundation

/// Real CoreBluetooth client. The central is created lazily in `activate()` so the permission prompt
/// only appears once the user taps Allow (or authorization was already decided).
final class CoreBluetoothClient: NSObject, BleClient, CBCentralManagerDelegate, CBPeripheralDelegate {
    var onEvent: ((BleEvent) -> Void)?

    private var central: CBCentralManager?
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var active: CBPeripheral?
    private var wantsScan = false
    private var userDisconnect = false
    private var pendingCharacteristics = 0
    private var discovered: [CBService] = []

    private func emit(_ event: BleEvent) {
        DispatchQueue.main.async { [weak self] in self?.onEvent?(event) }
    }

    func activate() {
        if central == nil {
            central = CBCentralManager(delegate: self, queue: .main)
        } else if let central {
            centralManagerDidUpdateState(central)
        }
    }

    func startScan() {
        wantsScan = true
        applyScan()
    }

    func stopScan() {
        wantsScan = false
        central?.stopScan()
    }

    private func applyScan() {
        guard let central, central.state == .poweredOn, wantsScan else { return }
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func connect(_ deviceId: UUID) {
        guard let central, let peripheral = peripherals[deviceId] else {
            emit(.connection(.failed("Device not found")))
            return
        }
        tearDown(cancel: true)
        userDisconnect = false
        active = peripheral
        peripheral.delegate = self
        emit(.connection(.connecting))
        central.connect(peripheral)
    }

    func disconnect() {
        userDisconnect = true
        tearDown(cancel: true)
    }

    private func tearDown(cancel: Bool) {
        if cancel, let p = active, let central { central.cancelPeripheralConnection(p) }
        active?.delegate = nil
        active = nil
        discovered = []
        pendingCharacteristics = 0
    }

    // MARK: CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            emit(.radio(.ready))
            applyScan()
        case .poweredOff: emit(.radio(.poweredOff))
        case .unauthorized: emit(.radio(.denied))
        case .unsupported: emit(.radio(.unsupported))
        case .resetting: emit(.radio(.resetting))
        default: emit(.radio(.notDetermined))
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let rssi = RSSI.intValue
        guard rssi != 127 else { return } // 127 = RSSI unavailable
        peripherals[peripheral.identifier] = peripheral
        let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name
        emit(.discovered(BleDevice(id: peripheral.identifier, name: name, rssi: rssi)))
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral === active else { return }
        emit(.connection(.discovering))
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard peripheral === active else { return }
        tearDown(cancel: false)
        emit(.connection(.failed(error?.localizedDescription ?? "Connection failed")))
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard peripheral === active, !userDisconnect else { return }
        tearDown(cancel: false)
        emit(.connection(.failed(error?.localizedDescription ?? "Disconnected")))
    }

    // MARK: CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral === active else { return }
        if let error {
            tearDown(cancel: true)
            emit(.connection(.failed(error.localizedDescription)))
            return
        }
        discovered = peripheral.services ?? []
        pendingCharacteristics = discovered.count
        if discovered.isEmpty {
            finishDiscovery()
        } else {
            discovered.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral === active else { return }
        pendingCharacteristics -= 1
        if pendingCharacteristics <= 0 { finishDiscovery() }
    }

    private func finishDiscovery() {
        let services = discovered.map { service in
            BleService(
                uuid: shortUuid(service.uuid.uuidString),
                characteristics: (service.characteristics ?? []).map { c in
                    BleCharacteristic(uuid: shortUuid(c.uuid.uuidString), properties: Self.properties(c.properties))
                }
            )
        }
        emit(.services(services))
        emit(.connection(.connected))
    }

    private static func properties(_ p: CBCharacteristicProperties) -> [BleProperty] {
        var out: [BleProperty] = []
        if p.contains(.read) { out.append(.read) }
        if p.contains(.write) { out.append(.write) }
        if p.contains(.writeWithoutResponse) { out.append(.writeNoResponse) }
        if p.contains(.notify) { out.append(.notify) }
        if p.contains(.indicate) { out.append(.indicate) }
        return out
    }
}
