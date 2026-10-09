import SwiftUI

@main
struct WatchApp: App {
    @State private var model = BleViewModel()
    @State private var path: [BleDevice] = []

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                ScanView()
                    .navigationDestination(for: BleDevice.self) { DeviceDetailView(device: $0) }
            }
            .environment(model)
            .tint(DesignTokens.Colors.accent)
            .preferredColorScheme(.dark)
        }
    }
}
