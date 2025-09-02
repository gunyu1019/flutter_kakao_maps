import Flutter
import KakaoMapsSDK

protocol TrackingControllerHandler {
    var trackingManager: TrackingManager { get }
    var labelManager: LabelManager { get }

    func setTrackingRotation(rotation: Bool, onSuccess: (Any?) -> Void)

    func startTracking(label: Poi, onSuccess: (Any?) -> Void)

    func stopTracking(onSuccess: (Any?) -> Void)
}

extension TrackingControllerHandler {
    func trackingHandle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = castSafty(call.arguments, caster: asDict)

        switch call.method {
        case "startTracking":
            let labelLayerId = asString(arguments!["layerId"]!)
            let labelLayer = labelManager.getLabelLayer(layerID: labelLayerId)
            let poi = labelLayer!.getPoi(poiID: asString(arguments!["poiId"]!))
            startTracking(label: poi!, onSuccess: result)
        case "stopTracking": stopTracking(onSuccess: result)
        case "setTrackingRotation":
            let rotation = asBool(arguments!["rotation"]!)
            setTrackingRotation(rotation: rotation, onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
