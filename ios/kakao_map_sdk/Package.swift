// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kakao_map_sdk",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "kakao-map-sdk", targets: ["kakao_map_sdk"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM.git",
            from: "2.12.5"
        ),
    ],
    targets: [
        .target(
            name: "kakao_map_sdk",
            dependencies: [
                .product(name: "KakaoMapsSDK-SPM", package: "KakaoMapsSDK-SPM"),
            ],
            resources: []
        ),
    ]
)
