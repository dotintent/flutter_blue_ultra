import CoreBluetooth
import Observation
import SwiftUI

@MainActor
@Observable
final class BleViewModel {
    static let scanWindow: Duration = .seconds(30)
    static let connectTimeout: Duration = .seconds(15)
    static let discoveryTimeout: Duration = .seconds(10)

    private(set) var radio: BleRadioState = .notDetermined
    private(set) var scanning = false
    /// Sorted by RSSI, strongest first.
    private(set) var devices: [BleDevice] = []
    private(set) var selected: BleDevice?
    private(set) var connection: BleConnectionState = .disconnected
    private(set) var services: [BleService] = []
    private(set) var error: String?

    @ObservationIgnored private let client: BleClient
    @ObservationIgnored private var scanTimer: Task<Void, Never>?
    @ObservationIgnored private var phaseTimer: Task<Void, Never>?
    /// True while the scan screen is on top; gates auto-start after returning from the background.
    @ObservationIgnored private var scanScreenVisible = false

    init(client: BleClient = BleClientFactory.make()) {
        self.client = client
        client.onEvent = { [weak self] event in
            // Clients deliver on the main queue.
            MainActor.assumeIsolated { self?.handle(event) }
        }
        // Only touch CoreBluetooth right away if the user already decided (no prompt in that case).
        #if targetEnvironment(simulator)
        client.activate()
        #else
        if CBManager.authorization != .notDetermined { client.activate() }
        #endif
    }

    var isReady: Bool { radio == .ready }

    // MARK: Permission

    func requestAccess() { client.activate() }

    // MARK: Scan

    func scanScreenAppeared() {
        scanScreenVisible = true
        if isReady { startScan() }
    }

    func scanScreenDisappeared() {
        scanScreenVisible = false
        stopScan()
    }

    func appBecameActive() {
        if scanScreenVisible, isReady, !scanning { startScan() }
    }

    func startScan() {
        guard isReady, !scanning else { return }
        scanning = true
        devices = []
        error = nil
        client.startScan()
        scanTimer?.cancel()
        scanTimer = Task { [weak self] in
            try? await Task.sleep(for: Self.scanWindow)
            if !Task.isCancelled { self?.stopScan() }
        }
    }

    func stopScan() {
        scanTimer?.cancel()
        scanTimer = nil
        if scanning { client.stopScan() }
        scanning = false
    }

    func clearError() { error = nil }

    // MARK: Connection

    /// Selects the device, connects and discovers services. Also serves as Retry.
    func connect(_ device: BleDevice) {
        stopScan()
        resetConnection()
        selected = device
        connection = .connecting
        client.connect(device.id)
        arm(Self.connectTimeout, message: "Connection timed out")
    }

    /// Drops the link but keeps the device selected so Connect is offered again.
    func disconnect() {
        phaseTimer?.cancel()
        client.disconnect()
        resetConnection()
    }

    /// Leaving the detail screen: cancel the connection and forget the selection.
    func closeDevice() {
        disconnect()
        selected = nil
    }

    private func resetConnection() {
        connection = .disconnected
        services = []
        error = nil
    }

    /// Fails the connection if it has not left its current phase before the timeout.
    private func arm(_ timeout: Duration, message: String) {
        phaseTimer?.cancel()
        let phase = connection
        phaseTimer = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            guard !Task.isCancelled, let self, self.connection == phase else { return }
            self.client.disconnect()
            self.connection = .failed(message)
            self.error = message
        }
    }

    // MARK: Events

    private func handle(_ event: BleEvent) {
        switch event {
        case .radio(let state):
            radio = state
            if state != .ready { stopScan() } else if scanScreenVisible { startScan() }
        case .discovered(let device):
            guard scanning else { return }
            devices = (devices.filter { $0.id != device.id } + [device])
                .sorted { $0.rssi != $1.rssi ? $0.rssi > $1.rssi : $0.id.uuidString < $1.id.uuidString }
        case .connection(let state):
            // A late .disconnected must not overwrite a failure (Retry stays visible).
            if state == .disconnected, case .failed = connection { return }
            connection = state
            switch state {
            case .discovering: arm(Self.discoveryTimeout, message: "Service discovery timed out")
            case .connected, .disconnected: phaseTimer?.cancel()
            case .failed(let message): phaseTimer?.cancel(); error = message
            case .connecting: break
            }
        case .services(let list):
            services = list
        case .scanFailed(let message):
            error = message
            stopScan()
        }
    }
}
