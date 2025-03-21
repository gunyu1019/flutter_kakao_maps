import Flutter
import KakaoMapsSDK

class PoiClickListener {
    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func onPoisInteractionEvent(_ param: PoisInteractionEventParam) {
        let labelManager = param.kakaoMap.getLabelManager()
        let layerID = param.layerID
        let poiId = param.poiID

        let lodLayer = labelManager.getLodLabelLayer(layerID)

        if lodLayer != nil {
            channel.invokeMethod("onLodPoiClick", arguments: [
                "layerId": layerID,
                "poiId": poiId,
            ])
            return
        }
        channel.invokeMethod("onPoiClick", arguments: [
            "layerId": layerID,
            "poiId": poiId,
        ])
    }
}
