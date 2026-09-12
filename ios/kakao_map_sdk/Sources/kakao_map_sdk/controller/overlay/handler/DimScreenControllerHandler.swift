import Flutter
import KakaoMapsSDK

protocol DimScreenControllerHandler {
    var dimScreenManager: DimScreen { get }

    func setDimColor(color: UIColor, onSuccess: (Any?) -> Void)

    func setDimVisible(visible: Bool, onSuccess: (Any?) -> Void)

    func setDimCover(cover: DimScreenCover, onSuccess: (Any?) -> Void)

    func addDimHighlightPolygonShape(option: PolygonShapeOptions, visible: Bool, onSuccess: (String?) -> Void)

    func addDimHighlightMapPolygonShape(option: MapPolygonShapeOptions, visible: Bool, onSuccess: (String?) -> Void)

    func removeDimHighlightPolygonShape(shapeId: String, onSuccess: (Any?) -> Void)

    func removeDimHighlightMapPolygonShape(shapeId: String, onSuccess: (Any?) -> Void)

    func changeShapeVisible(shape: Shape, visible: Bool, onSuccess: (Any?) -> Void)

    func changeMapPolygonShape(shape: MapPolygonShape, styleId: String, position: [MapPolygon], onSuccess: (Any?) -> Void)

    func changePolygonShape(shape: PolygonShape, styleId: String, position: [Polygon], onSuccess: (Any?) -> Void)
}

extension DimScreenControllerHandler {
    func dimScreenHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)

        let polygonId = castSafty(arguments?["polygonId"], caster: asString)
        let mapPolygonShape: MapPolygonShape? = polygonId.flatMap { key in
            dimScreenManager.getHighlightMapPolygonShape(shapeID: key)
        }
        let polygonShape: PolygonShape? = polygonId.flatMap { key in
            dimScreenManager.getHighlightPolygonShape(shapeID: key)
        }
        let shape: Shape? = mapPolygonShape ?? polygonShape

        func requirePolygon() -> Shape? {
            guard let shape else {
                result(missingNativeResource(method: call.method, resource: "dim-screen polygon", id: polygonId))
                return nil
            }
            return shape
        }

        switch call.method {
        case "setColor":
            let color = UIColor(value: asUInt(arguments!["color"]!))
            setDimColor(color: color, onSuccess: result)
        case "setVisible": setDimVisible(visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "setDimCover":
            let coverValue = asInt(arguments!["cover"]!)
            guard let cover = DimScreenCover(rawValue: coverValue) else {
                result(FlutterError(
                    code: "INVALID_DIM_SCREEN_COVER",
                    message: "Unknown DimScreenCover raw value: \(coverValue)",
                    details: nil
                ))
                return
            }
            setDimCover(cover: cover, onSuccess: result)
        case "addHighlightPolygonShape":
            let polygon = asDict(arguments!["polygon"]!)
            let position = asDict(polygon["position"]!)
            let positionType = asInt(position["type"]!)
            let visible = asBool(arguments!["visible"] ?? true)
            if positionType == 0 {
                let option = MapPolygonShapeOptions(payload: polygon)
                addDimHighlightMapPolygonShape(option: option, visible: visible, onSuccess: result)
            } else if positionType == 1 {
                let option = PolygonShapeOptions(payload: polygon)
                addDimHighlightPolygonShape(option: option, visible: visible, onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "removeHighlightPolygonShape":
            guard requirePolygon() != nil, let id = polygonId else { return }
            if mapPolygonShape != nil {
                removeDimHighlightMapPolygonShape(shapeId: id, onSuccess: result)
            } else {
                removeDimHighlightPolygonShape(shapeId: id, onSuccess: result)
            }
        case "changePolygonVisible":
            guard let shape = requirePolygon() else { return }
            let visible = asBool(arguments!["visible"]!)
            changeShapeVisible(shape: shape, visible: visible, onSuccess: result)
        case "changePolygon":
            let styleId = asString(arguments!["styleId"]!)
            let rawPosition = asDict(arguments!["position"]!)
            let positionType = asInt(rawPosition["type"]!)
            if positionType == 0 {
                guard let mapPolygonShape else {
                    result(missingNativeResource(method: call.method, resource: "dim-screen map polygon", id: polygonId))
                    return
                }
                let position = MapPolygon(payload: rawPosition)
                changeMapPolygonShape(shape: mapPolygonShape, styleId: styleId, position: [position], onSuccess: result)
            } else if positionType == 1 {
                guard let polygonShape else {
                    result(missingNativeResource(method: call.method, resource: "dim-screen relative polygon", id: polygonId))
                    return
                }
                let position = Polygon(payload: rawPosition)
                changePolygonShape(shape: polygonShape, styleId: styleId, position: [position], onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        default: result(FlutterMethodNotImplemented)
        }
    }
}
