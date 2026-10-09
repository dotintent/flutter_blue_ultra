import SwiftUI

private typealias C = DesignTokens.Colors

struct RssiBars: View {
    let rssi: Int

    var body: some View {
        let lit = rssiBars(rssi)
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < lit ? C.text : C.surfaceHigh)
                    .frame(width: 3, height: CGFloat(3 + (i + 1) * 2))
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Signal \(lit) of 5")
    }
}

struct ConnectionDot: View {
    let state: BleConnectionState

    private var color: Color {
        switch state {
        case .connected: C.success
        case .connecting, .discovering: C.warn
        case .failed: C.accent
        case .disconnected: C.textFaint
        }
    }

    var body: some View {
        Circle().fill(color).frame(width: DesignTokens.Dimens.dot, height: DesignTokens.Dimens.dot)
    }
}

/// Two expanding rings and a core dot; shown while scanning.
struct ScanRipple: View {
    var size: CGFloat = 24

    var body: some View {
        TimelineView(.animation) { context in
            let phase = (context.date.timeIntervalSinceReferenceDate / 1.6).truncatingRemainder(dividingBy: 1)
            Canvas { gc, canvas in
                let center = CGPoint(x: canvas.width / 2, y: canvas.height / 2)
                let maxR = min(canvas.width, canvas.height) / 2
                for offset in [0.0, 0.5] {
                    let p = (phase + offset).truncatingRemainder(dividingBy: 1)
                    let r = maxR * p
                    let ring = Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
                    gc.stroke(ring, with: .color(C.accent.opacity(1 - p)), lineWidth: 1.5)
                }
                let core = maxR * 0.2
                gc.fill(Path(ellipseIn: CGRect(x: center.x - core, y: center.y - core, width: core * 2, height: core * 2)),
                        with: .color(C.accent))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct PropertyChip: View {
    let property: BleProperty

    var body: some View {
        Text(property.rawValue)
            .font(DesignTokens.Fonts.monoSmall)
            .foregroundStyle(C.text)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(C.surfaceHigh, in: RoundedRectangle(cornerRadius: DesignTokens.Dimens.chipRadius))
    }
}

/// Full-width surface button used for rows and actions.
struct ChipButtonStyle: ButtonStyle {
    var primary = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Fonts.button)
            .foregroundStyle(primary ? C.background : C.text)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(primary ? C.accent : C.surfaceAlt, in: RoundedRectangle(cornerRadius: DesignTokens.Dimens.cardRadius))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct ActionChip: View {
    let label: String
    let systemImage: String
    var primary = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
        }
        .buttonStyle(ChipButtonStyle(primary: primary))
    }
}

/// Centred notice with an icon and an optional action.
struct StatusMessage<Icon: View>: View {
    let icon: Icon
    let title: String
    let detail: String
    var actionLabel: String?
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: DesignTokens.Dimens.gap) {
            icon
            Text(title).font(DesignTokens.Fonts.titleLarge).multilineTextAlignment(.center)
            Text(detail).font(DesignTokens.Fonts.bodySmall).foregroundStyle(C.textDim).multilineTextAlignment(.center)
            if let actionLabel {
                Button(actionLabel, action: action)
                    .buttonStyle(ChipButtonStyle(primary: true))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct BluetoothGlyph: View {
    var size: CGFloat = DesignTokens.Dimens.iconLarge

    var body: some View {
        Image("BluetoothGlyph")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(C.accent)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// Tap to dismiss.
struct ErrorChip: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            VStack(spacing: 2) {
                Text(message).foregroundStyle(C.accent).lineLimit(3)
                Text("Tap to dismiss").font(DesignTokens.Fonts.caption).foregroundStyle(C.textDim)
            }
        }
        .buttonStyle(ChipButtonStyle())
    }
}
