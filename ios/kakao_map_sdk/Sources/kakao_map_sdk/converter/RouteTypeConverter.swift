import KakaoMapsSDK

extension RoutePattern {
    convenience init(payload: [String: Any]) {
        self.init(
            pattern: asImage(payload: asDict(payload["patternImage"]!))!,
            distance: asFloat(payload["distance"]!),
            symbol: castSafty(payload["symbolImage"], caster: {
                asImage(payload: asDict($0))!
            }),
            pinStart: castSafty(payload["pinEnd"], caster: asBool) ?? false,
            pinEnd: castSafty(payload["pinEnd"], caster: asBool) ?? false
        )
    }
}

extension PerLevelRouteStyle {
    convenience init(payload: [String: Any], patternIndex: Int = -1) {
        if !(payload["strokeWidth"] is NSNull || payload["strokeColor"] is NSNull || payload["strokeWidth"] == nil || payload["strokeColor"] == nil) {
            self.init(
                width: asUInt(payload["lineWidth"]!),
                color: UIColor(value: asUInt(payload["color"]!)),
                strokeWidth: asUInt(payload["strokeWidth"]!),
                strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0,
                patternIndex: patternIndex
            )
        } else {
            self.init(
                width: asUInt(payload["lineWidth"]!),
                color: UIColor(value: asUInt(payload["color"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0,
                patternIndex: patternIndex
            )
        }
    }
}

extension RouteStyleSet {
    convenience init(payload: [String: Any]) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        var patterns = [RoutePattern]()
        let styleSets: [RouteStyle] = castSafty(payload["styles"], caster: {
            asArray($0, caster: { (styleSetElement: Any) -> RouteStyle in
                let rawStyles = asDict(styleSetElement)
                var patternIndex = -1
                if rawStyles["pattern"] != nil, !(rawStyles["pattern"] is NSNull) {
                    patterns.append(
                        RoutePattern(payload: asDict(rawStyles["pattern"]!))
                    )
                    patternIndex = patterns.count - 1
                }
                var styles = [PerLevelRouteStyle]()
                styles.append(PerLevelRouteStyle(payload: rawStyles, patternIndex: patternIndex))
                styles.append(
                    contentsOf: asArray(rawStyles["otherStyle"] ?? [], caster: asDict).map { styleElement -> PerLevelRouteStyle in
                        patternIndex = -1
                        if rawStyles["pattern"] != nil, rawStyles["pattern"] is NSNull {
                            patterns.append(
                                RoutePattern(payload: asDict(rawStyles["pattern"]!))
                            )
                            patternIndex = patterns.count - 1
                        }
                        return PerLevelRouteStyle(payload: styleElement, patternIndex: patternIndex)
                    }
                )

                return RouteStyle(styles: styles)
            })
        }) ?? []

        self.init(
            styleID: styleId,
            styles: styleSets
        )
        for pattern in patterns {
            addPattern(pattern)
        }
    }
}

extension RouteSegment {
    convenience init(payload: [String: Any], index: UInt = 0) {
        var points = asArray(payload["points"]!, caster: {
            MapPoint(payload: asDict($0))
        })
        let curveType = castSafty(payload["curveType"], caster: asInt) ?? 0
        if curveType == 1 {
            points = Primitives.getCurvePoints(startPoint: points[0], endPoint: points[points.count - 1], isLeft: true)
        } else if curveType == 2 {
            points = Primitives.getCurvePoints(startPoint: points[0], endPoint: points[points.count - 1], isLeft: false)
        }
        self.init(
            points: points,
            styleIndex: index
        )
    }
}

func asRouteOption(payload: [String: Any]) -> RouteOptions {
    let routeId = castSafty(payload["id"], caster: asString)
    let styleId = asString(payload["styleId"]!)
    let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10000

    let option = routeId != nil ? RouteOptions(
        routeID: routeId!, styleID: styleId, zOrder: zOrder
    ) : RouteOptions(
        styleID: styleId, zOrder: zOrder
    )
    option.segments = [
        RouteSegment(payload: payload, index: 0),
    ]
    return option
}

func asRouteMultipleOption(payload: [String: Any]) -> RouteOptions {
    var styleId: String? = nil
    let routeId = castSafty(payload["id"], caster: asString)
    let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10000
    let segments = asArray(payload["routes"]!).enumerated().map { (index: Int, rawElement: Any) ->
        RouteSegment in
        let element = asDict(rawElement)
        if element["styleId"] != nil && styleId == nil {
            styleId = asString(element["styleId"]!)
        }
        return RouteSegment(payload: element, index: UInt(index))
    }

    let option = routeId != nil ? RouteOptions(
        routeID: routeId!, styleID: styleId!, zOrder: zOrder
    ) : RouteOptions(
        styleID: styleId!, zOrder: zOrder
    )
    option.segments = segments
    return option
}
