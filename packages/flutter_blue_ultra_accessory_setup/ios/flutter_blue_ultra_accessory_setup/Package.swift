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
            // type: .dynamic,
            targets: ["flutter_blue_ultra_accessory_setup", "flutter_blue_ultra_accessory_setup_swift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_blue_ultra_accessory_setup",
            publicHeadersPath: "public_headers",
            linkerSettings: [
                .linkedFramework("AccessorySetupKit"),
                .linkedFramework("Foundation"),
                .unsafeFlags(["-fvisibility=default"])
            ]
        ),
        .target(
            name: "flutter_blue_ultra_accessory_setup_swift",
            dependencies: [],
            resources: [],
            linkerSettings: [
                .linkedFramework("AccessorySetupKit"),
                .linkedFramework("UIKit"),
                .linkedFramework("Security"),
                .linkedFramework("Foundation"),
            ]
        )
    ]
)
