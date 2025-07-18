import Flutter
import KakaoMapsSDK

class KakaoMapController: KakaoMapControllerSender, KakaoMapControllerHandler {
    private let channel: FlutterMethodChannel
    private let overlayChannel: FlutterMethodChannel
    private let mapController: KMController

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
        overlayChannel: FlutterMethodChannel,
        mapController: KMController
    ) {
        self.channel = channel
        self.overlayChannel = overlayChannel
        self.mapController = mapController

        cameraListener = CameraListener(channel: self.channel)
        mapClickListener = MapClickListener(channel: self.channel)
        poiClickListener = PoiClickListener(channel: self.channel)

        channel.setMethodCallHandler(handle)
    }

    func getCameraPosition(onSuccess: @escaping (_ cameraPosition: [String: Any]) -> Void) {
        let position = kakaoMap.getPosition(CGPoint(x: kakaoMap.viewRect.width * 0.5, y: kakaoMap.viewRect.height * 0.5))
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
            kakaoMap.addCompassTappedEventHandler(target: mapClickListener, handler: MapClickListener.onCompassTappedEvent)
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
            poiClickListener.enable = true
        }
    }

    func fromScreenPoint(point: CGPoint, onSuccess: ([String: Double]) -> Void) {
        let position = kakaoMap.getPosition(point)
        onSuccess(position.toMessageable())
    }

    func toScreenPoint(position: MapPoint, onSuccess: ([String: Double]) -> Void) {
        let point = convertMapPointToPoint(kakaoMap: kakaoMap, position: position)
        onSuccess(point.toMessageable())
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

    func clearCache(onSuccess: (Any?) -> Void) {
        mapController.clearMemoryCache(kakaoMap.viewName())
        mapController.clearViewInfoCaches()
        onSuccess(nil)
    }

    func clearDiskCache(onSuccess: (Any?) -> Void) {
        mapController.clearDiskCache()
        onSuccess(nil)
    }

    func canPositionVisible(zoomLevel: Int, position: [MapPoint], onSuccess: (Bool) -> Void) {
        let visible = kakaoMap.canShow(mapPoints: position, atLevel: zoomLevel)
        onSuccess(visible)
    }

    func changeMapType(mapType: String, onSuccess _: (Any?) -> Void) {
        kakaoMap.changeViewInfo(appName: "openmap", viewInfoName: mapType)
    }

    func overlayVisible(overlayType: String, visible: Bool, onSuccess: (Any?) -> Void) {
        if visible {
            kakaoMap.showOverlay(overlayType)
        } else {
            kakaoMap.hideOverlay(overlayType)
        }
        onSuccess(nil)
    }

    func defaultGUIvisible(type: DefaultGUIType, visible: Bool, onSuccess: (Any?) -> Void) {
        switch type {
        case .compass:
            if visible {
                kakaoMap.showCompass()
            } else {
                kakaoMap.hideCompass()
            }
        case .scale:
            if visible {
                kakaoMap.showScaleBar()
            } else {
                kakaoMap.hideScaleBar()
            }
        case .logo:
            break
        }
        onSuccess(nil)
    }

    func defaultGUIposition(type: DefaultGUIType, gravity: GuiAlignment, position: CGPoint, onSuccess: (Any?) -> Void) {
        switch type {
        case .compass: kakaoMap.setCompassPosition(origin: gravity, position: position)
        case .scale: kakaoMap.setScaleBarPosition(origin: gravity, position: position)
        case .logo: kakaoMap.setLogoPosition(origin: gravity, position: position)
        }
        onSuccess(nil)
    }

    func scaleAutohide(autohide: Bool, onSuccess: (Any?) -> Void) {
        kakaoMap.setScaleBarAutoDisappear(autohide)
        onSuccess(nil)
    }

    func scaleAnimationTime(fadeIn: UInt32, fadeOut: UInt32, retention: UInt32, onSuccess: (Any?) -> Void) {
        kakaoMap.setScaleBarFadeInOutOption(
            FadeInOutOptions(
                fadeInTime: fadeIn,
                fadeOutTime: fadeOut,
                retentionTime: retention
            )
        )
        onSuccess(nil)
    }

    func pause(onSuccess: (Any?) -> Void) {
        mapController.pauseEngine()
        onSuccess(nil)
    }

    func resume(onSuccess: (Any?) -> Void) {
        mapController.activateEngine()
        onSuccess(nil)
    }

    func finish(onSuccess: (Any?) -> Void) {
        mapController.resetEngine()
        onSuccess(nil)
    }

    func onMapReady(kakaoMap: KakaoMap) {
        self.kakaoMap = kakaoMap
        overlayController = OverlayController(channel: overlayChannel, kakaoMap: kakaoMap, labelListener: poiClickListener)
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
