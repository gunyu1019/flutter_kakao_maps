import Flutter
import KakaoMapsSDK

protocol ShapeControllerHandler {
    var shapeManager: ShapeManager { get }

    func createShapeLayer(layerId: String, zOrder: Int, passType: ShapeLayerPassType, onSuccess: (Any?) -> Void)

    func removeShapeLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPolygonShapeStyle(style: PolygonStyleSet, onSuccess: (String) -> Void)

    func addPolylineShapeStyle(style: PolylineStyleSet, onSuccess: (String) -> Void)

    func addMapPolygonShape(layer: ShapeLayer, option: MapPolygonShapeOptions, visible: Bool, onSuccess: (String?) -> Void)

    func addMapPolylineShape(layer: ShapeLayer, option: MapPolylineShapeOptions, visible: Bool, onSuccess: (String?) -> Void)

    func addPolygonShape(layer: ShapeLayer, option: PolygonShapeOptions, visible: Bool, onSuccess: (String?) -> Void)

    func addPolylineShape(layer: ShapeLayer, option: PolylineShapeOptions, visible: Bool, onSuccess: (String?) -> Void)

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
            layer?.getMapPolylineShape(shapeID: key)
        }
        let polylineShape: PolylineShape? = polylineId.flatMap { key in
            layer?.getPolylineShape(shapeID: key)
        }

        let mapPolygonShape: MapPolygonShape? = polygonId.flatMap { key in
            layer?.getMapPolygonShape(shapeID: key)
        }
        let polygonShape: PolygonShape? = polygonId.flatMap { key in
            layer?.getPolygonShape(shapeID: key)
        }
        func requireLayer() -> ShapeLayer? {
            guard let layer else {
                result(missingNativeResource(method: call.method, resource: "shape layer", id: layerId))
                return nil
            }
            return layer
        }

        func requirePolyline() -> Shape? {
            guard requireLayer() != nil else { return nil }
            let shape: Shape? = mapPolylineShape ?? polylineShape
            guard let shape else {
                result(missingNativeResource(method: call.method, resource: "polyline", id: polylineId))
                return nil
            }
            return shape
        }

        func requirePolygon() -> Shape? {
            guard requireLayer() != nil else { return nil }
            let shape: Shape? = mapPolygonShape ?? polygonShape
            guard let shape else {
                result(missingNativeResource(method: call.method, resource: "polygon", id: polygonId))
                return nil
            }
            return shape
        }

        switch call.method {
        case "createShapeLayer":
            let zOrder = castSafty(arguments?["zOrder"], caster: asInt) ?? 10001
            let passType = castSafty(arguments?["passType"], caster: { ShapeLayerPassType(rawValue: asInt($0))! }) ?? .default
            createShapeLayer(layerId: layerId!, zOrder: zOrder, passType: passType, onSuccess: result)
        case "removeShapeLayer":
            guard requireLayer() != nil, let layerId else { return }
            removeShapeLayer(layerId: layerId, onSuccess: result)
        case "addPolylineShapeStyle": addPolylineShapeStyle(style: PolylineStyleSet(payload: arguments!), onSuccess: result)
        case "addPolygonShapeStyle": addPolygonShapeStyle(style: PolygonStyleSet(payload: arguments!), onSuccess: result)
        case "addPolylineShape":
            guard let layer = requireLayer() else { return }
            let polyline = asDict(arguments!["polyline"]!)
            let position = asDict(polyline["position"]!)
            let positionType = asInt(position["type"]!)
            let visible = asBool(arguments!["visible"] ?? true)
            if positionType == 0 {
                let option = MapPolylineShapeOptions(payload: polyline)
                addMapPolylineShape(layer: layer, option: option, visible: visible, onSuccess: result)
            } else if positionType == 1 {
                let option = PolylineShapeOptions(payload: polyline)
                addPolylineShape(layer: layer, option: option, visible: visible, onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "addPolygonShape":
            guard let layer = requireLayer() else { return }
            let polygon = asDict(arguments!["polygon"]!)
            let position = asDict(polygon["position"]!)
            let positionType = asInt(position["type"]!)
            let visible = asBool(arguments!["visible"] ?? true)
            if positionType == 0 {
                let option = MapPolygonShapeOptions(payload: polygon)
                addMapPolygonShape(layer: layer, option: option, visible: visible, onSuccess: result)
            } else if positionType == 1 {
                let option = PolygonShapeOptions(payload: polygon)
                addPolygonShape(layer: layer, option: option, visible: visible, onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "removePolylineShape":
            guard let layer = requireLayer(), requirePolyline() != nil, let polylineId else { return }
            if polylineShape == nil {
                removeMapPolylineShape(layer: layer, shapeId: polylineId, onSuccess: result)
            } else {
                removePolylineShape(layer: layer, shapeId: polylineId, onSuccess: result)
            }
        case "removePolygonShape":
            guard let layer = requireLayer(), requirePolygon() != nil, let polygonId else { return }
            if polygonShape == nil {
                removeMapPolygonShape(layer: layer, shapeId: polygonId, onSuccess: result)
            } else {
                removePolygonShape(layer: layer, shapeId: polygonId, onSuccess: result)
            }
        case "changePolylineVisible":
            guard let shape = requirePolyline() else { return }
            let visible = asBool(arguments!["visible"]!)
            changeShapeVisible(shape: shape, visible: visible, onSuccess: result)
        case "changePolygonVisible":
            guard let shape = requirePolygon() else { return }
            let visible = asBool(arguments!["visible"]!)
            changeShapeVisible(shape: shape, visible: visible, onSuccess: result)
        case "changePolyline":
            guard requireLayer() != nil else { return }
            let styleId = asString(arguments!["styleId"]!)
            let rawPosition = asDict(arguments!["position"]!)
            let positionType = asInt(rawPosition["type"]!)
            if positionType == 0 {
                guard let mapPolylineShape else {
                    result(missingNativeResource(method: call.method, resource: "map polyline", id: polylineId))
                    return
                }
                let points = asArray(rawPosition["points"]!, caster: { MapPoint(payload: asDict($0)) })
                let position = MapPolyline(line: points, styleIndex: 0)
                changeMapPolylineShape(shape: mapPolylineShape, styleId: styleId, position: [position], onSuccess: result)
            } else if positionType == 1 {
                guard let polylineShape else {
                    result(missingNativeResource(method: call.method, resource: "relative polyline", id: polylineId))
                    return
                }
                let points = asDotPoints(payload: rawPosition)
                let position = Polyline(line: points!, styleIndex: 0)
                changePolylineShape(shape: polylineShape, styleId: styleId, position: [position], onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "changePolygon":
            guard requireLayer() != nil else { return }
            let styleId = asString(arguments!["styleId"]!)
            let rawPosition = asDict(arguments!["position"]!)
            let positionType = asInt(rawPosition["type"]!)
            if positionType == 0 {
                guard let mapPolygonShape else {
                    result(missingNativeResource(method: call.method, resource: "map polygon", id: polygonId))
                    return
                }
                let position = MapPolygon(payload: rawPosition)
                changeMapPolygonShape(shape: mapPolygonShape, styleId: styleId, position: [position], onSuccess: result)
            } else if positionType == 1 {
                guard let polygonShape else {
                    result(missingNativeResource(method: call.method, resource: "relative polygon", id: polygonId))
                    return
                }
                let position = Polygon(payload: rawPosition)
                changePolygonShape(shape: polygonShape, styleId: styleId, position: [position], onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "changeVisibleAllPolyline":
            guard let layer = requireLayer() else { return }
            changePolylineAllVisible(layer: layer, visible: asBool(arguments!["visible"]!), onSuccess: result)
        case "changeVisibleAllPolygon":
            guard let layer = requireLayer() else { return }
            changePolygonAllVisible(layer: layer, visible: asBool(arguments!["visible"]!), onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
