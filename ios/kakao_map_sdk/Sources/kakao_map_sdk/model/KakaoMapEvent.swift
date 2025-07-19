enum KakaoMapEvent: UInt8 {
    case CameraMoveStart = 0b0000_0001
    case CameraMoveEnd = 0b0000_0010
    case CompassClick = 0b0000_0100
    case MapClick = 0b0000_1000
    case TerrainClick = 0b0001_0000
    case TerrainLongClick = 0b0010_0000
    case PoiClick = 0b1000000
    case LodPoiClick = 0b1000_0000

    func compare(value: UInt8) -> Bool {
        return rawValue & value == rawValue
    }
}
