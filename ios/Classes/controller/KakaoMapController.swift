import Flutter
import KakaoMapsSDK

class KakaoMapController: KakaoMapControllerSender, KakaoMapControllerHandler {
    private let channel: FlutterMethodChannel
    private let overlayChannel: FlutterMethodChannel

    private var lateinitKakaoMap: KakaoMap? = nil
    var kakaoMap: KakaoMap {
        get {
            return lateinitKakaoMap!
        }
        set(value) {
            lateinitKakaoMap = value
        }
    }

    private var overlayController: OverlayController? = nil

    private let cameraListener: CameraListener
    private let mapClickListener: MapClickListener
    private let poiClickListener: PoiClickListener

    init(
        channel: FlutterMethodChannel,
        overlayChannel: FlutterMethodChannel
    ) {
        self.channel = channel
        self.overlayChannel = overlayChannel

        cameraListener = CameraListener(channel: self.channel)
        mapClickListener = MapClickListener(channel: self.channel)
        poiClickListener = PoiClickListener(channel: self.channel)

        channel.setMethodCallHandler(handle)
    }

    func getCameraPosition(onSuccess: @escaping (_ cameraPosition: [String: Any]) -> Void) {
        let position = kakaoMap.getPosition(CGPoint(x: 0.5, y: 0.5))
        var payload: [String: Any] = [
            "zoomLevel": kakaoMap.zoomLevel,
            "tiltAngle": kakaoMap.tiltAngle,
            "rotationAngle": kakaoMap.rotationAngle,
            "height": kakaoMap.cameraHeight,
        ]
        payload.merge(position.toMessageable()) { current, _ in current }
        onSuccess(payload)
    }

    func moveCamera(
        cameraUpdate: CameraUpdate,
        cameraAnimation: CameraAnimationOptions?,
        onSuccess: (Any?) -> Void
    ) {
        if cameraAnimation == nil {
            kakaoMap.moveCamera(cameraUpdate)
            onSuccess(nil)
            return
        }
        kakaoMap.animateCamera(cameraUpdate: cameraUpdate, options: cameraAnimation!)
        onSuccess(nil)
    }

    func setEventHandler(event: UInt8) {
        if KakaoMapEvent.CameraMoveStart.compare(value: event) {
            kakaoMap.addCameraWillMovedEventHandler(target: cameraListener, handler: CameraListener.onCameraWillMovedEvent)
        }
        if KakaoMapEvent.CameraMoveEnd.compare(value: event) {
            kakaoMap.addCameraStoppedEventHandler(target: cameraListener, handler: CameraListener.onCameraStoppedEvent)
        }
        if KakaoMapEvent.CompassClick.compare(value: event) {
            kakaoMap.addCameraStoppedEventHandler(target: mapClickListener, handler: MapClickListener.onCompassTappedEvent)
        }
        if KakaoMapEvent.MapClick.compare(value: event) {
            kakaoMap.addMapTappedEventHandler(target: mapClickListener, handler: MapClickListener.onViewInteractionEvent)
        }
        if KakaoMapEvent.TerrainClick.compare(value: event) {
            kakaoMap.addTerrainTappedEventHandler(target: mapClickListener, handler: MapClickListener.onTerrainTappedEvent)
        }
        if KakaoMapEvent.TerrainLongClick.compare(value: event) {
            kakaoMap.addTerrainLongPressedEventHandler(target: mapClickListener, handler: MapClickListener.onTerrainLongPressedEvent)
        }
        if KakaoMapEvent.PoiClick.compare(value: event) || KakaoMapEvent.LodPoiClick.compare(value: event) {
            kakaoMap.addPoisTappedEventHandler(target: poiClickListener, handler: PoiClickListener.onPoisInteractionEvent)
        }
    }

    func setGestureEnable(gestureType: GestureType, enable: Bool, onSuccess: (Any?) -> Void) {
        kakaoMap.setGestureEnable(type: gestureType, enable: enable)
        onSuccess(nil)
    }

    func getBuildingHeightScale(onSuccess: (Float) -> Void) {
        onSuccess(kakaoMap.buildingScale)
    }

    func setBuildingHeightScale(scale: Float, onSuccess: (Any?) -> Void) {
        kakaoMap.buildingScale = scale
        onSuccess(nil)
    }

    func onMapReady(kakaoMap: KakaoMap) {
        self.kakaoMap = kakaoMap
        overlayController = OverlayController(channel: overlayChannel, kakaoMap: kakaoMap)
        channel.invokeMethod("onMapReady", arguments: nil)
    }

    func onMapDestroy() {
        channel.invokeMethod("onMapDestroy", arguments: nil)
    }

    func onMapResumed() {
        channel.invokeMethod("onMapResumed", arguments: nil)
    }

    func onMapPaused() {
        channel.invokeMethod("onMapPaused", arguments: nil)
    }

    func onMapError(error: Error) {
        if error is BaseError {
            channel.invokeMethod("onMapError", arguments: [
                "className": "\(error.self)",
                "message": (error as! BaseError).errorCode,
                "errorCode": (error as! BaseError).message,
            ])
            return
        }
        channel.invokeMethod("onMapError", arguments: [
            "className": "\(error.self)",
        ])
    }
}
