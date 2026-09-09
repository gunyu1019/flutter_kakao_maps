import Flutter
import KakaoMapsSDK

protocol LabelControllerHandler {
    var labelManager: LabelManager { get }
    var labelListener: PoiClickListener { get }

    func createLabelLayer(option: LabelLayerOptions, onSuccess: (Any?) -> Void)

    func removeLabelLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPoiStyle(style: PoiStyle, onSuccess: (String?) -> Void)

    func addPoi(layer: LabelLayer, poi: PoiOptions, position: MapPoint, visible: Bool, onSuccess: @escaping (String?) -> Void)

    func removePoi(layer: LabelLayer, poiId: String, onSuccess: (Any?) -> Void)

    func addPolylineText(layer: LabelLayer, label: WaveTextOptions, visible: Bool, onSuccess: (String?) -> Void)

    func removePolylineText(layer: LabelLayer, labelId: String, onSuccess: (Any?) -> Void)

    func changePolylineTextAndStyle(label: WaveText, styleId: String, text: String?, onSuccess: (Any?) -> Void)

    func changePolylineTextVisible(label: WaveText, visible: Bool, onSuccess: (Any?) -> Void)

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

    func addPoiBadge(poi: Poi, badge: PoiBadge, visible: Bool, onSuccess: (String?) -> Void)

    func removePoiBadge(poi: Poi, badgeId: String, onSuccess: (Any?) -> Void)

    func changePoiBadgeVisible(poi: Poi, badgeId: String, visible: Bool, onSuccess: (Any?) -> Void)

    func addShareTransformPoi(poi: Poi, targetPoi: Poi, onSuccess: (Any?) -> Void)

    func addShareTransformShape(poi: Poi, targetShapeLayerId: String, targetShapeId: String, onSuccess: (Any?) -> Void)

    func removeShareTransformPoi(poi: Poi, targetPoi: Poi, onSuccess: (Any?) -> Void)

    func removeShareTransformShape(poi: Poi, targetShapeLayerId: String, targetShapeId: String, onSuccess: (Any?) -> Void)

    func addSharePositionPoi(poi: Poi, targetPoi: Poi, onSuccess: (Any?) -> Void)

    func removeSharePositionPoi(poi: Poi, targetPoi: Poi, onSuccess: (Any?) -> Void)

    func movePathPoi(poi: Poi, path: [MapPoint], duration: UInt, baseRadian: Float?, cornerRadius: Float, jumpThreshold: Float, onSuccess: (Any?) -> Void)
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
            layer?.getPoi(poiID: key)
        }

        let polylineTextId = castSafty(arguments?["labelId"], caster: asString)
        let polylineText: WaveText? = polylineTextId.flatMap { key in
            layer?.getWaveText(waveTextID: key)
        }

        func requireLayer() -> LabelLayer? {
            guard let layer else {
                result(missingNativeResource(method: call.method, resource: "label layer", id: layerId))
                return nil
            }
            return layer
        }

        func requirePoi() -> Poi? {
            guard requireLayer() != nil else { return nil }
            guard let poi else {
                result(missingNativeResource(method: call.method, resource: "POI", id: poiId))
                return nil
            }
            return poi
        }

        func requirePolylineText() -> WaveText? {
            guard requireLayer() != nil else { return nil }
            guard let polylineText else {
                result(missingNativeResource(method: call.method, resource: "polyline text", id: polylineTextId))
                return nil
            }
            return polylineText
        }

        switch call.method {
        case "createLabelLayer": createLabelLayer(option: LabelLayerOptions(payload: arguments!), onSuccess: result)
        case "removeLabelLayer":
            guard requireLayer() != nil, let layerId else { return }
            removeLabelLayer(layerId: layerId, onSuccess: result)
        case "addPoiStyle": addPoiStyle(style: PoiStyle(payload: arguments!), onSuccess: result)
        case "addPoi":
            guard let layer = requireLayer() else { return }
            let poiArgument = asDict(arguments!["poi"]!)
            let poiOption = PoiOptions(payload: poiArgument)
            let position = MapPoint(payload: poiArgument)
            let visible = asBool(arguments!["visible"] ?? true)
            addPoi(layer: layer, poi: poiOption, position: position, visible: visible, onSuccess: result)
        case "removePoi":
            guard let layer = requireLayer(), requirePoi() != nil, let poiId else { return }
            removePoi(layer: layer, poiId: poiId, onSuccess: result)
        case "addPolylineText":
            guard let layer = requireLayer() else { return }
            let waveTextArgument = asDict(arguments!["label"]!)
            let waveTextStyle = WaveTextStyle(payload: asDict(waveTextArgument["style"]!))
            labelManager.addWaveTextStyle(waveTextStyle)
            let waveTextOption = WaveTextOptions(payload: waveTextArgument, styleId: waveTextStyle.styleID)
            let visible = asBool(waveTextArgument["visible"] ?? true)
            addPolylineText(layer: layer, label: waveTextOption, visible: visible, onSuccess: result)
        case "removePolylineText":
            guard let layer = requireLayer(), requirePolylineText() != nil, let polylineTextId else { return }
            removePolylineText(layer: layer, labelId: polylineTextId, onSuccess: result)
        // poi Handler
        case "changePoiOffsetPosition":
            guard let poi = requirePoi() else { return }
            let rawPayload: [String: Double] = ["x": asDouble(arguments!["x"]!), "y": asDouble(arguments!["y"]!)]
            let offset = CGPoint(payload: rawPayload)
            changePoiPixelOffset(poi: poi, offset: offset, onSuccess: result)
        case "changePoiVisible":
            guard let poi = requirePoi() else { return }
            let visible = asBool(arguments!["visible"]!)
            let autoMove = castSafty(arguments!["autoMove"], caster: asBool) ?? false
            changePoiVisible(poi: poi, visible: visible, autoMove: autoMove, onSuccess: result)
        case "changePoiStyle":
            guard let poi = requirePoi() else { return }
            let styleId = asString(arguments!["styleId"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            changePoiStyle(poi: poi, styleId: styleId, transition: transition, onSuccess: result)
        case "changePoiText":
            guard let poi = requirePoi() else { return }
            let text = asString(arguments!["text"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            let styleId = asString(arguments!["styleId"]!)
            changePoiText(poi: poi, styleId: styleId, text: text, transition: transition, onSuccess: result)
        case "invalidatePoi":
            guard let poi = requirePoi() else { return }
            let styleId = asString(arguments!["styleId"]!)
            let text = asString(arguments!["text"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            invalidatePoi(poi: poi, styleId: styleId, text: text, transition: transition, onSuccess: result)
        case "movePoi":
            guard let poi = requirePoi() else { return }
            let position = MapPoint(payload: arguments!)
            let duration = castSafty(arguments!["millis"], caster: asUInt)
            movePoi(poi: poi, position: position, duration: duration, onSuccess: result)
        case "rotatePoi":
            guard let poi = requirePoi() else { return }
            let angle = asDouble(arguments!["angle"]!)
            let duration = castSafty(arguments!["millis"], caster: asUInt)
            rotatePoi(poi: poi, angle: angle, duration: duration, onSuccess: result)
        case "rankPoi":
            guard let poi = requirePoi() else { return }
            let rank = asInt(arguments!["rank"]!)
            rankPoi(poi: poi, rank: rank, onSuccess: result)
        // polyline text Handler
        case "changePolylineTextStyle":
            guard let polylineText = requirePolylineText() else { return }
            let waveTextStyle = WaveTextStyle(payload: asDict(arguments!["styles"]!))
            labelManager.addWaveTextStyle(waveTextStyle)
            let text = castSafty(arguments?["text"], caster: asString)
            changePolylineTextAndStyle(
                label: polylineText,
                styleId: waveTextStyle.styleID,
                text: text,
                onSuccess: result
            )
        case "changePolylineTextVisible":
            guard let polylineText = requirePolylineText() else { return }
            changePolylineTextVisible(
                label: polylineText,
                visible: asBool(arguments!["visible"]!),
                onSuccess: result
            )
        case "setLayerClickable":
            guard let layer = requireLayer() else { return }
            changeLabelLayerClickable(layer: layer, clickable: asBool(arguments!["clickable"]!), onSuccess: result)
        case "setLayerZOrder":
            guard let layer = requireLayer() else { return }
            changeLabelLayerZOrder(layer: layer, zOrder: asInt(arguments!["zOrder"]!), onSuccess: result)
        case "changeVisibleAllPoi":
            guard let layer = requireLayer() else { return }
            changePoiAllVisible(layer: layer, visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "changeVisibleAllPolylineText":
            guard let layer = requireLayer() else { return }
            changePolylineTextAllVisible(layer: layer, visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "addPoiBadge":
            guard let poi = requirePoi() else { return }
            let badgeArgument = asDict(arguments!["badge"]!)
            let badgeOption = PoiBadge(payload: badgeArgument)
            let visible = asBool(badgeArgument["visible"] ?? true)
            addPoiBadge(poi: poi, badge: badgeOption, visible: visible, onSuccess: result)
        case "removePoiBadge":
            guard let poi = requirePoi() else { return }
            removePoiBadge(poi: poi, badgeId: asString(arguments!["badgeId"]!), onSuccess: result)
        case "changePoiBadgeVisible":
            guard let poi = requirePoi() else { return }
            changePoiBadgeVisible(
                poi: poi,
                badgeId: asString(arguments!["badgeId"]!),
                visible: asBool(arguments!["visible"]!),
                onSuccess: result
            )
        case "addShareTransformPoi":
            guard let poi = requirePoi() else { return }
            let targetLayerId: String = asString(arguments!["targetLabelLayerId"]!)
            let targetLayer: LabelLayer? = labelManager.getLabelLayer(layerID: targetLayerId)
            let targetPoiId: String = asString(arguments!["targetPoiId"]!)
            guard let targetLayer else {
                result(missingNativeResource(method: call.method, resource: "target label layer", id: targetLayerId))
                return
            }
            guard let targetPoi = targetLayer.getPoi(poiID: targetPoiId) else {
                result(missingNativeResource(method: call.method, resource: "target POI", id: targetPoiId))
                return
            }
            addShareTransformPoi(poi: poi, targetPoi: targetPoi, onSuccess: result)
        case "addShareTransformShape":
            guard let poi = requirePoi() else { return }
            let targetLayerId: String = asString(arguments!["targetShapeLayerId"]!)
            let targetShapeId: String = asString(arguments!["targetShapeId"]!)
            addShareTransformShape(
                poi: poi,
                targetShapeLayerId: targetLayerId,
                targetShapeId: targetShapeId,
                onSuccess: result
            )
        case "removeShareTransformPoi":
            guard let poi = requirePoi() else { return }
            let targetLayerId: String = asString(arguments!["targetLabelLayerId"]!)
            let targetLayer: LabelLayer? = labelManager.getLabelLayer(layerID: targetLayerId)
            let targetPoiId: String = asString(arguments!["targetPoiId"]!)
            guard let targetLayer else {
                result(missingNativeResource(method: call.method, resource: "target label layer", id: targetLayerId))
                return
            }
            guard let targetPoi = targetLayer.getPoi(poiID: targetPoiId) else {
                result(missingNativeResource(method: call.method, resource: "target POI", id: targetPoiId))
                return
            }
            removeShareTransformPoi(poi: poi, targetPoi: targetPoi, onSuccess: result)
        case "removeShareTransformShape":
            guard let poi = requirePoi() else { return }
            let targetLayerId: String = asString(arguments!["targetShapeLayerId"]!)
            let targetShapeId: String = asString(arguments!["targetShapeId"]!)
            removeShareTransformShape(
                poi: poi,
                targetShapeLayerId: targetLayerId,
                targetShapeId: targetShapeId,
                onSuccess: result
            )
        case "addSharePositionPoi":
            guard let poi = requirePoi() else { return }
            let targetLayerId: String = asString(arguments!["targetLabelLayerId"]!)
            let targetLayer: LabelLayer? = labelManager.getLabelLayer(layerID: targetLayerId)
            let targetPoiId: String = asString(arguments!["targetPoiId"]!)
            guard let targetLayer else {
                result(missingNativeResource(method: call.method, resource: "target label layer", id: targetLayerId))
                return
            }
            guard let targetPoi = targetLayer.getPoi(poiID: targetPoiId) else {
                result(missingNativeResource(method: call.method, resource: "target POI", id: targetPoiId))
                return
            }
            addSharePositionPoi(poi: poi, targetPoi: targetPoi, onSuccess: result)
        case "removeSharePositionPoi":
            guard let poi = requirePoi() else { return }
            let targetLayerId: String = asString(arguments!["targetLabelLayerId"]!)
            let targetLayer: LabelLayer? = labelManager.getLabelLayer(layerID: targetLayerId)
            let targetPoiId: String = asString(arguments!["targetPoiId"]!)
            guard let targetLayer else {
                result(missingNativeResource(method: call.method, resource: "target label layer", id: targetLayerId))
                return
            }
            guard let targetPoi = targetLayer.getPoi(poiID: targetPoiId) else {
                result(missingNativeResource(method: call.method, resource: "target POI", id: targetPoiId))
                return
            }
            removeSharePositionPoi(poi: poi, targetPoi: targetPoi, onSuccess: result)
        case "movePathPoi":
            guard let poi = requirePoi() else { return }
            let path = asArray(arguments!["path"]!, caster: {
                MapPoint(payload: asDict($0))
            })
            movePathPoi(
                poi: poi,
                path: path,
                duration: asUInt(arguments!["millis"]!),
                baseRadian: castSafty(arguments?["baseRadian"], caster: asFloat),
                cornerRadius: asFloat(arguments!["cornerRadius"]!),
                jumpThreshold: asFloat(arguments!["jumpThreshold"]!),
                onSuccess: result
            )
        default: result(FlutterMethodNotImplemented)
        }
    }
}
