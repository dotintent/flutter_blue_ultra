import SwiftUI

/// Entry screen: permission and Bluetooth gating, then the scan list.
struct ScanView: View {
    @Environment(BleViewModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Dimens.gap) {
                switch model.radio {
                case .ready: scanContent
                case .notDetermined:
                    StatusMessage(icon: BluetoothGlyph(), title: "Allow Bluetooth",
                                  detail: "Needed to find nearby devices.",
                                  actionLabel: "Allow", action: model.requestAccess)
                case .denied:
                    StatusMessage(icon: BluetoothGlyph(), title: "Bluetooth blocked",
                                  detail: "Enable it in Watch Settings › Privacy › Bluetooth.")
                case .poweredOff:
                    StatusMessage(icon: Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                    .font(.system(size: DesignTokens.Dimens.iconLarge))
                                    .foregroundStyle(DesignTokens.Colors.accent),
                                  title: "Bluetooth is off",
                                  detail: "Turn it on in Control Center or Settings › Bluetooth.")
                case .unsupported:
                    StatusMessage(icon: BluetoothGlyph(), title: "Not supported",
                                  detail: "This device does not support Bluetooth LE.")
                case .resetting:
                    StatusMessage(icon: BluetoothGlyph(), title: "Bluetooth restarting",
                                  detail: "One moment…")
                }
            }
            .padding(.horizontal, 4)
        }
        .background(DesignTokens.Colors.background)
        .onAppear { model.scanScreenAppeared() }
        .onDisappear { model.scanScreenDisappeared() }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: model.stopScan()
            case .active: model.appBecameActive()
            default: break
            }
        }
    }

    @ViewBuilder
    private var scanContent: some View {
        Text("Nearby")
            .font(DesignTokens.Fonts.titleLarge)
            .frame(maxWidth: .infinity)
        if let message = model.error {
            ErrorChip(message: message, onDismiss: model.clearError)
        }
        Button {
            model.scanning ? model.stopScan() : model.startScan()
        } label: {
            HStack(spacing: 6) {
                if model.scanning {
                    ScanRipple()
                } else {
                    Image(systemName: "arrow.clockwise").frame(width: 24, height: 24)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(model.scanning ? "Stop" : (model.devices.isEmpty ? "Scan again" : "Scan"))
                    if model.scanning && model.devices.isEmpty {
                        Text("Searching…").font(DesignTokens.Fonts.caption).foregroundStyle(DesignTokens.Colors.textDim)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(ChipButtonStyle())

        if model.devices.isEmpty && !model.scanning && model.error == nil {
            Text("No devices found")
                .font(DesignTokens.Fonts.bodySmall)
                .foregroundStyle(DesignTokens.Colors.textDim)
        }
        ForEach(model.devices) { device in
            NavigationLink(value: device) {
                HStack(spacing: 8) {
                    RssiBars(rssi: device.rssi)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(device.displayName).lineLimit(1)
                        Text(device.shortId)
                            .font(DesignTokens.Fonts.monoSmall)
                            .foregroundStyle(DesignTokens.Colors.textDim)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(DesignTokens.Colors.textFaint)
                }
            }
            .buttonStyle(ChipButtonStyle())
        }
    }
}
