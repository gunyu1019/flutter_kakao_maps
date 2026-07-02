package kr.yhs.flutter_kakao_maps.views

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.ContextWrapper
import android.content.MutableContextWrapper
import android.hardware.display.DisplayManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.SurfaceHolder
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

private const val PV_TAG = "PV-VD-DEBUG"

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

  private val displayManager: DisplayManager =
    context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager

  private val displayListener = object : DisplayManager.DisplayListener {
    override fun onDisplayAdded(displayId: Int) {
      val name = displayManager.getDisplay(displayId)?.name ?: "<unknown>"
      Log.i(PV_TAG, "[displayAdded] t=${SystemClock.uptimeMillis()} displayId=$displayId name=\"$name\"")
    }
    override fun onDisplayRemoved(displayId: Int) {
      Log.i(PV_TAG, "[displayRemoved] t=${SystemClock.uptimeMillis()} displayId=$displayId")
    }
    override fun onDisplayChanged(displayId: Int) {
      val name = displayManager.getDisplay(displayId)?.name ?: "<unknown>"
      Log.i(PV_TAG, "[displayChanged] t=${SystemClock.uptimeMillis()} displayId=$displayId name=\"$name\"")
    }
  }

  init {
    // Log construction: context class chain
    val ctxChain = buildContextChain(context, 4)
    val isMutable = context is MutableContextWrapper
    Log.i(PV_TAG, "[init] t=${SystemClock.uptimeMillis()} view=KakaoMapView@${Integer.toHexString(System.identityHashCode(this))} container@${Integer.toHexString(System.identityHashCode(container))} contextChain=$ctxChain isMutableContext=$isMutable recreateOnResume=$recreateMapViewOnResume recoverGLSurfaceView=$recoverGLSurfaceViewOnResume")
    if (recreateMapViewOnResume && recoverGLSurfaceViewOnResume) {
      Log.i(PV_TAG, "[init] recreation overrides recovery")
    }

    container.addView(mapView, matchParentLayoutParams())
    activity.application.registerActivityLifecycleCallbacks(this)
    displayManager.registerDisplayListener(displayListener, Handler(Looper.getMainLooper()))

    // Attach state listener on the container
    container.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
      override fun onViewAttachedToWindow(v: View) {
        Log.i(PV_TAG, "[attach] t=${SystemClock.uptimeMillis()} view=${v.javaClass.simpleName}@${Integer.toHexString(System.identityHashCode(v))} displayId=${v.display?.displayId} parents=${buildParentChain(v, 5)}")
      }
      override fun onViewDetachedFromWindow(v: View) {
        Log.i(PV_TAG, "[detach] t=${SystemClock.uptimeMillis()} view=${v.javaClass.simpleName}@${Integer.toHexString(System.identityHashCode(v))} displayId=${v.display?.displayId} parents=${buildParentChain(v, 5)}")
      }
    })
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
    val pendingRecreate = recreateMapViewOnResume && wasActivityPaused
    val recoveryActive = recoverGLSurfaceViewOnResume && !recreateMapViewOnResume && wasActivityPaused
    Log.i(PV_TAG, "[activityResumed] t=${SystemClock.uptimeMillis()} pendingRecreate=$pendingRecreate recoveryActive=$recoveryActive")
    isActivityResumed = true
    if (pendingRecreate) {
      wasActivityPaused = false
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
          Log.i(PV_TAG, "[recovery] no engine rehost detected within 600ms; skipping")
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
    Log.i(PV_TAG, "[activityPaused] t=${SystemClock.uptimeMillis()} recreateOnResume=$recreateMapViewOnResume")
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
    Log.i(PV_TAG, "[createMapView] t=${SystemClock.uptimeMillis()} mapView@${Integer.toHexString(System.identityHashCode(mapView))}")
    val wrappedOption = startOption.also { it.setOnReady(::onMapReady) }
    controller.mapView = mapView

    // Attach state listener on mapView
    mapView.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
      override fun onViewAttachedToWindow(v: View) {
        Log.i(PV_TAG, "[attach] t=${SystemClock.uptimeMillis()} view=${v.javaClass.simpleName}@${Integer.toHexString(System.identityHashCode(v))} displayId=${v.display?.displayId} parents=${buildParentChain(v, 5)}")
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
      override fun onViewDetachedFromWindow(v: View) {
        Log.i(PV_TAG, "[detach] t=${SystemClock.uptimeMillis()} view=${v.javaClass.simpleName}@${Integer.toHexString(System.identityHashCode(v))} displayId=${v.display?.displayId} parents=${buildParentChain(v, 5)}")
      }
    })

    // Register SurfaceHolder.Callback on mapView's SurfaceView
    runCatching {
      val surfaceView = mapView.getSurfaceView()
      surfaceView?.holder?.addCallback(object : SurfaceHolder.Callback {
        override fun surfaceCreated(holder: SurfaceHolder) {
          val surface = holder.surface
          Log.i(PV_TAG, "[surfaceCreated] t=${SystemClock.uptimeMillis()} surface@${Integer.toHexString(System.identityHashCode(surface))} isValid=${surface.isValid}")
        }
        override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
          val surface = holder.surface
          Log.i(PV_TAG, "[surfaceChanged] t=${SystemClock.uptimeMillis()} surface@${Integer.toHexString(System.identityHashCode(surface))} isValid=${surface.isValid} w=$width h=$height format=$format")
        }
        override fun surfaceDestroyed(holder: SurfaceHolder) {
          val surface = holder.surface
          Log.i(PV_TAG, "[surfaceDestroyed] t=${SystemClock.uptimeMillis()} surface@${Integer.toHexString(System.identityHashCode(surface))} isValid=${surface.isValid}")
        }
      })
    }.onFailure { e ->
      Log.i(PV_TAG, "[createMapView] surfaceHolder callback registration failed: $e")
    }

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
    Log.i(PV_TAG, "[scheduleRecreate] t=${SystemClock.uptimeMillis()} delayMs=$recreateDelayMillis")
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
    val engineStateBefore = runCatching { mapView.getEngineState() }.getOrElse { "unavailable" }
    Log.i(PV_TAG, "[recovery] engineState before=$engineStateBefore")

    // Primary: cast to Kakao fork GLSurfaceView and call onResume()
    val castResult = runCatching {
      val glSurfaceView = surfaceView as? com.kakao.vectormap.graphics.gl.GLSurfaceView
      if (glSurfaceView != null) {
        glSurfaceView.onResume()
        Log.i(PV_TAG, "[recovery] fork GLSurfaceView.onResume path=cast")
        true
      } else {
        false
      }
    }.getOrElse { e ->
      Log.w(PV_TAG, "[recovery] cast path failed: $e")
      false
    }

    // Fallback: reflection if cast yielded null (e.g. Vulkan surface view)
    if (!castResult && surfaceView != null) {
      runCatching {
        surfaceView.javaClass.getMethod("onResume").invoke(surfaceView)
        Log.i(PV_TAG, "[recovery] fork GLSurfaceView.onResume path=reflect")
      }.onFailure { e ->
        Log.w(PV_TAG, "[recovery] reflect path failed: $e; continuing")
      }
    }

    runCatching {
      mapView.resume()
      Log.i(PV_TAG, "[recovery] calling MapView.resume")
    }.onFailure { e ->
      Log.w(PV_TAG, "[recovery] MapView.resume failed: $e")
    }

    val engineStateAfter = runCatching { mapView.getEngineState() }.getOrElse { "unavailable" }
    Log.i(PV_TAG, "[recovery] engineState after=$engineStateAfter")
    pendingRecovery = false
  }

  private fun recreateMapView() {
    Log.i(PV_TAG, "[recreateMapView] t=${SystemClock.uptimeMillis()} isDisposed=$isDisposed")
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
    Log.i(PV_TAG, "[recreateMapView] done t=${SystemClock.uptimeMillis()} newMapView@${Integer.toHexString(System.identityHashCode(mapView))}")
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
    displayManager.unregisterDisplayListener(displayListener)
    Log.i(PV_TAG, "[dispose] t=${SystemClock.uptimeMillis()} view=KakaoMapView@${Integer.toHexString(System.identityHashCode(this))}")
  }

  private fun matchParentLayoutParams(): FrameLayout.LayoutParams {
    return FrameLayout.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT,
    )
  }

  private fun buildContextChain(context: Context, maxDepth: Int): String {
    val sb = StringBuilder()
    var ctx: Context? = context
    var depth = 0
    while (ctx != null && depth < maxDepth) {
      if (depth > 0) sb.append('>')
      sb.append(ctx.javaClass.simpleName)
      ctx = if (ctx is ContextWrapper) ctx.baseContext else null
      depth++
    }
    return sb.toString()
  }

  private fun buildParentChain(view: View, maxDepth: Int): String {
    val sb = StringBuilder()
    var v: ViewGroup? = view.parent as? ViewGroup
    var depth = 0
    while (v != null && depth < maxDepth) {
      if (depth > 0) sb.append('>')
      sb.append(v.javaClass.simpleName)
      v = v.parent as? ViewGroup
      depth++
    }
    return if (sb.isEmpty()) "<none>" else sb.toString()
  }
}
