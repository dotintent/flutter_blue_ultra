import Foundation

struct BleDevice: Identifiable, Hashable {
    let id: UUID
    var name: String?
    var rssi: Int

    var displayName: String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Unknown" : trimmed
    }

    /// Last 5 characters of the identifier UUID, e.g. "A1B2C".
    var shortId: String { String(id.uuidString.suffix(5)) }
}

enum BleProperty: String {
    case read = "R", write = "W", writeNoResponse = "WnR", notify = "N", indicate = "I"
}

struct BleCharacteristic: Identifiable, Hashable {
    let id = UUID()
    /// 16-bit alias ("2a19") for SIG UUIDs, else the full 128-bit string (lowercase).
    let uuid: String
    let properties: [BleProperty]
    var name: String? { GattNames.characteristic(uuid) }
}

struct BleService: Identifiable, Hashable {
    let id = UUID()
    let uuid: String
    let characteristics: [BleCharacteristic]
    var name: String? { GattNames.service(uuid) }
}

enum BleConnectionState: Equatable {
    case disconnected, connecting, discovering, connected
    case failed(String)

    var label: String {
        switch self {
        case .disconnected: "Not connected"
        case .connecting: "Connecting…"
        case .discovering: "Discovering services…"
        case .connected: "Connected"
        case .failed: "Connection failed"
        }
    }
}

/// Bluetooth radio / authorization, collapsed to what the UI gates on.
enum BleRadioState: Equatable {
    case notDetermined, denied, poweredOff, unsupported, resetting, ready
}

enum BleEvent {
    case radio(BleRadioState)
    case discovered(BleDevice)
    case connection(BleConnectionState)
    case services([BleService])
    case scanFailed(String)
}

/// 16-bit alias for SIG-base UUIDs ("180f"), else the full lowercase string.
func shortUuid(_ uuid: String) -> String {
    let s = uuid.lowercased()
    if s.count == 4 { return s }
    if s.count == 36, s.hasPrefix("0000"), s.hasSuffix("-0000-1000-8000-00805f9b34fb") {
        return String(s.dropFirst(4).prefix(4))
    }
    return s
}

func displayUuid(_ uuid: String) -> String {
    uuid.count == 4 ? uuid.uppercased() : uuid.lowercased()
}

/// Number of lit bars (1...5) for an RSSI in dBm.
func rssiBars(_ rssi: Int) -> Int {
    min(max(Int(((Double(rssi) + 100) / 10).rounded()), 1), 5)
}

/// Bluetooth SIG assigned-number names, ported from GattNames.kt.
enum GattNames {
    private static let services: [String: String] = [
        "1800": "Generic Access", "1801": "Generic Attribute", "180A": "Device Information",
        "180F": "Battery Service", "180D": "Heart Rate", "181A": "Environmental Sensing",
        "1818": "Cycling Power",
    ]

    private static let characteristics: [String: String] = [
        "2A00": "Device Name", "2A01": "Appearance", "2A19": "Battery Level",
        "2A24": "Model Number", "2A25": "Serial Number", "2A26": "Firmware Revision",
        "2A27": "Hardware Revision", "2A29": "Manufacturer Name", "2A37": "Heart Rate Measurement",
        "2A38": "Body Sensor Location", "2A39": "HR Control Point", "2A6D": "Pressure",
        "2A6E": "Temperature", "2A6F": "Humidity",
    ]

    static func service(_ uuid: String) -> String? { services[alias(uuid) ?? ""] }
    static func characteristic(_ uuid: String) -> String? { characteristics[alias(uuid) ?? ""] }

    /// Accepts a 16-bit alias or a full UUID on the SIG base; nil for custom UUIDs.
    private static func alias(_ uuid: String) -> String? {
        let v = uuid.trimmingCharacters(in: .whitespaces).lowercased()
        if v.count == 4 { return v.uppercased() }
        let s = shortUuid(v)
        return s.count == 4 ? s.uppercased() : nil
    }
}
