import KakaoMapsSDK
import Flutter

internal protocol ShapeControllerHandler {
    var shapeManager: ShapeManager { get };
    
    func createShapeLayer(layerId: String, zOrder: Int, passType: ShapeLayerPassType, onSuccess: (Any?) -> Void)

    func removeShapeLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPolygonShapeStyle(style: PolygonStyleSet, onSuccess: (String) -> Void)

    func addPolylineShapeStyle(style: PolylineStyleSet, onSuccess: (String) -> Void)

    func addMapPolygonShape(option: MapPolygonShapeOptions, onSuccess: (String) -> Void)

    func addMapPolylineShape(option: MapPolylineShapeOptions, onSuccess: (String) -> Void)

    func addPolygonShape(option: PolygonShapeOptions, onSuccess: (String) -> Void)

    func addPolylineShape(option: PolylineShapeOptions, onSuccess: (String) -> Void)
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
            let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
            let passType = castSafty(payload["passType"], caster: { ShapeLayerPassType(rawValue: asInt($0))! }) ?? ShapeLayerPassType.default
            createShapeLayer(layerId: layerId, zOrder: zOrder, passType: passType, onSuccess: result)
        case "removeShapeLayer": removeShapeLayer(layerId: layerId, onSuccess: result)
        case "addPolylineShapeStyle": addPolylineShapeStyle(PolylineStyleSet(payload: payload), onSuccess: result)
        case "addPolygonShapeStyle": addPolygonShapeStyle(PolygonStyleSet(payload: payload), onSuccess: result)
        case "addPolylineShape":
            let polyline = asDict(payload["polyline"]!)
            let position = asDict(polyline["position"]!)
            let positionType = asInt(position["type"]!)
            if (positionType == 0) {
                let option = MapPolylineShapeOptions(payload: polyline)
                addMapPolylineShape(option: option, onSuccess: result)
            } else if (positionType == 1) {
                let option = PolylineShapeOptions(payload: polyline)
                addPolylineShape(option: option, onSuccess: result)
            } else 
                result(FlutterMethodNotImplemented)
        case "addPolygonShape":
            let polygon = asDict(payload["polygon"]!)
            let position = asDict(polygon["position"]!)
            let positionType = asInt(position["type"]!)
            if (positionType == 0) {
                let option = MapPolygonShapeOptions(payload: polyline)
                addMapPolygonShape(option: option, onSuccess: result)
            } else if (positionType == 1) {
                let option = PolygonShapeOptions(payload: polyline)
                addPolygonShape(option: option, onSuccess: result)
            } else 
                result(FlutterMethodNotImplemented)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
