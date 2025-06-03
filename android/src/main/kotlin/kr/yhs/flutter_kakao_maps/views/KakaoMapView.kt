package kr.yhs.flutter_kakao_maps.views

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.view.View
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.MapView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kr.yhs.flutter_kakao_maps.controller.KakaoMapController
import kr.yhs.flutter_kakao_maps.model.KakaoMapOption

class KakaoMapView(
  private val activity: Activity,
  private val context: Context,
  private val controller: KakaoMapController,
  private val viewId: Int,
  private val option: KakaoMapOption,
  private val channel: MethodChannel,
) : PlatformView, Application.ActivityLifecycleCallbacks {
  private val mapView = MapView(activity)
  private lateinit var kakaoMap: KakaoMap

  init {
    controller.mapView = mapView
    mapView.start(controller, option)
    activity.application.registerActivityLifecycleCallbacks(this)
  }

  override fun getView(): View = mapView

  override fun dispose() {
    activity.application.unregisterActivityLifecycleCallbacks(this)
    mapView.finish()
    controller.dispose()
  }

  /* Application.LifeCycleCallback Handler */
  override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit

  override fun onActivityStarted(activity: Activity) = Unit

  override fun onActivityResumed(activity: Activity) {
    if (activity != this.activity) return
    mapView.resume()
  }

  override fun onActivityPaused(activity: Activity) {
    if (activity != this.activity) return
    mapView.pause()
  }

  override fun onActivityStopped(activity: Activity) = Unit

  override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit

  override fun onActivityDestroyed(activity: Activity) {
    if (activity != this.activity) return
    mapView.finish()
    activity.application.unregisterActivityLifecycleCallbacks(this)
  }
}
