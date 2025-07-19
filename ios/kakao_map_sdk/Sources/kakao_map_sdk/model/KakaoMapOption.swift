import KakaoMapsSDK

extension MapviewInfo {
    convenience init(
        payload: [String: Any],
        viewId: Int64
    ) {
        self.init(
            viewName: castSafty(payload["viewName"], caster: asString) ?? "map_\(viewId)",
            appName: "openmap",
            viewInfoName: asString(payload["mapType"] ?? "map"),
            defaultPosition: MapPoint(payload: payload),
            defaultLevel: asInt(payload["zoomLevel"] ?? 15),
            enabled: asBool(payload["visible"] ?? true)
        )
    }
}
