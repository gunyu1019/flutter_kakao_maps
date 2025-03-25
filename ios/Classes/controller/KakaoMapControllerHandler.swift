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

    func fromScreenPoint(point: CGPoint, onSuccess: ([String:Double]) -> Void)

    func toScreenPoint(position: MapPoint, onSuccess: ([String:Double]) -> Void)

    func clearCache(onSuccess: (Any?) -> Void)

    func clearDiskCache(onSuccess: (Any?) -> Void)

    func canPositionVisible(zoomLevel: Int, position: MapPoint[], onSuccess: (Bool) -> Void)

    func changeMapType(mapType: String, onSuccess: (Any?) -> Void)

    func getBuildingHeightScale(onSuccess: (Float) -> Void)

    func setBuildingHeightScale(scale: Float, onSuccess: (Any?) -> Void)

    func overlayVisible(overlayType: String, visible: Bool, onSuccess: (Any?) -> Void)
}

extension KakaoMapControllerHandler {
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)
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
        case "fromScreenPoint": fromScreenPoint(point: CGPoint(payload: arguments!), onSuccess: result)
        case "toScreenPoint": toScreenPoint(position: MapPoint(payload: arguments!), onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
