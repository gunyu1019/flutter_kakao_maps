import KakaoMapsSDK

class KakaoMapDelegate: NSObject, MapControllerDelegate {
    private let option: MapviewInfo
    private let sender: KakaoMapControllerSender

    init(
        controller: KMController,
        sender: KakaoMapControllerSender,
        option: MapviewInfo
    ) {
        self.controller = controller
        self.sender = sender
        self.option = option
        super.init()
    }

    func addViews() {
        controller.addView(option)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName _: String) {
        sender.onMapReady(
            kakaoMap: (controller.getView(viewName) as! KakaoMap)
        )
    }

    func addViewFailed(_: String, viewInfoName _: String) {
        sender.onMapError(
            error: MapViewLoadFailed()
        )
    }

    func authenticationFailed(_ errorCode: Int, desc: String) {
        sender.onMapError(
            error: AuthenticatedFailed(errorCode: errorCode, message: desc)
        )
    }

    func containerDidResized(_ size: CGSize) {
        let kakaoMap = controller.getView(option.viewName) as? KakaoMap
        let isInit = kakaoMap?.viewRect == CGRect(x: 0, y: 0, width: 1, height: 1)
        kakaoMap?.keepLevelOnResize = true
        kakaoMap?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)

        // (TEMP) re-rendering
        if isInit {
            kakaoMap?.moveCamera(CameraUpdate.make(zoomLevel: kakaoMap!.zoomLevel, mapView: kakaoMap!))
        }
    }

    var controller: KMController
}
