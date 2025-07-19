import KakaoMapsSDK

func convertMapPointToPoint(kakaoMap: KakaoMap, position: MapPoint) -> CGPoint {
    let minPosition = kakaoMap.getPosition(CGPoint(x: kakaoMap.viewRect.width, y: kakaoMap.viewRect.height))
    let maxPosition = kakaoMap.getPosition(CGPoint(x: 0.0, y: 0.0))

    let relativeLatitude = maxPosition.wgsCoord.latitude - minPosition.wgsCoord.latitude
    let relativeLongitude = maxPosition.wgsCoord.longitude - minPosition.wgsCoord.longitude

    let y = (position.wgsCoord.latitude - minPosition.wgsCoord.latitude) / relativeLatitude * kakaoMap.viewRect.height
    let x = (position.wgsCoord.longitude - minPosition.wgsCoord.longitude) / relativeLongitude * kakaoMap.viewRect.width
    return CGPoint(x: x, y: y)
}
