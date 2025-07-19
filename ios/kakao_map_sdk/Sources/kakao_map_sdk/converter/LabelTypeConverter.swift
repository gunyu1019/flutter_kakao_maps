import KakaoMapsSDK

func asPoiTransition(payload: [String: Any]?) -> PoiTransition {
    if payload == nil {
        return PoiTransition(entrance: .none, exit: .none)
    }
    return PoiTransition(
        entrance: castSafty(payload!["entrance"], caster: { TransitionType(rawValue: asInt($0)) ?? .none }) ?? TransitionType.none,
        exit: castSafty(payload!["exit"], caster: { TransitionType(rawValue: asInt($0)) ?? .none }) ?? TransitionType.none
    )
}

extension PoiTextStyle {
    convenience init(payload: [String: Any]) {
        let transition = asPoiTransition(payload: castSafty(payload["iconTransition"], caster: asDict))
        let textStyle = castSafty(payload["textStyle"], caster: {
            asArray($0, caster: {
                PoiTextLineStyle(textStyle: TextStyle(payload: asDict($0)))
            })
        }) ?? []
        self.init(
            transition: transition,
            enableEntranceTransition: transition.entrance != TransitionType.none,
            enableExitTransition: transition.exit != TransitionType.none,
            textLineStyles: textStyle
        )

        if payload["textGravity"] != nil {
            let gravity = asInt(payload["textGravity"]!)
            switch gravity {
            case 1:
                textLayouts = [PoiTextLayout.left]
            case 2:
                textLayouts = [PoiTextLayout.right]
            case 4:
                textLayouts = [PoiTextLayout.top]
            case 8:
                textLayouts = [PoiTextLayout.bottom]
            case 16:
                textLayouts = [PoiTextLayout.center]
            default:
                break
            }
        }
    }
}

extension PoiIconStyle {
    convenience init(payload: [String: Any]) {
        let transition = asPoiTransition(payload: castSafty(payload["iconTransition"], caster: asDict))
        let symbol = payload["icon"].flatMap(asDict).flatMap(asImage)

        self.init(
            symbol: symbol,
            anchorPoint: castSafty(payload["anchor"], caster: { CGPoint(payload: asDictTyped($0, caster: asDouble)) }) ?? CGPoint(x: 0.5, y: 0.5),
            transition: transition,
            enableEntranceTransition: transition.entrance != .none,
            enableExitTransition: transition.exit != .none,
            badges: nil
        )
    }
}

extension PerLevelPoiStyle {
    convenience init(payload: [String: Any]) {
        self.init(
            iconStyle: PoiIconStyle(payload: payload),
            textStyle: PoiTextStyle(payload: payload),
            padding: castSafty(payload["paddding"], caster: asFloat) ?? 0.0,
            level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
        )
    }
}

extension PoiStyle {
    convenience init(payload: [String: Any]) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        let rawStyles = asDict(payload["styles"])
        var styles = [PerLevelPoiStyle]()
        styles.append(PerLevelPoiStyle(payload: rawStyles))
        styles.append(
            contentsOf: asArray(rawStyles["otherStyle"] ?? [], caster: asDict).map {
                PerLevelPoiStyle(payload: $0)
            }
        )
        self.init(
            styleID: styleId,
            styles: styles
        )
    }
}

extension PoiOptions {
    convenience init(payload: [String: Any]) {
        self.init(styleID: asString(payload["styleId"]!))
        if let rank = payload["rank"] {
            if !(rank is NSNull) {
                self.rank = asInt(rank)
            }
        }
        if let clickable = payload["clickable"] {
            if !(clickable is NSNull) {
                self.clickable = asBool(clickable)
            }
        }
        if let transformMethod = payload["transformMethod"] {
            if !(transformMethod is NSNull) {
                transformType = PoiTransformType(rawValue: asInt(transformMethod)) ?? PoiTransformType.default
            }
        }
        if let text = payload["text"] {
            if !(text is NSNull) {
                asString(text).components(separatedBy: "\n").enumerated().map {
                    index, element in PoiText(text: element, styleIndex: UInt(index))
                }.map(addText)
            }
        }
    }
}

extension LabelLayerOptions {
    convenience init(payload: [String: Any]) {
        self.init(
            layerID: asString(payload["layerId"]!),
            competitionType: castSafty(payload["competitionType"], caster: { CompetitionType(rawValue: asInt($0))! }) ?? CompetitionType.none,
            competitionUnit: castSafty(payload["competitionUnit"], caster: { CompetitionUnit(rawValue: asInt($0))! }) ?? CompetitionUnit.poi,
            orderType: castSafty(payload["orderType"], caster: { OrderingType(rawValue: asInt($0))! }) ?? OrderingType.rank,
            zOrder: castSafty(payload["zOrder"], caster: asInt) ?? 10001
        )
    }
}

extension LodLabelLayerOptions {
    convenience init(payload: [String: Any]) {
        self.init(
            layerID: asString(payload["layerId"]!),
            competitionType: castSafty(payload["competitionType"], caster: { CompetitionType(rawValue: asInt($0))! }) ?? CompetitionType.none,
            competitionUnit: castSafty(payload["competitionUnit"], caster: { CompetitionUnit(rawValue: asInt($0))! }) ?? CompetitionUnit.poi,
            orderType: castSafty(payload["orderType"], caster: { OrderingType(rawValue: asInt($0))! }) ?? OrderingType.rank,
            zOrder: castSafty(payload["zOrder"], caster: asInt) ?? 10001,
            radius: castSafty(payload["radius"], caster: asFloat) ?? 20.0
        )
    }
}

extension PerLevelWaveTextStyle {
    convenience init(payload: [String: Any]) {
        self.init(
            textStyle: TextStyle(payload: payload),
            level: castSafty(payload["zoomLevel"], caster: asInt) ?? 0
        )
    }
}

extension WaveTextStyle {
    convenience init(payload: [String: Any]) {
        let styleId = castSafty(payload["styleId"], caster: asString) ?? UUID().uuidString
        var styles = [PerLevelWaveTextStyle]()
        styles.append(PerLevelWaveTextStyle(payload: payload))
        styles.append(
            contentsOf: asArray(payload["otherStyle"] ?? [], caster: asDict).map {
                PerLevelWaveTextStyle(payload: $0)
            }
        )
        self.init(
            styleID: styleId,
            styles: styles
        )
    }
}

extension WaveTextOptions {
    convenience init(payload: [String: Any], styleId: String) {
        if !(payload["id"] == nil || payload["id"] is NSNull) {
            self.init(styleID: styleId, waveTextID: asString(payload["id"]!))
        } else {
            self.init(styleID: styleId)
        }

        if let rank = payload["rank"] {
            if !(rank is NSNull) {
                self.rank = asUInt(rank)
            }
        }
        if let text = payload["text"] {
            if !(text is NSNull) {
                self.text = asString(text)
            }
        }
        if let points = payload["position"] {
            if !(points is NSNull) {
                self.points = asArray(points, caster: { MapPoint(payload: asDict($0)) })
            }
        }
    }
}
