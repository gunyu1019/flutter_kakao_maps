package kr.yhs.flutter_kakao_maps.listener

import android.graphics.PointF
import com.kakao.vectormap.Compass
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.LatLng
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.toMessageable
import kr.yhs.flutter_kakao_maps.converter.ReferenceTypeConverter.toMessageable

class MapClickListener(private val channel: MethodChannel) :
  KakaoMap.OnCompassClickListener,
  KakaoMap.OnTerrainClickListener,
  KakaoMap.OnTerrainLongClickListener,
  KakaoMap.OnViewportClickListener {
  override fun onViewportClicked(kakaoMap: KakaoMap, position: LatLng, screenPoint: PointF) {
    channel.invokeMethod(
      "onMapClick",
      mapOf("point" to screenPoint.toMessageable(), "position" to position.toMessageable()),
    )
  }

  override fun onCompassClicked(kakaoMap: KakaoMap, compass: Compass?) {
    channel.invokeMethod("onCompassClick", null)
  }

  override fun onTerrainClicked(kakaoMap: KakaoMap, position: LatLng, screenPoint: PointF) {
    channel.invokeMethod(
      "onTerrainClick",
      mapOf("point" to screenPoint.toMessageable(), "position" to position.toMessageable()),
    )
  }

  override fun onTerrainLongClicked(kakaoMap: KakaoMap, position: LatLng, screenPoint: PointF) {
    channel.invokeMethod(
      "onTerrainLongClick",
      mapOf("point" to screenPoint.toMessageable(), "position" to position.toMessageable()),
    )
  }
}
