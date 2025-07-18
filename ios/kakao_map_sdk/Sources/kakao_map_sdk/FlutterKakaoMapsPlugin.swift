import Flutter
import KakaoMapsSDK
import UIKit

public class FlutterKakaoMapsPlugin: NSObject, FlutterPlugin {
    private static var registrar: FlutterPluginRegistrar!

    public static func register(with registrar: FlutterPluginRegistrar) {
        self.registrar = registrar

        let kakaoMapFactory = KakaoMapViewFactory(messenger: registrar.messenger())
        registrar.register(kakaoMapFactory, withId: MAP_VIEW_TYPE_ID)

        let sdkChannel = FlutterMethodChannel(name: SDK_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let _ = SdkInitializer(channel: sdkChannel)
    }

    private static let MAP_VIEW_TYPE_ID = "plugin/kakao_map"

    private static let SDK_CHANNEL_NAME = "flutter_kakao_maps_sdk"
    private static let OVERLAY_CHANNEL_NAME = "flutter_kakao_maps_overlay"
    private static let VIEW_CHANNEL_NAME = "flutter_kakao_maps_view"

    static func createViewMethodChannelName(id: Int64) -> String {
        "\(VIEW_CHANNEL_NAME)#\(id)"
    }

    static func createOverlayMethodChannelName(id: Int64) -> String {
        "\(OVERLAY_CHANNEL_NAME)#\(id)"
    }

    static func getAssets(path: String) -> String {
        let key = registrar.lookupKey(forAsset: path)
        let mainBundle = Bundle.main
        let path = mainBundle.path(forResource: key, ofType: nil)!
        return path
    }
}
