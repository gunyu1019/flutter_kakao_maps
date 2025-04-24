import Flutter
import KakaoMapsSDK

class KakaoMapView: NSObject, FlutterPlatformView { // UIApplicationDelegate
    private let KMView: KMViewContainer
    private let kakaoMap: KMController
    private var eventDelegate: KakaoMapDelegate!

    private let controller: KakaoMapController

    init(
        frame _: CGRect,
        channel: FlutterMethodChannel,
        overlayChannel: FlutterMethodChannel,
        option: MapviewInfo
    ) {
        KMView = KMViewContainer()
        kakaoMap = KMController(viewContainer: KMView)
        controller = KakaoMapController(
            channel: channel,
            overlayChannel: overlayChannel,
            mapController: kakaoMap
        )
        super.init()

        eventDelegate = KakaoMapDelegate(
            view: KMView,
            controller: kakaoMap,
            sender: controller,
            option: option
        )
        kakaoMap.delegate = eventDelegate

        // Support ProMotion Mode
        kakaoMap.proMotionSupport = KMView.proMotionDisplay

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onViewPaused),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onViewResume),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        kakaoMap.prepareEngine()
    }

    func view() -> UIView {
        if !kakaoMap.isEnginePrepared {
            kakaoMap.prepareEngine()
        }
        if !kakaoMap.isEngineActive {
            kakaoMap.activateEngine()
        }
        return KMView
    }

    @objc func onViewPaused() {
        kakaoMap.pauseEngine()
        controller.onMapPaused()
    }

    @objc func onViewResume() {
        kakaoMap.activateEngine()
        controller.onMapResumed()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        self.kakaoMap.pauseEngine()
        self.kakaoMap.resetEngine()
    }
}
