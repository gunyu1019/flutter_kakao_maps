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

        switch call.method {
        case "setColor":
            let color = UIColor(value: asUInt(arguments!["color"]!))
            setDimColor(color: color, onSuccess: result)
        case "setVisible": setDimVisible(visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "setDimCover": setDimCover(cover: DimScreenCover(rawValue: asInt(arguments!["cover"]!))!, onSuccess: result)
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
            if polygonShape == nil {
                removeDimHighlightPolygonShape(shapeId: polygonId!, onSuccess: result)
            } else {
                removeDimHighlightMapPolygonShape(shapeId: polygonId!, onSuccess: result)
            }
        case "changePolygonVisible":
            let visible = asBool(arguments!["visible"]!)
            changeShapeVisible(shape: shape!, visible: visible, onSuccess: result)
        case "changePolygon":
            let styleId = asString(arguments!["styleId"]!)
            let rawPosition = asDict(arguments!["position"]!)
            let positionType = asInt(rawPosition["type"]!)
            if positionType == 0 {
                let points = asArray(rawPosition["points"]!, caster: { MapPoint(payload: asDict($0)) })
                let holes = castSafty(rawPosition["holes"], caster: {
                    asArray($0, caster: {
                        asArray($0, caster: asDict).map {
                            MapPoint(payload: $0)
                        }
                    })
                })
                let position = MapPolygon(exteriorRing: points, holes: holes, styleIndex: 0)
                changeMapPolygonShape(shape: mapPolygonShape!, styleId: styleId, position: [position], onSuccess: result)
            } else if positionType == 1 {
                let points = asDotPoints(payload: rawPosition)
                let holes = castSafty(rawPosition["holes"], caster: {
                    asArray($0, caster: {
                        asDotPoints(payload: asDict($0))!
                    })
                })
                let position = Polygon(exteriorRing: points!, holes: holes, styleIndex: 0)
                changePolygonShape(shape: polygonShape!, styleId: styleId, position: [position], onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        default: result(FlutterMethodNotImplemented)
        }
    }
}
