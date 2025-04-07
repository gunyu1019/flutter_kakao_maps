import Flutter
import KakaoMapsSDK

extension UIColor {
    convenience init(value: UInt) {
        self.init(red: CGFloat((value & 0x00FF_0000) >> 16) / 255.0,
                  green: CGFloat((value & 0x0000_FF00) >> 8) / 255.0,
                  blue: CGFloat(value & 0x0000_00FF) / 255.0,
                  alpha: CGFloat(value & 0xFF00_0000) / 1.0)
    }
}

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: size
        )
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: size
            ))
        }
        return resizedImage
    }
}

func asImage(payload: [String: Any]) -> UIImage? {
    let width = asInt(payload["width"]!)
    let height = asInt(payload["height"]!)
    let size = CGSize(width: width, height: height)
    let imageType = asInt(payload["type"]!)
    switch imageType {
    case 0:
        let rawPath = asString(payload["path"]!)
        let path = FlutterKakaoMapsPlugin.getAssets(path: rawPath)
        return UIImage(contentsOfFile: path)?.resize(size: size)
    case 2:
        let data = payload["data"] as! FlutterStandardTypedData
        return UIImage(data: data.data)?.resize(size: size)
    default: // type 1
        let path = asString(payload["path"]!)
        return UIImage(contentsOfFile: path)?.resize(size: size)
    }
}

extension CGPoint {
    init(payload: [String: Double]) {
        self.init(x: payload["x"]!, y: payload["y"]!)
    }

    init(payload: [String: Int]) {
        self.init(x: payload["x"]!, y: payload["y"]!)
    }

    func toMessageable() -> [String: Double] {
        [
            "x": x,
            "y": y,
        ]
    }
}

extension TextStyle {
    convenience init(payload: [String: Any]) {
        self.init(
            fontSize: payload["size"] as! UInt,
            fontColor: UIColor(value: payload["color"] as! UInt),
            strokeThickness: castSafty(payload["strokeSize"], caster: asUInt) ?? 0,
            strokeColor: castSafty(payload["strokeColor"], caster: { UIColor(value: asUInt($0)) }) ?? UIColor.white,
            font: castSafty(payload["font"], caster: asString) ?? "",
            charSpace: castSafty(payload["characterSpace"], caster: asInt) ?? 0,
            lineSpace: castSafty(payload["lineSpace"], caster: asFloat) ?? 1.0,
            aspectRatio: castSafty(payload["aspectRatio"], caster: asFloat) ?? 1.0
        )
    }
}

func asGuiAlignment(payload: Int) -> GuiAlignment {
    return GuiAlignment(
        vAlign: VerticalAlign(rawValue: payload % 3)!,
        hAlign: HorizontalAlign(rawValue: payload / 3)!
    )
}
