import Flutter
import KakaoMapsSDK

protocol RouteControllerHandler {
    var routeManager: RouteManager { get }

    func createShapeLayer(layerId: String, zOrder: Int, onSuccess: (Any?) -> Void)

    func removeShapeLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addRouteStyle(style: RouteStyleSet, onSuccess: (String) -> Void)

    func addRoute(layer: RouteLayer, route: RouteOptions, onSuccess: (String) -> Void)

    func removeRoute(layer: RouteLayer, routeId: String, onSuccess: (Any?) -> Void)

    func changeRoute(route: Route, styleId: String, points: List<RouteSegment>, onSuccess: (Any?) -> Void)

    func changeRouteVisible(route: Route, visible: Bool, onSuccess: (Any?) -> Void)

    func changeRouteZOrder(route: Route, zOrder: Int, onSuccess: (Any?) -> Void)
}

extension RouteControllerHandler {
    func routeHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)
        let layerId: String? = castSafty(arguments?["layerId"], caster: asString)
        let layer: RouteLayer? = layerId.flatMap { key in
            routeManager.getRouteLayer(layerID: key)
        }

        let routeId = castSafty(arguments?["routeId"], caster: asString)
        let route: Route? = poiId.flatMap { key in
            layer!.getRouteLayer(routeID: key)
        }

        switch call.method {
        default: result(FlutterMethodNotImplemented)
        }
    }
}
