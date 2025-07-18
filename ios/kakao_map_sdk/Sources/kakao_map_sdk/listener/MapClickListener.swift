import Flutter
import KakaoMapsSDK

class MapClickListener {
    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func onViewInteractionEvent(_ param: ViewInteractionEventParam) {
        let mapView = param.view as! KakaoMap
        let position = mapView.getPosition(param.point)

        channel.invokeMethod("onMapClick", arguments: [
            "point": param.point.toMessageable(),
            "position": position.toMessageable(),
        ])
    }

    func onCompassTappedEvent(_: KakaoMap) {
        channel.invokeMethod("onCompassClick", arguments: nil)
    }

    func onTerrainTappedEvent(_ param: TerrainInteractionEventParam) {
        let point = convertMapPointToPoint(kakaoMap: param.kakaoMap, position: param.position)
        channel.invokeMethod("onTerrainLongClick", arguments: [
            "point": point.toMessageable(),
            "position": param.position.toMessageable(),
        ])
    }

    func onTerrainLongPressedEvent(_ param: TerrainInteractionEventParam) {
        let point = convertMapPointToPoint(kakaoMap: param.kakaoMap, position: param.position)
        channel.invokeMethod("onTerrainLongClick", arguments: [
            "point": point.toMessageable(),
            "position": param.position.toMessageable(),
        ])
    }
}
