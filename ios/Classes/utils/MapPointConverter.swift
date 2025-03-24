import KakaoMapsSDK


internal func convertMapPointToPoint(kakaoMap: KakaoMap, position: MapPoint) {
    let minPosition = kakaoMap.getPosition(CGPoint(x: 0.0, y: 0.0))
    let maxPosition = kakaoMap.getPosition(CGPoint(x: 1.0, y: 1.0))

    let relativeLatitude = maxPosition.wgsCoord.latitude - minPosition.wgsCoord.latitude
    let relativeLongitude = maxPosition.wgsCoord.longitude - minPosition.wgsCoord.longitude

    let x = (position.wgsCoord.latitude - minPosition.wgsCoord.latitude) / relativeLatitude
    let y = (position.wgsCoord.longitude - minPosition.wgsCoord.longitude) / relativeLongitude
    return CGPoint(x: x, y: y)
}
