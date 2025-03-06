import Flutter
import KakaoMapsSDK

class SdkInitializer: NSObject {
    private let channel: FlutterMethodChannel
    private var isInitialzed: Bool

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        isInitialzed = false
        super.init()

        channel.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = asDict(call.arguments!)
        switch call.method {
        case "initialize":
            initalize(appKey: asString(arguments["appKey"]!), onSuccess: result)
        case "isInitialize":
            result(isInitialzed)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initalize(appKey: String, onSuccess: (Any?) -> Void) {
        SDKInitializer.InitSDK(appKey: appKey)
        isInitialzed = true
        onSuccess(nil)
    }
}
