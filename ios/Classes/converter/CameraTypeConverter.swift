import KakaoMapsSDK

extension MapPoint {
    convenience init(payload: [String: Any]) {
        self.init(
            longitude: asDouble(payload["longitude"]!),
            latitude: asDouble(payload["latitude"]!)
        )
    }

    convenience init(payload: [String: Double]) {
        self.init(
            longitude: payload["longitude"]!,
            latitude: payload["latitude"]!
        )
    }

    func toMessageable() -> [String: Double] {
        [
            "latitude": wgsCoord.latitude,
            "longitude": wgsCoord.longitude,
        ]
    }
}

func asCameraUpdate(kakaoMap: KakaoMap, payload: [String: Any]) -> CameraUpdate {
    let cameraUpdateType = asInt(payload["type"]!)
    let zoomLevel = castSafty(payload["zoomLevel"], caster: asInt) ?? kakaoMap.zoomLevel
    let angle = castSafty(payload["angle"], caster: asDouble)
    switch cameraUpdateType {
    case 0: return CameraUpdate.make(target: MapPoint(payload: payload), zoomLevel: zoomLevel, mapView: kakaoMap)
    case 1:
        return CameraUpdate.make(
            target: MapPoint(payload: payload),
            zoomLevel: zoomLevel,
            rotation: asDouble(payload["rotationAngle"] ?? kakaoMap.rotationAngle),
            tilt: asDouble(payload["tiltAngle"] ?? kakaoMap.tiltAngle),
            mapView: kakaoMap
        )
    case 3: return CameraUpdate.make(zoomLevel: zoomLevel, mapView: kakaoMap)
    case 4: return CameraUpdate.make(zoomLevel: kakaoMap.zoomLevel + 1, mapView: kakaoMap)
    case 5: return CameraUpdate.make(zoomLevel: kakaoMap.zoomLevel - 1, mapView: kakaoMap)
    case 6: return CameraUpdate.make(rotation: angle!, tilt: kakaoMap.tiltAngle, mapView: kakaoMap)
    case 7: return CameraUpdate.make(rotation: kakaoMap.rotationAngle, tilt: angle!, mapView: kakaoMap)
    case 8:
        let points = asArray(payload["points"]!).map {
            element in MapPoint(payload: asDictTyped(element, caster: asDouble))
        }
        let area = AreaRect(points: points)
        return CameraUpdate.make(
            area: area,
            levelLimit: zoomLevel
        )
    default: return CameraUpdate.make(mapView: kakaoMap)
    }
}

extension CameraAnimationOptions {
    init(payload: [String: Any]) {
        self.init(
            autoElevation: ObjCBool(asBool(payload["autoElevation"] ?? false)),
            consecutive: ObjCBool(asBool(payload["autoElevation"] ?? false)),
            durationInMillis: UInt(asInt(payload["duration"]!))
        )
    }
}
