import KakaoMapsSDK
import Flutter

internal protocol ShapeControllerHandler {
    var shapeManager: ShapeManager { get };
    
    func createShapeLabelLayer(layerId: String, zOrder: Int, passType: ShapeLayerPassType, onSuccess: (Any?) -> Void)

    func removeShapeLabelLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addPolygonStyle(style: PolygonStyleSet, onSuccess: (String) -> Void)

    func addPolylineStyle(style: PolylineStyleSet, onSuccess: (String) -> Void)

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
        default: result(FlutterMethodNotImplemented)
        }
    }
}
