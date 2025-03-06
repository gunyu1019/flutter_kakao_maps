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
}

extension KakaoMapControllerHandler {
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCameraPosition": getCameraPosition(onSuccess: result)
        case "moveCamera":
            let arguments = asDict(call.arguments!)
            let cameraUpdate = asCameraUpdate(kakaoMap: kakaoMap, payload: asDict(arguments["cameraUpdate"]!))
            let rawCameraAnimation = castSafty(arguments["cameraAnimation"], caster: asDict)
            let cameraAnimation = rawCameraAnimation != nil ? CameraAnimationOptions(payload: rawCameraAnimation!) : nil
            moveCamera(cameraUpdate: cameraUpdate, cameraAnimation: cameraAnimation, onSuccess: result)
        case "setEventHandler": setEventHandler(event: (call.arguments! as! UInt8))
        case "setGestureEnable":
            let arguments = asDict(call.arguments!)
            setGestureEnable(
                gestureType: GestureType(rawValue: asInt(arguments["gestureType"]!))!,
                enable: asBool(arguments["enable"]!),
                onSuccess: result
            )
        case "getBuildingHeightScale": getBuildingHeightScale(onSuccess: result)
        case "setBuildingHeightScale":
            let arguments = asDict(call.arguments!)
            setBuildingHeightScale(scale: asFloat(arguments["scale"]!), onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
