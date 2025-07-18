import PackageDescription

let package = Package(
    name: "kakao_map_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "kakao-map-sdk", targets: ["kakao_map_sdk"])
    ],
    dependencies: [
        .package(
        url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM.git",
        from: "2.12.5"
        )
    ],
    targets: [
        .target(
            // TODO: Update your target name.
            name: "kakao_map_sdk",
            dependencies: [
                .product(name: "KakaoMapsSDK-SPM", package: "KakaoMapsSDK-SPM")
            ],
            resources: []
        )
    ]
)