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
        var styles = Array<PerLevelPolygonStyle>()
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


internal extension PolygonStyleSet {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        let styles = castSafty(payload["styles"], caster:
            asArray($0, caster: {
                PolygonStyles(payload: $0)
            })
        ) ?? []

        self.init(
            styleSetID: styleId,
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


internal extension PolyglineStyleSet {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        let styles = castSafty(payload["styles"], caster:
            asArray($0, caster: {
                PolylineStyles(payload: $0)
            })
        ) ?? []
        let capType = castSafty(payload["polylineCap"], caster: {
            PolylineCapType(rawValue: asInt($0))
        }) ?? PolylineCapType.square
        self.init(
            styleSetID: styleId,
            styles: styles,
            capType: capType
        )
    }
}