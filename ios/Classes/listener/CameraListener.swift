import Flutter
import KakaoMapsSDK

internal class CameraListener {
    private let channel: FlutterMethodChannel

    init (channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func onCameraWillMovedEvent(_ param: CameraActionEventParam) {
        channel.invokeMethod("onCameraMoveStart", arguments: [
            "gesture": param.by.rawValue
        ])
    }

    func onCameraStoppedEvent(_ param: CameraActionEventParam) {
        let mapView = param.view as! KakaoMap
        let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))

        channel.invokeMethod("onCameraMoveEnd", arguments: [
            "gesture": param.by.rawValue,
            "position": position.toMessageable()
        ])
    }
}
