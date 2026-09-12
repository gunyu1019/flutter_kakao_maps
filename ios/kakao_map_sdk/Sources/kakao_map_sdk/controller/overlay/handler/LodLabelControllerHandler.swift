import Flutter
import KakaoMapsSDK

protocol LodLabelControllerHandler {
    var labelManager: LabelManager { get }

    func createLodLabelLayer(option: LodLabelLayerOptions, onSuccess: (Any?) -> Void)

    func removeLodLabelLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addLodPoi(layer: LodLabelLayer, poi: PoiOptions, position: MapPoint, visible: Bool, onSuccess: @escaping (String?) -> Void)

    func removeLodPoi(layer: LodLabelLayer, poiId: String, onSuccess: (Any?) -> Void)

    func changeLodPoiVisible(poi: LodPoi, visible: Bool, autoMove: Bool, onSuccess: (Any?) -> Void)

    func changeLodPoiStyle(poi: LodPoi, styleId: String, transition: Bool, onSuccess: (Any?) -> Void)

    func changeLodPoiText(poi: LodPoi, styleId: String, text: String, transition: Bool, onSuccess: (Any?) -> Void)

    func rankLodPoi(poi: LodPoi, rank: Int, onSuccess: (Any?) -> Void)

    func changeLodPoiAllVisible(layer: LodLabelLayer, visible: Bool, onSuccess: (Any?) -> Void)

    func changeLodLabelLayerClickable(layer: LodLabelLayer, clickable: Bool, onSuccess: (Any?) -> Void)

    func changeLodLabelLayerZOrder(layer: LodLabelLayer, zOrder: Int, onSuccess: (Any?) -> Void)

    func addLodPoiBadge(poi: LodPoi, badge: PoiBadge, visible: Bool, onSuccess: (String?) -> Void)

    func removeLodPoiBadge(poi: LodPoi, badgeId: String, onSuccess: (Any?) -> Void)

    func changeLodPoiBadgeVisible(poi: LodPoi, badgeId: String, visible: Bool, onSuccess: (Any?) -> Void)
}

extension LodLabelControllerHandler {
    func lodLabelHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)
        let layerId: String? = castSafty(arguments?["layerId"], caster: asString)
        let layer: LodLabelLayer? = layerId.flatMap { key in
            labelManager.getLodLabelLayer(layerID: key)
        }

        let poiId = castSafty(arguments?["poiId"], caster: asString)
        let poi: LodPoi? = poiId.flatMap { key in
            layer?.getLodPoi(poiID: key)
        }

        func requireLayer() -> LodLabelLayer? {
            guard let layer else {
                result(missingNativeResource(method: call.method, resource: "LOD label layer", id: layerId))
                return nil
            }
            return layer
        }

        func requirePoi() -> LodPoi? {
            guard requireLayer() != nil else { return nil }
            guard let poi else {
                result(missingNativeResource(method: call.method, resource: "LOD POI", id: poiId))
                return nil
            }
            return poi
        }

        switch call.method {
        case "createLodLabelLayer": createLodLabelLayer(option: LodLabelLayerOptions(payload: arguments!), onSuccess: result)
        case "removeLodLabelLayer":
            guard requireLayer() != nil, let layerId else { return }
            removeLodLabelLayer(layerId: layerId, onSuccess: result)
        case "addLodPoi":
            guard let layer = requireLayer() else { return }
            let poiArgument = asDict(arguments!["poi"]!)
            let poiOption = PoiOptions(payload: poiArgument)
            let position = MapPoint(payload: poiArgument)
            let visible = asBool(arguments!["visible"] ?? true)
            addLodPoi(layer: layer, poi: poiOption, position: position, visible: visible, onSuccess: result)
        case "removeLodPoi":
            guard let layer = requireLayer(), requirePoi() != nil, let poiId else { return }
            removeLodPoi(layer: layer, poiId: poiId, onSuccess: result)
        case "changePoiVisible":
            guard let poi = requirePoi() else { return }
            let visible = asBool(arguments!["visible"]!)
            let autoMove = castSafty(arguments!["autoMove"], caster: asBool) ?? false
            changeLodPoiVisible(poi: poi, visible: visible, autoMove: autoMove, onSuccess: result)
        case "changePoiStyle":
            guard let poi = requirePoi() else { return }
            let styleId = asString(arguments!["styleId"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            changeLodPoiStyle(poi: poi, styleId: styleId, transition: transition, onSuccess: result)
        case "changePoiText":
            guard let poi = requirePoi() else { return }
            let text = asString(arguments!["text"]!)
            let transition = asBool(arguments!["transition"] ?? false)
            let styleId = asString(arguments!["styleId"]!)
            changeLodPoiText(poi: poi, styleId: styleId, text: text, transition: transition, onSuccess: result)
        case "rankPoi":
            guard let poi = requirePoi() else { return }
            let rank = asInt(arguments!["rank"]!)
            rankLodPoi(poi: poi, rank: rank, onSuccess: result)
        case "setLayerClickable":
            guard let layer = requireLayer() else { return }
            changeLodLabelLayerClickable(layer: layer, clickable: asBool(arguments!["clickable"]!), onSuccess: result)
        case "setLayerZOrder":
            guard let layer = requireLayer() else { return }
            changeLodLabelLayerZOrder(layer: layer, zOrder: asInt(arguments!["zOrder"]!), onSuccess: result)
        case "changeVisibleAllLodPoi":
            guard let layer = requireLayer() else { return }
            changeLodPoiAllVisible(layer: layer, visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "addPoiBadge":
            guard let poi = requirePoi() else { return }
            let badgeArgument = asDict(arguments!["badge"]!)
            let badgeOption = PoiBadge(payload: badgeArgument)
            let visible = asBool(badgeArgument["visible"] ?? true)
            addLodPoiBadge(poi: poi, badge: badgeOption, visible: visible, onSuccess: result)
        case "removePoiBadge":
            guard let poi = requirePoi() else { return }
            removeLodPoiBadge(poi: poi, badgeId: asString(arguments!["badgeId"]!), onSuccess: result)
        case "changePoiBadgeVisible":
            guard let poi = requirePoi() else { return }
            changeLodPoiBadgeVisible(
                poi: poi,
                badgeId: asString(arguments!["badgeId"]!),
                visible: asBool(arguments!["visible"]!),
                onSuccess: result
            )
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
