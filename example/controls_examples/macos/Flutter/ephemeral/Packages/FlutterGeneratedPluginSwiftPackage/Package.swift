// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-11.5.0"),
        .package(name: "file_picker", path: "../.packages/file_picker-8.3.7"),
        .package(name: "file_selector_macos", path: "../.packages/file_selector_macos-0.9.5"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-8.3.1"),
        .package(name: "share_plus", path: "../.packages/share_plus-10.1.4"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "syncfusion_pdfviewer_macos", path: "../.packages/syncfusion_pdfviewer_macos-29.2.11"),
        .package(name: "url_launcher_macos", path: "../.packages/url_launcher_macos-3.2.5"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.11.0"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "file-selector-macos", package: "file_selector_macos"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "syncfusion-pdfviewer-macos", package: "syncfusion_pdfviewer_macos"),
                .product(name: "url-launcher-macos", package: "url_launcher_macos"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
