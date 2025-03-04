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


internal extension PolygonStyles {
    convenience init(payload: Dictionary<String, Any>) {
        let styles = Array<PerLevelPolygonStyle>()
        styles.append(PerLevelPolygonStyle(payload: payload))
        styles.append(
            contentsOf: asArray(payload["otherStyle"] ?? [], caster: asDict).map {
                PerLevelPolygonStyle(payload: $0)
            }
        )
        self.init(
            styles: styles
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


internal extension PolylineStyles {
    convenience init(payload: Dictionary<String, Any>) {
        let styles = Array<PerLevelPolylineStyle>()
        styles.append(PerLevelPolylineStyle(payload: payload))
        styles.append(
            contentsOf: asArray(payload["otherStyle"] ?? [], caster: asDict).map {
                PerLevelPolylineStyle(payload: $0)
            }
        )
        self.init(
            styles: styles
        )
    }
}