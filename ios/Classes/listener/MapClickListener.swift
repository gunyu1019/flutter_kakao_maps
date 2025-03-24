import Flutter
import KakaoMapsSDK

class MapClickListener {
    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func onViewInteractionEvent(_ param: ViewInteractionEventParam) {
        let mapView = param.view as! KakaoMap
        let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))

        channel.invokeMethod("onMapClick", arguments: [
            "point": param.point.toMessageable(),
            "position": position.toMessageable(),
        ])
    }

    func onCompassTappedEvent() {
        channel.invokeMethod("onCompassClick", arguments: nil)
    }

    func onTerrainTappedEvent(_ param: TerrainInteractionEventParam) {
        let mapView = param.kakaoMap
        let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))

        channel.invokeMethod("onTerrainClick", arguments: [
            "point": param.position.toMessageable(),
            "position": position.toMessageable(),
        ])
    }

    func onTerrainLongPressedEvent(_ param: TerrainInteractionEventParam) {
        let mapView = param.kakaoMap
        let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))

        channel.invokeMethod("onTerrainLongClick", arguments: [
            "point": param.point.toMessageable(),
            "position": position.toMessageable(),
        ])
    }
}
