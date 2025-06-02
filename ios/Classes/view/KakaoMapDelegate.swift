import KakaoMapsSDK

class KakaoMapDelegate: NSObject, MapControllerDelegate {
    private let option: MapviewInfo
    private let sender: KakaoMapControllerSender

    init(
        view: KMViewContainer,
        controller: KMController,
        sender: KakaoMapControllerSender,
        option: MapviewInfo
    ) {
        self.view = view
        self.controller = controller
        self.sender = sender
        self.option = option
        super.init()
    }

    func addViews() {
        controller.addView(option)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName _: String) {
        let kakaoMap = controller.getView(viewName) as! KakaoMap
        let isInit = kakaoMap.viewRect == CGRect(x: 0, y: 0, width: 1, height: 1)
        kakaoMap.keepLevelOnResize = true
        kakaoMap.viewRect = view.bounds

        // (TEMP) re-rendering
        if isInit {
            kakaoMap.moveCamera(CameraUpdate.make(zoomLevel: kakaoMap.zoomLevel, mapView: kakaoMap))
        }

        sender.onMapReady(kakaoMap: kakaoMap)
    }

    func addViewFailed(_: String, viewInfoName _: String) {
        sender.onMapError(
            error: MapViewLoadFailed()
        )
    }

    func authenticationSucceeded() {
        if !controller.isEnginePrepared {
            controller.prepareEngine()
        }
    }

    func authenticationFailed(_ errorCode: Int, desc: String) {
        // Handling Network Error
        if errorCode == 499 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.controller.prepareEngine()
            }
            return
        }
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
    var view: KMViewContainer
}
