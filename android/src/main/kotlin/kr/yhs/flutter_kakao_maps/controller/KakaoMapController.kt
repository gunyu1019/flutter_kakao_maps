package kr.yhs.flutter_kakao_maps.controller

import android.content.Context
import com.kakao.vectormap.GestureType
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.MapAuthException
import com.kakao.vectormap.MapLifeCycleCallback
import com.kakao.vectormap.MapOverlay
import com.kakao.vectormap.MapType
import com.kakao.vectormap.MapView
import com.kakao.vectormap.camera.CameraAnimation
import com.kakao.vectormap.camera.CameraPosition
import com.kakao.vectormap.camera.CameraUpdate
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.controller.overlay.OverlayController
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.toMessageable
import kr.yhs.flutter_kakao_maps.converter.ReferenceTypeConverter.toMessageable
import kr.yhs.flutter_kakao_maps.listener.CameraListener
import kr.yhs.flutter_kakao_maps.listener.MapClickListener
import kr.yhs.flutter_kakao_maps.listener.PoiClickListener
import kr.yhs.flutter_kakao_maps.model.DefaultGUIType
import kr.yhs.flutter_kakao_maps.model.KakaoMapEvent

class KakaoMapController(
  private val viewId: Int,
  private val context: Context,
  private val channel: MethodChannel,
  private val overlayChannel: MethodChannel,
) : KakaoMapControllerHandler, KakaoMapControllerSender, MapLifeCycleCallback() {
  private lateinit var kakaoMap: KakaoMap
  private lateinit var overlayController: OverlayController
  public lateinit var mapView: MapView

  // listener
  private val cameraListener = CameraListener(channel)
  private val poiClickListener = PoiClickListener(channel)
  private val mapClickListener = MapClickListener(channel)

  init {
    channel.setMethodCallHandler(::handle)
  }

  /* Handler */
  override fun getCameraPosition(onSuccess: (cameraPosition: Map<String, Any>) -> Unit) {
    kakaoMap.getCameraPosition(
      object : KakaoMap.OnCameraPositionListener {
        override fun onCameraPosition(cameraPosition: CameraPosition) {
          cameraPosition.toMessageable().let(onSuccess)
        }
      }
    )
  }

  override fun moveCamera(
    cameraUpdate: CameraUpdate,
    cameraAnimation: CameraAnimation?,
    onSuccess: (Any?) -> Unit,
  ) {
    if (cameraAnimation != null) {
      kakaoMap.moveCamera(cameraUpdate, cameraAnimation)
    } else {
      kakaoMap.moveCamera(cameraUpdate)
    }
    onSuccess(null)
  }

  override fun setGestureEnable(
    gestureType: GestureType,
    enable: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    kakaoMap.setGestureEnable(gestureType, enable)
    onSuccess(null)
  }

  override fun setEventHandler(event: Int) {
    if (KakaoMapEvent.CameraMoveStart.compare(event)) {
      kakaoMap.setOnCameraMoveStartListener(cameraListener)
    }
    if (KakaoMapEvent.CameraMoveEnd.compare(event)) {
      kakaoMap.setOnCameraMoveEndListener(cameraListener)
    }
    if (KakaoMapEvent.CompassClick.compare(event)) {
      kakaoMap.setOnCompassClickListener(mapClickListener)
    }
    if (KakaoMapEvent.MapClick.compare(event)) {
      kakaoMap.setOnViewportClickListener(mapClickListener)
    }
    if (KakaoMapEvent.TerrainClick.compare(event)) {
      kakaoMap.setOnTerrainClickListener(mapClickListener)
    }
    if (KakaoMapEvent.TerrainLongClick.compare(event)) {
      kakaoMap.setOnTerrainLongClickListener(mapClickListener)
    }
    if (KakaoMapEvent.PoiClick.compare(event)) {
      kakaoMap.setOnLabelClickListener(poiClickListener)
    }
    if (KakaoMapEvent.LodPoiClick.compare(event)) {
      kakaoMap.setOnLodLabelClickListener(poiClickListener)
    }
  }

  override fun fromScreenPoint(x: Int, y: Int, onSuccess: (Map<String, Any>?) -> Unit) {
    kakaoMap.fromScreenPoint(x, y)?.toMessageable().let(onSuccess::invoke)
  }

  override fun toScreenPoint(position: LatLng, onSuccess: (Map<String, Any>?) -> Unit) {
    kakaoMap.toScreenPoint(position)?.toMessageable().let(onSuccess::invoke)
  }

  override fun clearCache(onSuccess: (Any?) -> Unit) {
    kakaoMap.clearAllCache()
    onSuccess.invoke(null)
  }

  override fun clearDiskCache(onSuccess: (Any?) -> Unit) {
    kakaoMap.clearDiskCache()
    onSuccess.invoke(null)
  }

  override fun canPositionVisible(
    zoomLevel: Int,
    position: List<LatLng>,
    onSuccess: (Boolean) -> Unit,
  ) {
    kakaoMap.canShowMapPoints(zoomLevel, *position.toTypedArray()).let(onSuccess::invoke)
  }

  override fun changeMapType(mapType: MapType, onSuccess: (Any?) -> Unit) {
    kakaoMap.changeMapType(mapType)
    onSuccess.invoke(null)
  }

  override fun overlayVisible(
    overlayType: MapOverlay,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    if (visible) {
      kakaoMap.showOverlay(overlayType)
    } else {
      kakaoMap.hideOverlay(overlayType)
    }
    onSuccess.invoke(null)
  }

  override fun getBuildingHeightScale(onSuccess: (Float) -> Unit) {
    kakaoMap.buildingHeightScale.let(onSuccess::invoke)
  }

  override fun setBuildingHeightScale(scale: Float, onSuccess: (Any?) -> Unit) {
    kakaoMap.buildingHeightScale = scale
  }

  override fun defaultGUIvisible(
    type: DefaultGUIType,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    when (type) {
      DefaultGUIType.compass -> {
        if (visible) kakaoMap.compass?.show() else kakaoMap.compass?.hide()
      }
      DefaultGUIType.scale -> {
        if (visible) kakaoMap.scaleBar?.show() else kakaoMap.scaleBar?.hide()
      }
      DefaultGUIType.logo -> throw NotImplementedError("Logo can't setup visible.")
    }
    onSuccess.invoke(null)
  }

  override fun defaultGUIposition(
    type: DefaultGUIType,
    gravity: Int,
    x: Float,
    y: Float,
    onSuccess: (Any?) -> Unit,
  ) {
    when (type) {
      DefaultGUIType.compass -> kakaoMap.compass?.setPosition(gravity, x, y)
      DefaultGUIType.scale -> kakaoMap.scaleBar?.setPosition(gravity, x, y)
      DefaultGUIType.logo -> kakaoMap.logo?.setPosition(gravity, x, y)
    }
    onSuccess.invoke(null)
  }

  override fun scaleAutohide(autohide: Boolean, onSuccess: (Any?) -> Unit) {
    kakaoMap.scaleBar?.setAutoHide(autohide)
    onSuccess.invoke(null)
  }

  override fun scaleAnimationTime(
    fadeIn: Int,
    fadeOut: Int,
    retention: Int,
    onSuccess: (Any?) -> Unit,
  ) {
    kakaoMap.scaleBar?.setFadeInOutTime(fadeIn, fadeOut, retention)
    onSuccess.invoke(null)
  }

  override fun pause(onSuccess: (Any?) -> Unit) {
    mapView.pause()
    onSuccess.invoke(null)
  }

  override fun resume(onSuccess: (Any?) -> Unit) {
    mapView.resume()
    onSuccess.invoke(null)
  }

  override fun finish(onSuccess: (Any?) -> Unit) {
    mapView.finish()
    onSuccess.invoke(null)
  }

  /* Sender */
  override fun onMapReady(kakaoMap: KakaoMap) {
    this.kakaoMap = kakaoMap
    this.overlayController = OverlayController(overlayChannel, kakaoMap)
    channel.invokeMethod("onMapReady", null)
  }

  override fun onMapDestroy() {
    channel.invokeMethod("onMapDestroy", null)
  }

  override fun onMapResumed() {
    channel.invokeMethod("onMapResumed", null)
  }

  override fun onMapPaused() {
    channel.invokeMethod("onMapPaused", null)
  }

  override fun onMapError(exception: Exception) {
    if (exception is MapAuthException) {
      channel.invokeMethod(
        "onMapError",
        mapOf(
          "className" to "MapAuthException",
          "errorCode" to exception.errorCode,
          "message" to exception.message,
        ),
      )
      return
    }
    channel.invokeMethod(
      "onMapError",
      mapOf("className" to exception::javaClass.name, "message" to exception.message),
    )
  }

  fun dispose() {
    channel.setMethodCallHandler(null)
    overlayChannel.setMethodCallHandler(null)
  }
}
