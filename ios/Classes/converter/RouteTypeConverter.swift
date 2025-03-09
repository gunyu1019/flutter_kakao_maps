import KakaoMapsSDK


extension RoutePattern {
    convenience init(payload: [String: Any]) {
        self.init(
            pattern: UIImage(payload: asDict(payload["patternImage"])),
            distance: asFloat(payload["distance"]),
            symbol: castSafty(payload["symbolImage"], caster: { 
                UIImage(asDict($0))
            }),
            pinStart: castSafty(payload["pinEnd"], caster: asBool) ?? false,
            pinEnd: castSafty(payload["pinEnd"], caster: asBool) ?? false
        )
    }
}

extension PerLevelRouteStyle {
    convenience init(payload: [String: Any], patternIndex: Int = -1) {
        if payload["strokeSize"] == nil || payload["strokeColor"] == nil {
            self.init(
                width: asUInt(payload["lineWidth"]!), 
                color: UIColor(value: asUInt(payload["color"])),
                strokeWidth: asUInt(payload["strokeSize"]!),
                strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
                level: castSafty(payload["zoomLevel"], caster=asInt) ?? 0, 
                patternIndex: patternIndex
            )
        } else {
            self.init(
                width: asUInt(payload["lineWidth"]!), 
                color: UIColor(value: asUInt(payload["color"])),
                level: castSafty(payload["zoomLevel"], caster=asInt) ?? 0, 
                patternIndex: patternIndex
            )
        }
    }
}


extension RouteStyleSet {
    convenience init(payload: [String: Any]) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        var patterns = [RoutePattern]()
        let styleSets = castSafty(payload["styles"], caster: {
            asArray($0, caster: {
                let rawStyles = asDict($0)
                var patternIndex = -1
                if rawStyles["pattern"] != nil && rawStyles["pattern"] is NSNull {
                    patterns.append(
                        RoutePattern(payload: asDict(rawStyles["pattern"]!), patternIndex: patternIndex)
                    )
                    patternIndex = patterns.count - 1
                }
                var styles = [PerLevelRouteStyle]()
                styles.append(PerLevelRouteStyle(payload: rawStyles))
                styles.append(
                    contentsOf: asArray(rawStyles["otherStyle"] ?? [], caster: asDict).map {
                        patternIndex = -1
                        if rawStyles["pattern"] != nil && rawStyles["pattern"] is NSNull {
                            patterns.append(
                                RoutePattern(payload: asDict(rawStyles["pattern"]!))
                            )
                            patternIndex = patterns.count - 1
                        }
                        PerLevelRouteStyle(payload: $0, patternIndex: patternIndex)   
                    }
                )

                RouteStyle(styles: styles)
            })
        }) ?? []

        self.init(
            styleID: styleId,
            styles: styleSets
        )
        patterns.forEach {
            self.addPattern($0)
        }
    }
}