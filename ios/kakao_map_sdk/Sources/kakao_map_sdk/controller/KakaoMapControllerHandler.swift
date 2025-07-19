import Flutter
import KakaoMapsSDK

protocol KakaoMapControllerHandler {
    var kakaoMap: KakaoMap { get }

    func getCameraPosition(onSuccess: @escaping (_ cameraPosition: [String: Any]) -> Void)

    func moveCamera(
        cameraUpdate: CameraUpdate,
        cameraAnimation: CameraAnimationOptions?,
        onSuccess: (Any?) -> Void
    )

    func setEventHandler(event: UInt8)

    func setGestureEnable(gestureType: GestureType, enable: Bool, onSuccess: (Any?) -> Void)

    func getBuildingHeightScale(onSuccess: (Float) -> Void)

    func setBuildingHeightScale(scale: Float, onSuccess: (Any?) -> Void)

    func fromScreenPoint(point: CGPoint, onSuccess: ([String: Double]) -> Void)

    func toScreenPoint(position: MapPoint, onSuccess: ([String: Double]) -> Void)

    func clearCache(onSuccess: (Any?) -> Void)

    func clearDiskCache(onSuccess: (Any?) -> Void)

    func canPositionVisible(zoomLevel: Int, position: [MapPoint], onSuccess: (Bool) -> Void)

    func changeMapType(mapType: String, onSuccess: (Any?) -> Void)

    func overlayVisible(overlayType: String, visible: Bool, onSuccess: (Any?) -> Void)

    func defaultGUIvisible(type: DefaultGUIType, visible: Bool, onSuccess: (Any?) -> Void)

    func defaultGUIposition(type: DefaultGUIType, gravity: GuiAlignment, position: CGPoint, onSuccess: (Any?) -> Void)

    func scaleAutohide(autohide: Bool, onSuccess: (Any?) -> Void)

    func scaleAnimationTime(fadeIn: UInt32, fadeOut: UInt32, retention: UInt32, onSuccess: (Any?) -> Void)

    func pause(onSuccess: (Any?) -> Void)

    func resume(onSuccess: (Any?) -> Void)

    func finish(onSuccess: (Any?) -> Void)
}

extension KakaoMapControllerHandler {
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case "getCameraPosition": getCameraPosition(onSuccess: result)
        case "moveCamera":
            let cameraUpdate = asCameraUpdate(kakaoMap: kakaoMap, payload: asDict(arguments!["cameraUpdate"]!))
            let rawCameraAnimation = castSafty(arguments!["cameraAnimation"], caster: asDict)
            let cameraAnimation = rawCameraAnimation != nil ? CameraAnimationOptions(payload: rawCameraAnimation!) : nil
            moveCamera(cameraUpdate: cameraUpdate, cameraAnimation: cameraAnimation, onSuccess: result)
        case "setEventHandler": setEventHandler(event: (call.arguments! as! UInt8))
        case "setGestureEnable":
            setGestureEnable(
                gestureType: GestureType(rawValue: asInt(arguments!["gestureType"]!))!,
                enable: asBool(arguments!["enable"]!),
                onSuccess: result
            )
        case "getBuildingHeightScale": getBuildingHeightScale(onSuccess: result)
        case "setBuildingHeightScale": setBuildingHeightScale(scale: asFloat(arguments!["scale"]!), onSuccess: result)
        case "fromScreenPoint":
            let pointPayload = asDictTyped(call.arguments!, caster: asDouble)
            fromScreenPoint(point: CGPoint(payload: pointPayload), onSuccess: result)
        case "toScreenPoint": toScreenPoint(position: MapPoint(payload: arguments!), onSuccess: result)
        case "clearCache": clearCache(onSuccess: result)
        case "clearDiskCache": clearDiskCache(onSuccess: result)
        case "canPositionVisible":
            let zoomLevel = asInt(arguments!["zoomLevel"]!)
            let position = asArray(arguments!["position"]!, caster: { MapPoint(payload: asDict($0)) })
            canPositionVisible(zoomLevel: zoomLevel, position: position, onSuccess: result)
        case "changeMapType": changeMapType(mapType: asString(arguments!["mapType"]!), onSuccess: result)
        case "overlayVisible":
            overlayVisible(
                overlayType: asString(arguments!["overlayType"]!),
                visible: asBool(arguments!["visible"]!),
                onSuccess: result
            )
        case "defaultGUIvisible":
            let guiType = DefaultGUIType(rawValue: asString(arguments!["type"]!))!
            let visible = asBool(arguments!["visible"]!)
            defaultGUIvisible(type: guiType, visible: visible, onSuccess: result)
        case "defaultGUIposition":
            let guiType = DefaultGUIType(rawValue: asString(arguments!["type"]!))!
            let position = CGPoint(x: asDouble(arguments!["x"]!), y: asDouble(arguments!["y"]!))
            let gravity = asGuiAlignment(payload: asInt(arguments!["gravity"]!))
            defaultGUIposition(type: guiType, gravity: gravity, position: position, onSuccess: result)
        case "scaleAutohide":
            let autohide = asBool(arguments!["autohide"]!)
            scaleAutohide(autohide: autohide, onSuccess: result)
        case "scaleAnimationTime":
            let fadeIn = arguments!["fadeIn"]! as! UInt32
            let fadeOut = arguments!["fadeIn"]! as! UInt32
            let retention = arguments!["fadeIn"]! as! UInt32
            scaleAnimationTime(fadeIn: fadeIn, fadeOut: fadeOut, retention: retention, onSuccess: result)
        case "pause":
            pause(onSuccess: result)
        case "resume":
            resume(onSuccess: result)
        case "finish":
            finish(onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
