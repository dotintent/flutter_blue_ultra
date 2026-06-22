// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_blue_ultra_accessory_setup",
    platforms: [
        .iOS("18.0")
    ],
    products: [
        .library(
            name: "flutter-blue-ultra-accessory-setup",
            targets: ["flutter_blue_ultra_accessory_setup"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_blue_ultra_accessory_setup",
            dependencies: [],
            // Explicit so the SPM link matches the podspec's `s.frameworks` and
            // doesn't rely solely on Swift autolinking. Flutter is injected by
            // the generated plugin package; Foundation/UIKit autolink.
            linkerSettings: [
                .linkedFramework("AccessorySetupKit"),
                .linkedFramework("CoreBluetooth"),
            ]
        )
    ]
)
