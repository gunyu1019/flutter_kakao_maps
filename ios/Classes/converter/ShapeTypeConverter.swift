import KakaoMapsSDK

extension PerLevelPolygonStyle {
    convenience init(payload: [String: Any]) {
        if !(payload["strokeWidth"] is NSNull || payload["strokeColor"] is NSNull || payload["strokeWidth"] == nil || payload["strokeColor"] == nil) {
            self.init(
                color: UIColor(value: asUInt(payload["color"]!)),
                strokeWidth: asUInt(payload["strokeWidth"]!),
                strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        } else {
            self.init(
                color: UIColor(value: asUInt(payload["color"]!)),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        }
    }
}

extension PolygonStyle {
    convenience init(payload: [String: Any]) {
        var styles = [PerLevelPolygonStyle]()
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

extension PolygonStyleSet {
    convenience init(payload: [String: Any]) {
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

extension PerLevelPolylineStyle {
    convenience init(payload: [String: Any]) {
        if !(payload["strokeWidth"] is NSNull || payload["strokeColor"] is NSNull || payload["strokeWidth"] == nil || payload["strokeColor"] == nil) {
            self.init(
                bodyColor: UIColor(value: asUInt(payload["color"]!)),
                bodyWidth: asUInt(payload["lineWidth"]!),
                strokeColor: UIColor(value: asUInt(payload["strokeColor"]!)),
                strokeWidth: asUInt(payload["strokeWidth"]!),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )

        } else {
            self.init(
                bodyColor: UIColor(value: asUInt(payload["color"]!)),
                bodyWidth: asUInt(payload["lineWidth"]!),
                level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
            )
        }
    }
}

extension PolylineStyle {
    convenience init(payload: [String: Any]) {
        var styles = [PerLevelPolylineStyle]()
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

extension PolylineStyleSet {
    convenience init(payload: [String: Any]) {
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
            capType: capType ?? .square
        )
    }
}

func asDotPoints(payload: [String: Any]) -> [CGPoint]? {
    switch asInt(payload["dotType"]!) {
    case 0:
        let radius = asDouble(payload["radius"]!)
        let clockwise = castSafty(payload["closewise"], caster: asBool) ?? true
        return Primitives.getCirclePoints(radius: radius, numPoints: 720, cw: clockwise)
    case 1:
        let width = asDouble(payload["width"]!)
        let height = asDouble(payload["height"]!)
        let clockwise = castSafty(payload["closewise"], caster: asBool) ?? true
        return Primitives.getRectanglePoints(width: width, height: height, cw: clockwise)
    default:
        return nil
    }
}

extension PolygonShapeOptions {
    convenience init(payload: [String: Any]) {
        let styleId = asString(payload["styleId"]!)
        let polygonId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if polygonId == nil {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polygonId!, styleID: styleId, zOrder: zOrder)
        }

        let position = asDict(payload["position"]!)
        let points = asDotPoints(payload: position)
        let holes = castSafty(position["holes"], caster: {
            asArray($0, caster: {
                asDotPoints(payload: asDict($0))!
            })
        })

        basePosition = MapPoint(payload: asDict(position["basePoint"]!))
        polygons = [
            Polygon(
                exteriorRing: points!,
                holes: holes,
                styleIndex: 0
            ),
        ]
    }
}

extension MapPolygonShapeOptions {
    convenience init(payload: [String: Any]) {
        let styleId = asString(payload["styleId"]!)
        let polygonId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if polygonId == nil {
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
        polygons = [
            MapPolygon(
                exteriorRing: points,
                holes: holes,
                styleIndex: 0
            ),
        ]
    }
}

extension PolylineShapeOptions {
    convenience init(payload: [String: Any]) {
        let styleId = asString(payload["styleId"]!)
        let polylineId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if polylineId == nil {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polylineId!, styleID: styleId, zOrder: zOrder)
        }
        let position = asDict(payload["position"]!)
        let points = asDotPoints(payload: position)

        basePosition = MapPoint(payload: asDict(position["basePoint"]!))
        polylines = [
            Polyline(
                line: points!,
                styleIndex: 0
            ),
        ]
    }
}

extension MapPolylineShapeOptions {
    convenience init(payload: [String: Any]) {
        let styleId = asString(payload["styleId"]!)
        let polylineId = castSafty(payload["id"], caster: asString)
        let zOrder = castSafty(payload["zOrder"], caster: asInt) ?? 10001
        if polylineId == nil {
            self.init(styleID: styleId, zOrder: zOrder)
        } else {
            self.init(shapeID: polylineId!, styleID: styleId, zOrder: zOrder)
        }

        let position = asDict(payload["position"]!)
        let points = asArray(position["points"]!, caster: { MapPoint(payload: asDict($0)) })
        polylines = [
            MapPolyline(
                line: points,
                styleIndex: 0
            ),
        ]
    }
}
