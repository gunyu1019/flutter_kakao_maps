// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(
        url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM.git",
        from: "2.12.5"
    ),
]

var targetDependencies: [Target.Dependency] = [
    .product(name: "KakaoMapsSDK-SPM", package: "KakaoMapsSDK-SPM"),
]

/// Flutter 3.47+ exposes the framework as a neighboring generated package.
/// Older supported Flutter versions inject Flutter without that package.
let flutterFrameworkPath = URL(fileURLWithPath: Context.packageDirectory)
    .deletingLastPathComponent()
    .appendingPathComponent("FlutterFramework")
    .path
if FileManager.default.fileExists(atPath: flutterFrameworkPath) {
    packageDependencies.append(
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    )
    targetDependencies.append(
        .product(name: "FlutterFramework", package: "FlutterFramework")
    )
}

let package = Package(
    name: "kakao_map_sdk",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "kakao-map-sdk", targets: ["kakao_map_sdk"]),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "kakao_map_sdk",
            dependencies: targetDependencies,
            resources: []
        ),
    ]
)
