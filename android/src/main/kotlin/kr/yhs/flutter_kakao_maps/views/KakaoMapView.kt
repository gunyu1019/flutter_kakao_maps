package kr.yhs.flutter_kakao_maps.views

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.MapView
import com.kakao.vectormap.camera.CameraPosition
import com.kakao.vectormap.camera.CameraUpdateFactory
import io.flutter.plugin.platform.PlatformView
import kr.yhs.flutter_kakao_maps.controller.KakaoMapController
import kr.yhs.flutter_kakao_maps.model.KakaoMapOption

class KakaoMapView(
  private val activity: Activity,
  context: Context,
  private val controller: KakaoMapController,
  private val option: KakaoMapOption,
  private val recreateMapViewOnResume: Boolean,
  recreateMapViewDelayMillis: Long,
  private val recoverGLSurfaceViewOnResume: Boolean,
) : PlatformView, Application.ActivityLifecycleCallbacks {
  private val container = FrameLayout(context)
  private val recreateDelayMillis = recreateMapViewDelayMillis.coerceAtLeast(0L)
  private var mapView = createMapView(option)
  private lateinit var kakaoMap: KakaoMap
  private var lastCameraPosition: CameraPosition? = null
  private var pendingCameraPosition: CameraPosition? = null
  private var isActivityResumed = false
  private var wasActivityPaused = false
  private var isDisposed = false
  private var pendingRecreateRunnable: Runnable? = null
  private var pendingRecovery = false
  private var pendingRecoveryRunnable: Runnable? = null
  private var pendingRecoveryTimeoutRunnable: Runnable? = null

  init {
    container.addView(mapView, matchParentLayoutParams())
    activity.application.registerActivityLifecycleCallbacks(this)
  }

  override fun getView(): View = container

  override fun dispose() {
    disposeMapView()
    controller.dispose()
  }

  /* Application.LifeCycleCallback Handler */
  override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit

  override fun onActivityStarted(activity: Activity) = Unit

  override fun onActivityResumed(activity: Activity) {
    if (activity != this.activity) return
    if (pendingRecreate) {
      wasActivityPaused = false
      mapView.resume()
      scheduleMapViewRecreation()
      return
    }
    if (recoveryActive) {
      wasActivityPaused = false
      // Resume normally first; recovery only adds the fork GL-thread un-pause if the
      // engine rehost (detach/reattach) pauses the view again after this point.
      mapView.resume()
      pendingRecovery = true
      val timeoutRunnable = Runnable {
        pendingRecoveryTimeoutRunnable = null
        if (pendingRecovery) {
          pendingRecovery = false
        }
      }
      pendingRecoveryTimeoutRunnable = timeoutRunnable
      container.postDelayed(timeoutRunnable, 600L)
      return
    }
    wasActivityPaused = false
    mapView.resume()
  }

  override fun onActivityPaused(activity: Activity) {
    if (activity != this.activity) return
    isActivityResumed = false
    wasActivityPaused = true
    cancelPendingMapViewRecreation()
    cancelPendingRecovery()
    captureCameraPosition()
    mapView.pause()
  }

  override fun onActivityStopped(activity: Activity) = Unit

  override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit

  override fun onActivityDestroyed(activity: Activity) {
    if (activity != this.activity) return
    disposeMapView()
  }

  private fun createMapView(startOption: KakaoMapOption): MapView {
    val mapView = MapView(activity)
    val wrappedOption = startOption.also { it.setOnReady(::onMapReady) }
    controller.mapView = mapView

    mapView.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
      override fun onViewAttachedToWindow(v: View) {
        if (pendingRecovery) {
          cancelPendingRecoveryTimeout()
          val recoveryRunnable = Runnable {
            pendingRecoveryRunnable = null
            executeGLSurfaceViewRecovery()
          }
          pendingRecoveryRunnable = recoveryRunnable
          container.post(recoveryRunnable)
        }
      }
      override fun onViewDetachedFromWindow(v: View) = Unit
    })

    mapView.start(controller, wrappedOption)
    return mapView
  }

  private fun onMapReady(map: KakaoMap) {
    kakaoMap = map
    pendingCameraPosition?.let { cameraPosition ->
      map.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
      lastCameraPosition = cameraPosition
      pendingCameraPosition = null
    } ?: run {
      captureCameraPosition()
    }
    controller.onMapReady(map)
  }

  private fun scheduleMapViewRecreation() {
    cancelPendingMapViewRecreation()
    val runnable = Runnable {
      pendingRecreateRunnable = null
      recreateMapView()
    }
    pendingRecreateRunnable = runnable
    container.postDelayed(runnable, recreateDelayMillis)
  }

  private fun cancelPendingMapViewRecreation() {
    pendingRecreateRunnable?.let(container::removeCallbacks)
    pendingRecreateRunnable = null
  }

  private fun cancelPendingRecoveryTimeout() {
    pendingRecoveryTimeoutRunnable?.let(container::removeCallbacks)
    pendingRecoveryTimeoutRunnable = null
  }

  private fun cancelPendingRecovery() {
    cancelPendingRecoveryTimeout()
    pendingRecoveryRunnable?.let(container::removeCallbacks)
    pendingRecoveryRunnable = null
    pendingRecovery = false
  }

  private fun executeGLSurfaceViewRecovery() {
    if (isDisposed) return
    val surfaceView = runCatching { mapView.getSurfaceView() }.getOrNull()

    // Primary: cast to Kakao fork GLSurfaceView and call onResume()
    val castResult = runCatching {
      val glSurfaceView = surfaceView as? com.kakao.vectormap.graphics.gl.GLSurfaceView
      if (glSurfaceView != null) {
        glSurfaceView.onResume()
        true
      } else {
        false
      }
    }.getOrElse {
      false
    }

    // Fallback: reflection if cast yielded null (e.g. Vulkan surface view)
    if (!castResult && surfaceView != null) {
      runCatching {
        surfaceView.javaClass.getMethod("onResume").invoke(surfaceView)
      }
    }

    runCatching {
      mapView.resume()
    }

    pendingRecovery = false
  }

  private fun recreateMapView() {
    if (isDisposed) return
    val cameraPosition = captureCameraPosition()
    pendingCameraPosition = cameraPosition
    val oldMapView = mapView
    oldMapView.finish()
    container.removeView(oldMapView)

    val startOption = cameraPosition?.let(option::copyWithCameraPosition) ?: option
    mapView = createMapView(startOption)
    container.addView(mapView, matchParentLayoutParams())
    if (isActivityResumed) {
      mapView.resume()
    }
  }

  private fun captureCameraPosition(): CameraPosition? {
    if (!::kakaoMap.isInitialized) return lastCameraPosition
    lastCameraPosition =
      runCatching { kakaoMap.cameraPosition }.getOrElse { lastCameraPosition }
    return lastCameraPosition
  }

  private fun disposeMapView() {
    if (isDisposed) return
    isDisposed = true
    cancelPendingMapViewRecreation()
    cancelPendingRecovery()
    mapView.finish()
    container.removeAllViews()
    activity.application.unregisterActivityLifecycleCallbacks(this)
  }

  private fun matchParentLayoutParams(): FrameLayout.LayoutParams {
    return FrameLayout.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT,
    )
  }
}
