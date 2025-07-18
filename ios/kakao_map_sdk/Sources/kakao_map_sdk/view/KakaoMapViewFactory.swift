import Flutter
import KakaoMapsSDK

class KakaoMapViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()

        URLSession.shared.configuration.httpMaximumConnectionsPerHost = 8
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> any FlutterPlatformView {
        let channel = FlutterMethodChannel(
            name: FlutterKakaoMapsPlugin.createViewMethodChannelName(id: viewId),
            binaryMessenger: messenger
        )
        let overlayChannel = FlutterMethodChannel(
            name: FlutterKakaoMapsPlugin.createOverlayMethodChannelName(id: viewId),
            binaryMessenger: messenger
        )

        let arguments = asDict(args!)
        let option = MapviewInfo(payload: arguments, viewId: viewId)

        return KakaoMapView(frame: frame, channel: channel, overlayChannel: overlayChannel, option: option)
    }

    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}
