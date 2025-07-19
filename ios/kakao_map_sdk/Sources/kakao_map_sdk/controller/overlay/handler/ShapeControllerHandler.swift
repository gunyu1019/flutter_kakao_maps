import Flutter
import KakaoMapsSDK

protocol ShapeControllerHandler {
    var shapeManager: ShapeManager { get }

    func createShapeLayer(layerId: String, zOrder: Int, passType: ShapeLayerPassType, onSuccess: (Any?) -> Void)

    func removeShapeLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPolygonShapeStyle(style: PolygonStyleSet, onSuccess: (String) -> Void)

    func addPolylineShapeStyle(style: PolylineStyleSet, onSuccess: (String) -> Void)

    func addMapPolygonShape(layer: ShapeLayer, option: MapPolygonShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func addMapPolylineShape(layer: ShapeLayer, option: MapPolylineShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func addPolygonShape(layer: ShapeLayer, option: PolygonShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func addPolylineShape(layer: ShapeLayer, option: PolylineShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func removeMapPolygonShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void)

    func removeMapPolylineShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void)

    func removePolygonShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void)

    func removePolylineShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void)

    func changeShapeVisible(shape: Shape, visible: Bool, onSuccess: (Any?) -> Void)

    func changeMapPolygonShape(shape: MapPolygonShape, styleId: String, position: [MapPolygon], onSuccess: (Any?) -> Void)

    func changeMapPolylineShape(shape: MapPolylineShape, styleId: String, position: [MapPolyline], onSuccess: (Any?) -> Void)

    func changePolygonShape(shape: PolygonShape, styleId: String, position: [Polygon], onSuccess: (Any?) -> Void)

    func changePolylineShape(shape: PolylineShape, styleId: String, position: [Polyline], onSuccess: (Any?) -> Void)

    func changePolylineAllVisible(layer: ShapeLayer, visible: Bool, onSuccess: (Any?) -> Void)

    func changePolygonAllVisible(layer: ShapeLayer, visible: Bool, onSuccess: (Any?) -> Void)
}

extension ShapeControllerHandler {
    func shapeHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)
        let layerId: String? = castSafty(arguments?["layerId"], caster: asString)
        let layer: ShapeLayer? = layerId.flatMap { key in
            shapeManager.getShapeLayer(layerID: key)
        }

        let polylineId = castSafty(arguments?["polylineId"], caster: asString)
        let polygonId = castSafty(arguments?["polygonId"], caster: asString)

        let mapPolylineShape: MapPolylineShape? = polylineId.flatMap { key in
            layer!.getMapPolylineShape(shapeID: key)
        }
        let polylineShape: PolylineShape? = polylineId.flatMap { key in
            layer!.getPolylineShape(shapeID: key)
        }

        let mapPolygonShape: MapPolygonShape? = polygonId.flatMap { key in
            layer!.getMapPolygonShape(shapeID: key)
        }
        let polygonShape: PolygonShape? = polygonId.flatMap { key in
            layer!.getPolygonShape(shapeID: key)
        }
        let shape: Shape? = mapPolylineShape ?? mapPolygonShape ?? polylineShape ?? polygonShape

        switch call.method {
        case "createShapeLayer":
            let zOrder = castSafty(arguments?["zOrder"], caster: asInt) ?? 10001
            let passType = castSafty(arguments?["passType"], caster: { ShapeLayerPassType(rawValue: asInt($0))! }) ?? .default
            createShapeLayer(layerId: layerId!, zOrder: zOrder, passType: passType, onSuccess: result)
        case "removeShapeLayer": removeShapeLayer(layerId: layerId!, onSuccess: result)
        case "addPolylineShapeStyle": addPolylineShapeStyle(style: PolylineStyleSet(payload: arguments!), onSuccess: result)
        case "addPolygonShapeStyle": addPolygonShapeStyle(style: PolygonStyleSet(payload: arguments!), onSuccess: result)
        case "addPolylineShape":
            let polyline = asDict(arguments!["polyline"]!)
            let position = asDict(polyline["position"]!)
            let positionType = asInt(position["type"]!)
            let visible = asBool(arguments!["visible"] ?? true)
            if positionType == 0 {
                let option = MapPolylineShapeOptions(payload: polyline)
                addMapPolylineShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else if positionType == 1 {
                let option = PolylineShapeOptions(payload: polyline)
                addPolylineShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "addPolygonShape":
            let polygon = asDict(arguments!["polygon"]!)
            let position = asDict(polygon["position"]!)
            let positionType = asInt(position["type"]!)
            let visible = asBool(arguments!["visible"] ?? true)
            if positionType == 0 {
                let option = MapPolygonShapeOptions(payload: polygon)
                addMapPolygonShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else if positionType == 1 {
                let option = PolygonShapeOptions(payload: polygon)
                addPolygonShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "removePolylineShape":
            if polylineShape == nil {
                removePolylineShape(layer: layer!, shapeId: polylineId!, onSuccess: result)
            } else {
                removeMapPolylineShape(layer: layer!, shapeId: polylineId!, onSuccess: result)
            }
        case "removePolygonShape":
            if polygonShape == nil {
                removePolygonShape(layer: layer!, shapeId: polygonId!, onSuccess: result)
            } else {
                removeMapPolygonShape(layer: layer!, shapeId: polygonId!, onSuccess: result)
            }
        case "changePolylineVisible":
            let visible = asBool(arguments!["visible"]!)
            changeShapeVisible(shape: shape!, visible: visible, onSuccess: result)
        case "changePolygonVisible":
            let visible = asBool(arguments!["visible"]!)
            changeShapeVisible(shape: shape!, visible: visible, onSuccess: result)
        case "changePolyline":
            let styleId = asString(arguments!["styleId"]!)
            let rawPosition = asDict(arguments!["position"]!)
            let positionType = asInt(rawPosition["type"]!)
            if positionType == 0 {
                let points = asArray(rawPosition["points"]!, caster: { MapPoint(payload: asDict($0)) })
                let position = MapPolyline(line: points, styleIndex: 0)
                changeMapPolylineShape(shape: mapPolylineShape!, styleId: styleId, position: [position], onSuccess: result)
            } else if positionType == 1 {
                let points = asDotPoints(payload: rawPosition)
                let position = Polyline(line: points!, styleIndex: 0)
                changePolylineShape(shape: polylineShape!, styleId: styleId, position: [position], onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
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
        case "changeVisibleAllPolyline": changePolylineAllVisible(layer: layer!, visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "changeVisibleAllPolygon":
            changePolygonAllVisible(layer: layer!, visible: asBool(arguments!["visible"]!), onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
