import KakaoMapsSDK
import Flutter

internal protocol ShapeControllerHandler {
    var shapeManager: ShapeManager { get };
    
    func createShapeLayer(layerId: String, zOrder: Int, passType: ShapeLayerPassType, onSuccess: (Any?) -> Void)

    func removeShapeLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPolygonShapeStyle(style: PolygonStyleSet, onSuccess: (String) -> Void)

    func addPolylineShapeStyle(style: PolylineStyleSet, onSuccess: (String) -> Void)

    func addMapPolygonShape(layer: ShapeLayer, option: MapPolygonShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func addMapPolylineShape(layer: ShapeLayer, option: MapPolylineShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func addPolygonShape(layer: ShapeLayer, option: PolygonShapeOptions, visible: Bool, onSuccess: (String) -> Void)

    func addPolylineShape(layer: ShapeLayer, option: PolylineShapeOptions, visible: Bool, onSuccess: (String) -> Void)
}

internal extension ShapeControllerHandler {
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
        let shape = mapPolylineShape ?? mapPolygonShape ?? polylineShape ?? polygonShape

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
            if (positionType == 0) {
                let option = MapPolylineShapeOptions(payload: polyline)
                addMapPolylineShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else if (positionType == 1) {
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
            if (positionType == 0) {
                let option = MapPolygonShapeOptions(payload: polygon)
                addMapPolygonShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else if (positionType == 1) {
                let option = PolygonShapeOptions(payload: polygon)
                addPolygonShape(layer: layer!, option: option, visible: visible, onSuccess: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        default: result(FlutterMethodNotImplemented)
        }
    }
}
