import KakaoMapsSDK


internal extension PerLevelPolygonStyle {
    convenience init(payload: Dictionary<String, Any>) {
        if (payload["strokeSize"] == nil || payload["strokeColor"] == nil) {
            self.init(
                color: UIColor(value: asUInt(payload["color"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        } else {
            self.init(
                color: UIColor(value: asUInt(payload["color"]!)),
                strokeWidth: asUInt(payload["strokeSize"]!),
                strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        }
    }
}


internal extension PolygonStyle {
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
        let styles = castSafty(payload["styles"], caster: {
            asArray($0, caster: {
                PolygonStyle(payload: asDict($0))
            })
        }) ?? []

        self.init(
            styleSetID: styleId,
            styles: styles
        )
    }
}


internal extension PerLevelPolylineStyle {
    convenience init(payload: Dictionary<String, Any>) {
        if (payload["strokeSize"] == nil || payload["strokeColor"] == nil) {
            self.init(
                bodyColor: UIColor(value: asUInt(payload["color"]!)),
                bodyWidth: asUInt(payload["lineWidth"]!),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        } else {
            self.init(
                bodyColor: UIColor(value: asUInt(payload["color"]!)),
                bodyWidth: asUInt(payload["lineWidth"]!),
                strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
                strokeWidth: asUInt(payload["strokeSize"]!),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        }
    }
}


internal extension PolylineStyle {
    convenience init(payload: Dictionary<String, Any>) {
        var styles = Array<PerLevelPolylineStyle>()
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


internal extension PolylineStyleSet {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        let styles = castSafty(payload["styles"], caster: {
            asArray($0, caster: {
                PolylineStyle(payload: asDict($0))
            })
        }) ?? []
        let capType = castSafty(payload["polylineCap"], caster: {
            PolylineCapType(rawValue: asInt($0))!
        })
        self.init(
            styleSetID: styleId,
            styles: styles,
            capType: (capType ?? .square)
        )
    }
}


internal func asDotPoints(payload: Dictionary<String, Any>) -> [CGPoint]? {
    switch asInt(payload["dotType"]!) {
    case 0:
        let radius = asDouble(payload["radius"]!)
        let clockwise = castSafty(payload["closewise"], caster: asBool) ?? true
        return Primitives.getCirclePoints(radius: radius, numPoints: 0, cw: clockwise)
    case 1:
        let width = asDouble(payload["width"]!)
        let height = asDouble(payload["height"]!)
        let clockwise = castSafty(payload["closewise"], caster: asBool) ?? true
        return Primitives.getRectanglePoints(width: width, height: height, cw: clockwise)
    default:
        return nil
    }
}


internal extension PolygonShapeOptions {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = asString(payload["styleId"]!)
        let polygonId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if (polygonId == nil) {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polygonId!, styleID: styleId, zOrder: zOrder)
        }

        let position = asDict(payload["position"]!)
        let points = asDotPoints(payload: asDict(position["points"]!))
        let holes = castSafty(position["holes"], caster: {
            asArray($0, caster: {
                asDotPoints(payload: asDict($0))!
            })
        })

        self.basePosition = MapPoint(payload: asDict(position["basePoint"]!))
        self.polygons = [
            Polygon(
                exteriorRing: points!,
                holes: holes,
                styleIndex: 0
            )
        ]
    }
}


internal extension MapPolygonShapeOptions {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = asString(payload["styleId"]!)
        let polygonId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if (polygonId == nil) {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polygonId!, styleID: styleId, zOrder: zOrder)
        }

        let position = asDict(payload["position"]!)
        let points = asArray(position["points"]!, caster: { MapPoint(payload: asDict($0)) })
        let holes = castSafty(position["holes"], caster: {
            asArray($0, caster: {
                asArray($0, caster: asDict).map {
                    MapPoint(payload: $0)
                }
            })
        })
        self.polygons = [
            MapPolygon(
                exteriorRing: points,
                holes: holes,
                styleIndex: 0
            )
        ]
    }
}


internal extension PolylineShapeOptions {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = asString(payload["styleId"]!)
        let polylineId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if (polylineId == nil) {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polylineId!, styleID: styleId, zOrder: zOrder)
        }
        let position = asDict(payload["position"]!)
        let points = asDotPoints(payload: asDict(position["points"]!))

        self.basePosition = MapPoint(payload: asDict(position["basePoint"]!))
        self.polylines = [
            Polyline(
                line: points!,
                styleIndex: 0
            )
        ]
    }
}


internal extension MapPolylineShapeOptions {
    convenience init(payload: Dictionary<String, Any>) {
        let styleId = asString(payload["styleId"]!)
        let polylineId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if (polylineId == nil) {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polylineId!, styleID: styleId, zOrder: zOrder)
        }

        let position = asDict(payload["position"]!)
        let points = asArray(position["points"]!, caster: { MapPoint(payload: asDict($0)) })
        self.polylines = [
            MapPolyline(
                line: points,
                styleIndex: 0
            )
        ]
    }
}
