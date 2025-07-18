import Flutter
import KakaoMapsSDK

class OverlayController: LabelControllerHandler, LodLabelControllerHandler, ShapeControllerHandler, RouteControllerHandler {
    private let channel: FlutterMethodChannel
    private let kakaoMap: KakaoMap

    let labelManager: LabelManager
    let shapeManager: ShapeManager
    let routeManager: RouteManager

    let labelListener: PoiClickListener

    init(channel: FlutterMethodChannel, kakaoMap: KakaoMap, labelListener: PoiClickListener) {
        self.channel = channel
        self.kakaoMap = kakaoMap
        self.labelListener = labelListener

        labelManager = kakaoMap.getLabelManager()
        shapeManager = kakaoMap.getShapeManager()
        routeManager = kakaoMap.getRouteManager()

        setupInitLayer()
        channel.setMethodCallHandler(handle)
    }

    func setupInitLayer() {
        labelManager.addLabelLayer(
            option: LabelLayerOptions(
                layerID: "label_default_layer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 10001
            )
        )
        labelManager.addLodLabelLayer(
            option: LodLabelLayerOptions(
                layerID: "lodLabel_default_layer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 10001,
                radius: 20.0
            )
        )
        shapeManager.addShapeLayer(
            layerID: "vector_layer_0",
            zOrder: 10001
        )
        routeManager.addRouteLayer(
            layerID: "route_layer_0",
            zOrder: 10000
        )
    }

    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = asDict(call.arguments!)
        let overlayType = OverlayType(rawValue: asInt(arguments["type"]!))
        switch overlayType {
        case .label: labelHandle(call: call, result: result)
        case .lodLabel: lodLabelHandle(call: call, result: result)
        case .shape: shapeHandle(call: call, result: result)
        case .route: routeHandle(call: call, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    func createLabelLayer(option: LabelLayerOptions, onSuccess: (Any?) -> Void) {
        labelManager.addLabelLayer(option: option)
        onSuccess(nil)
    }

    func removeLabelLayer(layerId: String, onSuccess: (Any?) -> Void) {
        labelManager.removeLabelLayer(layerID: layerId)
        onSuccess(nil)
    }

    func addPoiStyle(style: PoiStyle, onSuccess: (String) -> Void) {
        labelManager.addPoiStyle(style)
        onSuccess(style.styleID)
    }

    func addPoi(layer: LabelLayer, poi: PoiOptions, position: MapPoint, visible: Bool, onSuccess: @escaping (String) -> Void) {
        let poiInstance = layer.addPoi(option: poi, at: position)
        if visible && !(poiInstance?.isShow ?? false) {
            poiInstance?.show()
        }
        poiInstance?.addPoiTappedEventHandler(target: labelListener, handler: PoiClickListener.onPoiInteractionEvent)
        onSuccess(poiInstance!.itemID)
    }

    func removePoi(layer: LabelLayer, poiId: String, onSuccess: (Any?) -> Void) {
        layer.removePoi(poiID: poiId)
        onSuccess(nil)
    }

    func addPolylineText(layer: LabelLayer, label: WaveTextOptions, visible: Bool, onSuccess: (String) -> Void) {
        let waveTextInstance = layer.addWaveText(label)
        if visible && !(waveTextInstance?.isShow ?? false) {
            waveTextInstance?.show()
        }
        onSuccess(waveTextInstance!.itemID)
    }

    func removePolylineText(layer: LabelLayer, labelId: String, onSuccess: (Any?) -> Void) {
        layer.removeWaveText(waveTextID: labelId)
        onSuccess(nil)
    }

    func changePoiPixelOffset(poi: Poi, offset: CGPoint, onSuccess: (Any?) -> Void) {
        poi.pixelOffset = offset
        onSuccess(nil)
    }

    func changePoiVisible(poi: Poi, visible: Bool, autoMove: Bool, onSuccess: (Any?) -> Void) {
        if visible && autoMove {
            poi.showWithAutoMove()
        } else if visible {
            poi.show()
        } else {
            poi.hide()
        }
        onSuccess(nil)
    }

    func changePoiStyle(poi: Poi, styleId: String, transition: Bool, onSuccess: (Any?) -> Void) {
        poi.changeStyle(styleID: styleId, enableTransition: transition)
        onSuccess(nil)
    }

    func changePoiText(poi: Poi, styleId: String, text: String, transition: Bool, onSuccess: (Any?) -> Void) {
        let poiText = asString(text).components(separatedBy: "\n").enumerated().map {
            index, element in PoiText(text: element, styleIndex: UInt(index))
        }
        poi.changeTextAndStyle(texts: poiText, styleID: styleId, enableTransition: transition)
        onSuccess(nil)
    }

    func invalidatePoi(
        poi: Poi,
        styleId: String,
        text: String,
        transition: Bool,
        onSuccess: (Any?) -> Void
    ) {
        let poiText = asString(text).components(separatedBy: "\n").enumerated().map {
            index, element in PoiText(text: element, styleIndex: UInt(index))
        }
        poi.changeTextAndStyle(texts: poiText, styleID: styleId, enableTransition: transition)
        onSuccess(nil)
    }

    func movePoi(poi: Poi, position: MapPoint, duration: UInt?, onSuccess: (Any?) -> Void) {
        if duration == nil || duration is NSNull {
            poi.position = position
        } else {
            poi.moveAt(position, duration: duration!)
        }
        onSuccess(nil)
    }

    func rotatePoi(poi: Poi, angle: Double, duration: UInt?, onSuccess: (Any?) -> Void) {
        if duration == nil || duration is NSNull {
            poi.orientation = angle
        } else {
            poi.rotateAt(angle, duration: duration!)
        }
        onSuccess(nil)
    }

    func rankPoi(poi: Poi, rank: Int, onSuccess: (Any?) -> Void) {
        poi.rank = rank
        onSuccess(nil)
    }

    func createLodLabelLayer(option: LodLabelLayerOptions, onSuccess: (Any?) -> Void) {
        labelManager.addLodLabelLayer(option: option)
        onSuccess(nil)
    }

    func removeLodLabelLayer(layerId: String, onSuccess: (Any?) -> Void) {
        labelManager.removeLodLabelLayer(layerID: layerId)
        onSuccess(nil)
    }

    func addLodPoi(layer: LodLabelLayer, poi: PoiOptions, position: MapPoint, visible: Bool, onSuccess: @escaping (String) -> Void) {
        let poiInstance = layer.addLodPoi(option: poi, at: position)
        if visible && !(poiInstance?.isShow ?? false) {
            poiInstance?.show()
        }
        poiInstance?.addPoiTappedEventHandler(target: labelListener, handler: PoiClickListener.onLodPoiInteractionEvent)
        onSuccess(poiInstance!.itemID)
    }

    func removeLodPoi(layer: LodLabelLayer, poiId: String, onSuccess: (Any?) -> Void) {
        layer.removeLodPoi(poiID: poiId)
        onSuccess(nil)
    }

    func changeLodPoiVisible(poi: LodPoi, visible: Bool, autoMove: Bool, onSuccess: (Any?) -> Void) {
        if visible && autoMove {
            poi.showWithAutoMove()
        } else if visible {
            poi.show()
        } else {
            poi.hide()
        }
        onSuccess(nil)
    }

    func changeLodPoiStyle(poi: LodPoi, styleId: String, transition: Bool, onSuccess: (Any?) -> Void) {
        poi.changeStyle(styleID: styleId, enableTransition: transition)
        onSuccess(nil)
    }

    func changeLodPoiText(poi: LodPoi, styleId: String, text: String, transition: Bool, onSuccess: (Any?) -> Void) {
        let poiText = asString(text).components(separatedBy: "\n").enumerated().map {
            index, element in PoiText(text: element, styleIndex: UInt(index))
        }
        poi.changeTextAndStyle(texts: poiText, styleID: styleId, enableTransition: transition)
        onSuccess(nil)
    }

    func rankLodPoi(poi: LodPoi, rank: Int, onSuccess: (Any?) -> Void) {
        poi.rank = rank
        onSuccess(nil)
    }

    func createShapeLayer(layerId: String, zOrder: Int, passType: ShapeLayerPassType, onSuccess: (Any?) -> Void) {
        shapeManager.addShapeLayer(layerID: layerId, zOrder: zOrder, passType: passType)
        onSuccess(nil)
    }

    func removeShapeLayer(layerId: String, onSuccess: (Any?) -> Void) {
        shapeManager.removeShapeLayer(layerID: layerId)
        onSuccess(nil)
    }

    func addPolygonShapeStyle(style: PolygonStyleSet, onSuccess: (String) -> Void) {
        shapeManager.addPolygonStyleSet(style)
        onSuccess(style.styleSetID)
    }

    func addPolylineShapeStyle(style: PolylineStyleSet, onSuccess: (String) -> Void) {
        shapeManager.addPolylineStyleSet(style)
        onSuccess(style.styleSetID)
    }

    func addMapPolygonShape(layer: ShapeLayer, option: MapPolygonShapeOptions, visible: Bool, onSuccess: (String) -> Void) {
        let shapeInstance = layer.addMapPolygonShape(option)
        if visible && !(shapeInstance?.isShow ?? false) {
            shapeInstance?.show()
        }
        onSuccess(shapeInstance!.shapeID)
    }

    func addMapPolylineShape(layer: ShapeLayer, option: MapPolylineShapeOptions, visible: Bool, onSuccess: (String) -> Void) {
        let shapeInstance = layer.addMapPolylineShape(option)
        if visible && !(shapeInstance?.isShow ?? false) {
            shapeInstance?.show()
        }
        onSuccess(shapeInstance!.shapeID)
    }

    func addPolygonShape(layer: ShapeLayer, option: PolygonShapeOptions, visible: Bool, onSuccess: (String) -> Void) {
        let shapeInstance = layer.addPolygonShape(option)
        if visible && !(shapeInstance?.isShow ?? false) {
            shapeInstance?.show()
        }
        onSuccess(shapeInstance!.shapeID)
    }

    func addPolylineShape(layer: ShapeLayer, option: PolylineShapeOptions, visible: Bool, onSuccess: (String) -> Void) {
        let shapeInstance = layer.addPolylineShape(option)
        if visible && !(shapeInstance?.isShow ?? false) {
            shapeInstance?.show()
        }
        onSuccess(shapeInstance!.shapeID)
    }

    func removeMapPolygonShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void) {
        layer.removeMapPolygonShape(shapeID: shapeId)
        onSuccess(nil)
    }

    func removeMapPolylineShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void) {
        layer.removeMapPolylineShape(shapeID: shapeId)
        onSuccess(nil)
    }

    func removePolygonShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void) {
        layer.removePolygonShape(shapeID: shapeId)
        onSuccess(nil)
    }

    func removePolylineShape(layer: ShapeLayer, shapeId: String, onSuccess: (Any?) -> Void) {
        layer.removePolylineShape(shapeID: shapeId)
        onSuccess(nil)
    }

    func changeShapeVisible(shape: Shape, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            shape.show()
        } else {
            shape.hide()
        }
        onSuccess(nil)
    }

    func changeMapPolygonShape(shape: MapPolygonShape, styleId: String, position: [MapPolygon], onSuccess: (Any?) -> Void) {
        shape.changeStyleAndData(styleID: styleId, polygons: position)
        onSuccess(nil)
    }

    func changeMapPolylineShape(shape: MapPolylineShape, styleId: String, position: [MapPolyline], onSuccess: (Any?) -> Void) {
        shape.changeStyleAndData(styleID: styleId, lines: position)
        onSuccess(nil)
    }

    func changePolygonShape(shape: PolygonShape, styleId: String, position: [Polygon], onSuccess: (Any?) -> Void) {
        shape.changeStyleAndData(styleID: styleId, polygons: position)
        onSuccess(nil)
    }

    func changePolylineShape(shape: PolylineShape, styleId: String, position: [Polyline], onSuccess: (Any?) -> Void) {
        shape.changeStyleAndData(styleID: styleId, lines: position)
        onSuccess(nil)
    }

    func createRouteLayer(layerId: String, zOrder: Int, onSuccess: (Any?) -> Void) {
        routeManager.addRouteLayer(layerID: layerId, zOrder: zOrder)
        onSuccess(nil)
    }

    func removeRouteLayer(layerId: String, onSuccess: (Any?) -> Void) {
        routeManager.removeRouteLayer(layerID: layerId)
        onSuccess(nil)
    }

    func addRouteStyle(style: RouteStyleSet, onSuccess: (String) -> Void) {
        routeManager.addRouteStyleSet(style)
        onSuccess(style.styleSetID)
    }

    func addRoute(layer: RouteLayer, route: RouteOptions, onSuccess: (String) -> Void) {
        let routeInstance = layer.addRoute(option: route)
        onSuccess(routeInstance!.routeID)
    }

    func removeRoute(layer: RouteLayer, routeId: String, onSuccess: (Any?) -> Void) {
        layer.removeRoute(routeID: routeId)
        onSuccess(nil)
    }

    func changeRoute(route: Route, styleId: String, points: [RouteSegment], onSuccess: (Any?) -> Void) {
        route.changeStyleAndData(styleID: styleId, segments: points)
        onSuccess(nil)
    }

    func changeRouteVisible(route: Route, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            route.show()
        } else {
            route.hide()
        }
        onSuccess(nil)
    }

    func changeRouteZOrder(route: Route, zOrder: Int, onSuccess: (Any?) -> Void) {
        route.zOrder = zOrder
        onSuccess(nil)
    }

    func changePoiAllVisible(layer: LabelLayer, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            layer.showAllPois()
        } else {
            layer.hideAllPois()
        }
        onSuccess(nil)
    }

    func changePolylineTextAllVisible(layer: LabelLayer, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            layer.showAllWaveTexts()
        } else {
            layer.hideAllWaveTexts()
        }
        onSuccess(nil)
    }

    func changeLabelLayerClickable(layer: LabelLayer, clickable: Bool, onSuccess: (Any?) -> Void) {
        layer.setClickable(clickable)
        onSuccess(nil)
    }

    func changeLabelLayerZOrder(layer: LabelLayer, zOrder: Int, onSuccess: (Any?) -> Void) {
        layer.zOrder = zOrder
        onSuccess(nil)
    }

    func changeLodPoiAllVisible(layer: LodLabelLayer, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            layer.showAllLodPois()
        } else {
            layer.hideAllLodPois()
        }
        onSuccess(nil)
    }

    func changeLodLabelLayerClickable(layer: LodLabelLayer, clickable: Bool, onSuccess: (Any?) -> Void) {
        layer.setClickable(clickable)
        onSuccess(nil)
    }

    func changeLodLabelLayerZOrder(layer: LodLabelLayer, zOrder: Int, onSuccess: (Any?) -> Void) {
        layer.zOrder = zOrder
        onSuccess(nil)
    }

    func changePolylineAllVisible(layer: ShapeLayer, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            layer.showAllPolylineShapes()
        } else {
            layer.hideAllPolylineShapes()
        }
        onSuccess(nil)
    }

    func changePolygonAllVisible(layer: ShapeLayer, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            layer.showAllPolygonShapes()
        } else {
            layer.hideAllPolygonShapes()
        }
        onSuccess(nil)
    }

    func changeRouteLayerVisible(layer: RouteLayer, visible: Bool, onSuccess: (Any?) -> Void) {
        layer.visible = visible
        onSuccess(nil)
    }
}
