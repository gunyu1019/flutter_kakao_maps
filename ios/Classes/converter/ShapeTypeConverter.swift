import KakaoMapsSDK


internal extension PerLevelPolygonStyle {
    convenience init(payload: Dictionary<String, Any>) {
        if (payload["strokeSize"] == nil || payload["strokeColor"] == nil) {
            return self.init(
                color: UIColor(value: asUInt(payload["color"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        }
        self.init(
            color: UIColor(value: asUInt(payload["color"]!)),
            strokeWidth: asUInt(payload["strokeSize"]!),
            strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
            level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
        )
    }
}


internal extension PerLevelPolylineStyle {
    convenience init(payload: Dictionary<String, Any>) {
        if (payload["strokeSize"] == nil || payload["strokeColor"] == nil) {
            return self.init(
                bodyColor: UIColor(value: asUInt(payload["color"]!)),
                bodyWidth: asUInt(payload["lineWidth"]!),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        }
        self.init(
            bodyColor: UIColor(value: asUInt(payload["color"]!)),
            bodyWidth: asUInt(payload["lineWidth"]!),
            strokeWidth: asUInt(payload["strokeSize"]!),
            strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
            level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
        )
    }
}