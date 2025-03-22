import Flutter
import KakaoMapsSDK

class PoiClickListener {
    private let channel: FlutterMethodChannel
    var enable: Bool

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.enable = false
    }

    func onPoiInteractionEvent(_ param: PoiInteractionEventParam) {
        if enable return
        channel.invokeMethod("onPoiClick", arguments: [
            "layerId": param.poiItem.layerID,
            "poiId": param.poiItem.itemID,
        ])
    }

    func onLodPoiInteractionEvent(_ param: PoiInteractionEventParam) {
        if enable return
        channel.invokeMethod("onLodPoiClick", arguments: [
            "layerId": param.poiItem.layerID,
            "poiId": param.poiItem.itemID,
        ])
    }
}
