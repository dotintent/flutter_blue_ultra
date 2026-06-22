import AccessorySetupKit
import CoreBluetooth
import Flutter
import UIKit

/// Flutter plugin bridging Apple's AccessorySetupKit through Pigeon platform
/// channels. The session is a singleton owned by the plugin instance.
public final class FlutterAccessorySetupPlugin: NSObject, FlutterPlugin, AccessorySetupApi {

  private let session = ASAccessorySession()
  private let flutterApi: AccessorySetupFlutterApi

  /// Retains the native accessories so Dart can address them by identifier.
  private var accessoriesById: [String: ASAccessory] = [:]

  private let logQueue = DispatchQueue(label: "com.withintent.fbu.accessory-setup.logs")
  private var logs: [String] = []

  init(binaryMessenger: FlutterBinaryMessenger) {
    self.flutterApi = AccessorySetupFlutterApi(binaryMessenger: binaryMessenger)
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterAccessorySetupPlugin(binaryMessenger: registrar.messenger())
    AccessorySetupApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    registrar.publish(instance)
  }

  // MARK: - AccessorySetupApi

  func activate() throws {
    appendLog("activate")
    session.activate(on: .main) { [weak self] event in
      self?.handle(event: event)
    }
  }

  func showPicker(completion: @escaping (Result<Void, Error>) -> Void) {
    appendLog("showPicker")
    session.showPicker { [weak self] error in
      self?.complete(completion, error)
    }
  }

  func showPickerForItems(
    items: [PickerDisplayItem],
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    appendLog("showPickerForItems")
    do {
      let displayItems = try items.map { try makePickerDisplayItem($0) }
      session.showPicker(for: displayItems) { [weak self] error in
        self?.complete(completion, error)
      }
    } catch {
      completion(.failure(pigeonError(error)))
    }
  }

  func showPickerForDevice(
    name: String,
    imageBytes: FlutterStandardTypedData,
    serviceUuid: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    appendLog("showPickerForDevice")
    do {
      let item = try makePickerDisplayItem(
        name: name, imageData: imageBytes.data, serviceUuid: serviceUuid)
      session.showPicker(for: [item]) { [weak self] error in
        self?.complete(completion, error)
      }
    } catch {
      completion(.failure(pigeonError(error)))
    }
  }

  func removeAccessory(
    accessoryId: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    appendLog("removeAccessory \(accessoryId)")
    guard let accessory = accessoriesById[accessoryId] else {
      completion(.failure(unknownAccessoryError(accessoryId)))
      return
    }
    session.removeAccessory(accessory) { [weak self] error in
      self?.complete(completion, error)
    }
  }

  func renameAccessory(
    accessoryId: String,
    options: RenameOptions,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    appendLog("renameAccessory \(accessoryId)")
    guard let accessory = accessoriesById[accessoryId] else {
      completion(.failure(unknownAccessoryError(accessoryId)))
      return
    }
    var renameOptions: ASAccessory.RenameOptions = []
    if options.renameSSID {
      renameOptions.insert(.ssid)
    }
    session.renameAccessory(accessory, options: renameOptions) { [weak self] error in
      self?.complete(completion, error)
    }
  }

  func finishAuthorization(
    accessoryId: String,
    settings: AccessorySettings,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    appendLog("finishAuthorization \(accessoryId)")
    guard let accessory = accessoriesById[accessoryId] else {
      completion(.failure(unknownAccessoryError(accessoryId)))
      return
    }
    let accessorySettings = ASAccessorySettings()
    accessorySettings.ssid = settings.ssid
    accessorySettings.bluetoothTransportBridgingIdentifier =
      settings.bluetoothTransportBridgingIdentifier?.data
    session.finishAuthorization(for: accessory, settings: accessorySettings) {
      [weak self] error in
      self?.complete(completion, error)
    }
  }

  func failAuthorization(
    accessoryId: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    appendLog("failAuthorization \(accessoryId)")
    guard let accessory = accessoriesById[accessoryId] else {
      completion(.failure(unknownAccessoryError(accessoryId)))
      return
    }
    session.failAuthorization(for: accessory) { [weak self] error in
      self?.complete(completion, error)
    }
  }

  func getAccessories() throws -> [Accessory] {
    appendLog("getAccessories")
    return refreshAccessories()
  }

  func getLogs() throws -> [String] {
    return logQueue.sync { logs }
  }

  func invalidate() throws {
    appendLog("invalidate")
    session.invalidate()
  }

  // MARK: - Events

  private func handle(event: ASAccessoryEvent) {
    appendLog("event \(event.eventType.rawValue), error: \(String(describing: event.error))")
    // Refresh the id map so subsequent calls can resolve the accessory.
    _ = refreshAccessories()
    let payload = AccessoryEvent(
      type: mapEventType(event.eventType),
      accessory: event.accessory.map(mapAccessory),
      error: mapError(event.error)
    )
    flutterApi.onAccessoryEvent(event: payload) { _ in }
  }

  // MARK: - Mapping helpers

  @discardableResult
  private func refreshAccessories() -> [Accessory] {
    let native = session.accessories
    var map: [String: ASAccessory] = [:]
    var result: [Accessory] = []
    for accessory in native {
      let mapped = mapAccessory(accessory)
      if let id = mapped.bluetoothIdentifier {
        map[id] = accessory
      }
      result.append(mapped)
    }
    accessoriesById = map
    return result
  }

  private func mapAccessory(_ accessory: ASAccessory) -> Accessory {
    return Accessory(
      bluetoothIdentifier: accessory.bluetoothIdentifier?.uuidString,
      displayName: accessory.displayName,
      state: mapState(accessory.state),
      ssid: accessory.ssid
    )
  }

  private func mapState(_ state: ASAccessory.AccessoryState) -> AccessoryState {
    switch state {
    case .unauthorized: return .unauthorized
    case .awaitingAuthorization: return .awaitingAuthorization
    case .authorized: return .authorized
    @unknown default: return .unauthorized
    }
  }

  private func mapEventType(_ type: ASAccessoryEventType) -> AccessoryEventType {
    switch type {
    case .unknown: return .unknown
    case .activated: return .activated
    case .invalidated: return .invalidated
    case .migrationComplete: return .migrationComplete
    case .accessoryAdded: return .accessoryAdded
    case .accessoryRemoved: return .accessoryRemoved
    case .accessoryChanged: return .accessoryChanged
    case .accessoryDiscovered: return .accessoryDiscovered
    case .pickerDidPresent: return .pickerDidPresent
    case .pickerDidDismiss: return .pickerDidDismiss
    case .pickerSetupBridging: return .pickerSetupBridging
    case .pickerSetupFailed: return .pickerSetupFailed
    case .pickerSetupPairing: return .pickerSetupPairing
    case .pickerSetupRename: return .pickerSetupRename
    @unknown default: return .unknown
    }
  }

  private func mapError(_ error: Error?) -> NativeError? {
    guard let error else { return nil }
    let ns = error as NSError
    return NativeError(domain: ns.domain, code: Int64(ns.code), message: ns.localizedDescription)
  }

  private func makePickerDisplayItem(_ item: PickerDisplayItem) throws -> ASPickerDisplayItem {
    return try makePickerDisplayItem(
      name: item.name, imageData: item.imageBytes.data, serviceUuid: item.serviceUuid)
  }

  private func makePickerDisplayItem(
    name: String, imageData: Data, serviceUuid: String?
  ) throws -> ASPickerDisplayItem {
    guard let image = UIImage(data: imageData) else {
      throw PigeonError(
        code: "1", message: "Failed to decode product image for \"\(name)\".", details: "")
    }
    let descriptor = ASDiscoveryDescriptor()
    // Tell ASK to perform LE pairing/bonding (triggers the system passkey prompt
    // for MITM-protected accessories). Without this, ASK authorizes the accessory
    // but never bonds, so the user is never asked for a PIN.
    descriptor.supportedOptions = .bluetoothPairingLE
    if let serviceUuid {
      descriptor.bluetoothServiceUUID = CBUUID(string: serviceUuid)
    }
    return ASPickerDisplayItem(name: name, productImage: image, descriptor: descriptor)
  }

  // MARK: - Error helpers

  private func complete(
    _ completion: @escaping (Result<Void, Error>) -> Void, _ error: Error?
  ) {
    if let error {
      completion(.failure(pigeonError(error)))
    } else {
      completion(.success(()))
    }
  }

  private func pigeonError(_ error: Error) -> PigeonError {
    let ns = error as NSError
    return PigeonError(
      code: String(ns.code), message: ns.localizedDescription, details: ns.domain)
  }

  private func unknownAccessoryError(_ id: String) -> PigeonError {
    return PigeonError(
      code: "-1", message: "No accessory found for identifier \(id).", details: "")
  }

  private func appendLog(_ message: String) {
    logQueue.async { [weak self] in self?.logs.append(message) }
  }
}
