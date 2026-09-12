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
            guard let labelLayer = labelManager.getLabelLayer(layerID: labelLayerId) else {
                result(missingNativeResource(method: call.method, resource: "tracking label layer", id: labelLayerId))
                return
            }
            let poiId = asString(arguments!["poiId"]!)
            guard let poi = labelLayer.getPoi(poiID: poiId) else {
                result(missingNativeResource(method: call.method, resource: "tracking POI", id: poiId))
                return
            }
            startTracking(label: poi, onSuccess: result)
        case "stopTracking": stopTracking(onSuccess: result)
        case "setTrackingPosition":
            let rotation = asBool(arguments!["rotation"]!)
            setTrackingRotation(rotation: rotation, onSuccess: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
