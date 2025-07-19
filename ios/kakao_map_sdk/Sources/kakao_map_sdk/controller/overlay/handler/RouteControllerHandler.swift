import Flutter
import KakaoMapsSDK

protocol RouteControllerHandler {
    var routeManager: RouteManager { get }

    func createRouteLayer(layerId: String, zOrder: Int, onSuccess: (Any?) -> Void)

    func removeRouteLayer(layerId: String, onSuccess: (Any?) -> Void)

    func addRouteStyle(style: RouteStyleSet, onSuccess: (String) -> Void)

    func addRoute(layer: RouteLayer, route: RouteOptions, onSuccess: (String) -> Void)

    func removeRoute(layer: RouteLayer, routeId: String, onSuccess: (Any?) -> Void)

    func changeRoute(route: Route, styleId: String, points: [RouteSegment], onSuccess: (Any?) -> Void)

    func changeRouteVisible(route: Route, visible: Bool, onSuccess: (Any?) -> Void)

    func changeRouteZOrder(route: Route, zOrder: Int, onSuccess: (Any?) -> Void)

    func changeRouteLayerVisible(layer: RouteLayer, visible: Bool, onSuccess: (Any?) -> Void)
}

extension RouteControllerHandler {
    func routeHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)
        let layerId: String? = castSafty(arguments?["layerId"], caster: asString)
        let layer: RouteLayer? = layerId.flatMap { key in
            routeManager.getRouteLayer(layerID: key)
        }

        let routeId = castSafty(arguments?["routeId"], caster: asString)
        let route: Route? = routeId.flatMap { key in
            layer!.getRoute(routeID: key)
        }

        switch call.method {
        case "createRouteLayer":
            let zOrder = castSafty(arguments?["zOrder"], caster: asInt) ?? 10000
            createRouteLayer(layerId: layerId!, zOrder: zOrder, onSuccess: result)
        case "removeRouteLayer": removeRouteLayer(layerId: layerId!, onSuccess: result)
        case "addRouteStyle": addRouteStyle(style: RouteStyleSet(payload: arguments!), onSuccess: result)
        case "addRoute": addRoute(layer: layer!, route: asRouteOption(payload: asDict(arguments!["route"]!)), onSuccess: result)
        case "addMultipleRoute": addRoute(layer: layer!, route: asRouteMultipleOption(payload: asDict(arguments!["route"]!)), onSuccess: result)
        case "remvoeRoute": removeRoute(layer: layer!, routeId: routeId!, onSuccess: result)
        case "changeRoute":
            let styleId = asString(arguments!["styleId"]!)
            let curveType = asArray(arguments!["curveType"]!, caster: asInt)
            let points = asArray(arguments!["points"]!, caster: { asArray($0, caster: asDict) })
            let segments = points.enumerated().map { index, payload -> RouteSegment in
                return RouteSegment(payload: [
                    "curveType": curveType[index],
                    "points": payload,
                ])
            }
            changeRoute(route: route!, styleId: styleId, points: segments, onSuccess: result)
        case "changeRouteVisible":
            let visible = asBool(arguments!["visible"]!)
            changeRouteVisible(route: route!, visible: visible, onSuccess: result)
        case "changeRouteZOrder":
            let zOrder = asInt(arguments!["zOrder"]!)
            changeRouteZOrder(route: route!, zOrder: zOrder, onSuccess: result)
        case "changeVisibleAllRoute": changeRouteLayerVisible(layer: layer!, visible: asBool(arguments!["visible"]!), onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
