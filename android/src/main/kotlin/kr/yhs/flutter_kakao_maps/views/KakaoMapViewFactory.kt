package kr.yhs.flutter_kakao_maps.views

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kr.yhs.flutter_kakao_maps.FlutterKakaoMapsPlugin
import kr.yhs.flutter_kakao_maps.controller.KakaoMapController
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.model.KakaoMapOption

class KakaoMapViewFactory(private val activity: Activity, private val messenger: BinaryMessenger) :
  PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val channel = MethodChannel(messenger, FlutterKakaoMapsPlugin.createViewChannelName(viewId))
    val convertedArgs = args!!.asMap<Any?>()

    val overlayChannel =
      MethodChannel(messenger, FlutterKakaoMapsPlugin.createOverlayChannelName(viewId))

    val controller = KakaoMapController(viewId, context, channel, overlayChannel)
    val option = KakaoMapOption.fromMessageable(controller::onMapReady, convertedArgs)
    return KakaoMapView(
      activity = activity,
      context = context,
      controller = controller,
      viewId = viewId,
      option = option,
      channel = channel,
    )
  }
}
