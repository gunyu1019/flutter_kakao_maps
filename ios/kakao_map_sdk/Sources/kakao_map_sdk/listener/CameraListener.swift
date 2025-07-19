import Flutter
import KakaoMapsSDK

class CameraListener {
    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func onCameraWillMovedEvent(_ param: CameraActionEventParam) {
        channel.invokeMethod("onCameraMoveStart", arguments: [
            "gesture": param.by.rawValue,
        ])
    }

    func onCameraStoppedEvent(_ param: CameraActionEventParam) {
        let mapView = param.view as! KakaoMap
        let position = mapView.getPosition(CGPoint(x: mapView.viewRect.width * 0.5, y: mapView.viewRect.height * 0.5))
        var payload: [String: Any] = [
            "zoomLevel": mapView.zoomLevel,
            "tiltAngle": mapView.tiltAngle,
            "rotationAngle": mapView.rotationAngle,
            "height": mapView.cameraHeight,
        ]
        payload.merge(position.toMessageable()) { current, _ in current }

        channel.invokeMethod("onCameraMoveEnd", arguments: [
            "gesture": param.by.rawValue,
            "position": payload,
        ])
    }
}
