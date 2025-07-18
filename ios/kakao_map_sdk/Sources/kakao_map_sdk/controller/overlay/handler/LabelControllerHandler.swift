import Flutter
import KakaoMapsSDK

protocol LabelControllerHandler {
    var labelManager: LabelManager { get }
    var labelListener: PoiClickListener { get }

    func createLabelLayer(option: LabelLayerOptions, onSuccess: (Any?) -> Void)

    func removeLabelLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPoiStyle(style: PoiStyle, onSuccess: (String) -> Void)

    func addPoi(layer: LabelLayer, poi: PoiOptions, position: MapPoint, visible: Bool, onSuccess: @escaping (String) -> Void)

    func removePoi(layer: LabelLayer, poiId: String, onSuccess: (Any?) -> Void)

    func addPolylineText(layer: LabelLayer, label: WaveTextOptions, visible: Bool, onSuccess: (String) -> Void)

    func removePolylineText(layer: LabelLayer, labelId: String, onSuccess: (Any?) -> Void)

    func changePoiPixelOffset(poi: Poi, offset: CGPoint, onSuccess: (Any?) -> Void)

    func changePoiVisible(poi: Poi, visible: Bool, autoMove: Bool, onSuccess: (Any?) -> Void)

    func changePoiStyle(poi: Poi, styleId: String, transition: Bool, onSuccess: (Any?) -> Void)

    func changePoiText(poi: Poi, styleId: String, text: String, transition: Bool, onSuccess: (Any?) -> Void)

    func invalidatePoi(
        poi: Poi,
        styleId: String,
        text: String,
        transition: Bool,
        onSuccess: (Any?) -> Void
    )

    func movePoi(poi: Poi, position: MapPoint, duration: UInt?, onSuccess: (Any?) -> Void)

    func rotatePoi(poi: Poi, angle: Double, duration: UInt?, onSuccess: (Any?) -> Void)

    func rankPoi(poi: Poi, rank: Int, onSuccess: (Any?) -> Void)

    func changePoiAllVisible(layer: LabelLayer, visible: Bool, onSuccess: (Any?) -> Void)

    func changePolylineTextAllVisible(layer: LabelLayer, visible: Bool, onSuccess: (Any?) -> Void)

    func changeLabelLayerClickable(layer: LabelLayer, clickable: Bool, onSuccess: (Any?) -> Void)

    func changeLabelLayerZOrder(layer: LabelLayer, zOrder: Int, onSuccess: (Any?) -> Void)
}

extension LabelControllerHandler {
    func labelHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)
        let layerId: String? = castSafty(arguments?["layerId"], caster: asString)
        let layer: LabelLayer? = layerId.flatMap { key in
            labelManager.getLabelLayer(layerID: key)
        }

        let poiId = castSafty(arguments?["poiId"], caster: asString)
        let poi: Poi? = poiId.flatMap { key in
            layer!.getPoi(poiID: key)
        }

        let polylineTextId = castSafty(arguments?["labelId"], caster: asString)
        let polylineText: WaveText? = polylineTextId.flatMap { key in
            layer!.getWaveText(waveTextID: key)
        }

        switch call.method {
        case "createLabelLayer": createLabelLayer(option: LabelLayerOptions(payload: arguments!), onSuccess: result)
        case "removeLabelLayer": removeLabelLayer(layerId: layerId!, onSuccess: result)
        case "addPoiStyle": addPoiStyle(style: PoiStyle(payload: arguments!), onSuccess: result)
        case "addPoi":
            let poiArgument = asDict(arguments!["poi"]!)
            let poiOption = PoiOptions(payload: poiArgument)
            let position = MapPoint(payload: poiArgument)
            let visible = asBool(arguments!["visible"] ?? true)
            addPoi(layer: layer!, poi: poiOption, position: position, visible: visible, onSuccess: result)
        case "removePoi": removePoi(layer: layer!, poiId: poiId!, onSuccess: result)
        case "addPolylineText":
            let waveTextArgument = asDict(arguments!["label"]!)
            let waveTextStyle = WaveTextStyle(payload: asDict(waveTextArgument["style"]!))
            labelManager.addWaveTextStyle(waveTextStyle)
            let waveTextOption = WaveTextOptions(payload: waveTextArgument, styleId: waveTextStyle.styleID)
            let visible = asBool(arguments!["visible"] ?? true)
            addPolylineText(layer: layer!, label: waveTextOption, visible: visible, onSuccess: result)
        case "removePolylineText": removePolylineText(layer: layer!, labelId: poiId!, onSuccess: result)
        // poi Handler
        case "changePoiPixelOffset":
            let rawPayload: [String: Double] = ["x": asDouble(arguments!["x"]!), "y": asDouble(arguments!["y"]!)]
            let offset = CGPoint(payload: rawPayload)
            changePoiPixelOffset(poi: poi!, offset: offset, onSuccess: result)
        case "changePoiVisible":
            let visible = asBool(arguments!["visible"]!)
            let autoMove = castSafty(arguments!["autoMove"], caster: asBool) ?? false
            changePoiVisible(poi: poi!, visible: visible, autoMove: autoMove, onSuccess: result)
        case "changePoiStyle":
            let styleId = asString(arguments!["styleId"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            changePoiStyle(poi: poi!, styleId: styleId, transition: transition, onSuccess: result)
        case "changePoiText":
            let text = asString(arguments!["text"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            let styleId = asString(arguments!["styleId"]!)
            changePoiText(poi: poi!, styleId: styleId, text: text, transition: transition, onSuccess: result)
        case "invalidatePoi":
            let styleId = asString(arguments!["styleId"]!)
            let text = asString(arguments!["text"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            invalidatePoi(poi: poi!, styleId: styleId, text: text, transition: transition, onSuccess: result)
        case "movePoi":
            let position = MapPoint(payload: arguments!)
            let duration = castSafty(arguments!["millis"], caster: asUInt)
            movePoi(poi: poi!, position: position, duration: duration, onSuccess: result)
        case "rotatePoi":
            let angle = asDouble(arguments!["angle"]!)
            let duration = castSafty(arguments!["millis"], caster: asUInt)
            rotatePoi(poi: poi!, angle: angle, duration: duration, onSuccess: result)
        case "rankPoi":
            let rank = asInt(arguments!["rank"]!)
            rankPoi(poi: poi!, rank: rank, onSuccess: result)
        case "setLayerClickable":
            changeLabelLayerClickable(layer: layer!, clickable: asBool(arguments!["clickable"]!), onSuccess: result)
        case "setLayerZOrder":
            changeLabelLayerZOrder(layer: layer!, zOrder: asInt(arguments!["zOrder"]!), onSuccess: result)
        case "changeVisibleAllPoi": changePoiAllVisible(layer: layer!, visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "changeVisibleAllPolylineText":
            changePolylineTextAllVisible(layer: layer!, visible: asBool(arguments!["visible"]!), onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
