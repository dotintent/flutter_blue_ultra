import SwiftUI

struct DeviceDetailView: View {
    @Environment(BleViewModel.self) private var model
    let device: BleDevice
    @State private var expanded: Set<UUID> = []

    private typealias C = DesignTokens.Colors

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Dimens.gap) {
                Text(device.displayName)
                    .font(DesignTokens.Fonts.titleLarge)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Text(device.shortId).font(DesignTokens.Fonts.monoSmall).foregroundStyle(C.textDim)
                    RssiBars(rssi: device.rssi)
                }
                HStack(spacing: 6) {
                    ConnectionDot(state: model.connection)
                    Text(model.connection.label).font(DesignTokens.Fonts.bodySmall)
                }
                if let message = failureMessage {
                    Text(message)
                        .font(DesignTokens.Fonts.bodySmall)
                        .foregroundStyle(C.accent)
                        .multilineTextAlignment(.center)
                }
                action
                if model.connection == .connected { serviceList }
            }
            .padding(.horizontal, 4)
        }
        .background(C.background)
        .navigationBarTitleDisplayMode(.inline)
        // Leaving the screen closes the connection.
        .onDisappear { model.closeDevice() }
    }

    private var failureMessage: String? {
        if case .failed(let message) = model.connection { return model.error ?? message }
        return model.error
    }

    @ViewBuilder
    private var action: some View {
        switch model.connection {
        case .disconnected:
            ActionChip(label: "Connect", systemImage: "link", primary: true) { model.connect(device) }
        case .failed:
            ActionChip(label: "Retry", systemImage: "arrow.clockwise", primary: true) { model.connect(device) }
        default:
            ActionChip(label: "Disconnect", systemImage: "xmark") { model.disconnect() }
        }
    }

    @ViewBuilder
    private var serviceList: some View {
        if model.services.isEmpty {
            Text("No services found")
                .font(DesignTokens.Fonts.bodySmall)
                .foregroundStyle(C.textDim)
        } else {
            Text("Services")
                .font(DesignTokens.Fonts.titleSmall)
                .foregroundStyle(C.textDim)
            ForEach(model.services) { service in
                let open = expanded.contains(service.id)
                Button {
                    if open { expanded.remove(service.id) } else { expanded.insert(service.id) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: open ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10))
                            .frame(width: DesignTokens.Dimens.iconSmall)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(service.name ?? displayUuid(service.uuid)).lineLimit(2)
                            if service.name != nil {
                                Text(displayUuid(service.uuid))
                                    .font(DesignTokens.Fonts.monoSmall)
                                    .foregroundStyle(C.textDim)
                                    .lineLimit(1)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(ChipButtonStyle())
                .accessibilityValue(open ? "Expanded" : "Collapsed")
                if open {
                    if service.characteristics.isEmpty {
                        Text("No characteristics")
                            .font(DesignTokens.Fonts.bodySmall)
                            .foregroundStyle(C.textDim)
                    }
                    ForEach(service.characteristics) { characteristic in
                        VStack(spacing: 2) {
                            Text(characteristic.name ?? "Characteristic")
                                .font(DesignTokens.Fonts.bodySmall)
                                .lineLimit(1)
                            Text(displayUuid(characteristic.uuid))
                                .font(DesignTokens.Fonts.monoSmall)
                                .foregroundStyle(C.textDim)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            HStack(spacing: 3) {
                                ForEach(characteristic.properties, id: \.self) { PropertyChip(property: $0) }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }
}
