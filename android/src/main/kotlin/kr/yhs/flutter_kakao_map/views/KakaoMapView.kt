package kr.yhs.flutter_kakao_map.views

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.util.Base64
import android.util.Log
import android.view.View
import android.os.Bundle
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.KakaoMapReadyCallback
import com.kakao.vectormap.KakaoMapSdk
import com.kakao.vectormap.MapLifeCycleCallback
import com.kakao.vectormap.MapView
import com.kakao.vectormap.MapReadyCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.lang.Exception
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import kr.yhs.flutter_kakao_map.model.KakaoMapOption
import kr.yhs.flutter_kakao_map.controller.KakaoMapController
import kr.yhs.flutter_kakao_map.controller.KakaoMapControllerSender

class KakaoMapView(
    private val activity: Activity,
    private val context: Context,
    private val viewId: Int,
    private val option: KakaoMapOption,
    private val channel: MethodChannel
): PlatformView, Application.ActivityLifecycleCallbacks, MapLifeCycleCallback() {
    private lateinit var mapView: MapView
    private lateinit var kakaoMap: KakaoMap
    private lateinit var controller: KakaoMapControllerSender

    init {
        option.setOnReady(::onMapReady)
        activity.registerActivityLifecycleCallbacks(this)
    }

    override fun getView(): View = mapView

    override fun dispose() {
        mapView = MapView(activity)
        activity.unregisterActivityLifecycleCallbacks(this)
        (controller as KakaoMapController).dispose()
    }

    fun onMapReady(map: KakaoMap) {
        kakaoMap = map
        controller = KakaoMapController(context, channel, kakaoMap)
        controller.onMapReady()
    }

    override fun onMapDestroy() {
        controller.onMapDestroyed()
    }

    override fun onMapError(exception: Exception) {
        controller.onMapException()
    }

    /* Application.LifeCycleCallback Handler */
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit

    override fun onActivityStarted(activity: Activity) {
        mapView.start(this, option)
    }

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
    }
}
