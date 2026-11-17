import Flutter
import KakaoMapsSDK

class KakaoMapViewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar
    private let messenger: FlutterBinaryMessenger

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        messenger = registrar.messenger()
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

        // Resolve the engine when creating the view: plugin registration may happen before
        // a prewarmed engine is attached to its FlutterViewController.
        let engine = (registrar.viewController as? FlutterViewController)?.engine
        return KakaoMapView(frame: frame, channel: channel, overlayChannel: overlayChannel, option: option, flutterEngine: engine)
    }

    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}
