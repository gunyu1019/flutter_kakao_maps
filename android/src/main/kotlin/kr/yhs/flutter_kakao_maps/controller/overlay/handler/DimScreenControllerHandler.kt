package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import com.kakao.vectormap.shape.DotPoints
import com.kakao.vectormap.shape.MapPoints
import com.kakao.vectormap.shape.DimScreenManager
import com.kakao.vectormap.shape.DimScreenLayer
import com.kakao.vectormap.shape.DimScreenCover
import com.kakao.vectormap.shape.PolygonOptions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Arrays
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asDotPoints
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asMapPoints
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolygonOption
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolygonStylesSet
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolylineOption
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolylineStylesSet
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asShapeLayerOption

interface DimScreenControllerHandler {
  val dimScreenManager: DimScreenManager?

  val dimScreenLayer: DimScreenLayer?
    get = dimScreenManager?.getDimScreenLayer()
 
  fun dimScreenHandle(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments!!.asMap<Any?>()
    if (dimScreenManager == null) {
      throw NullPointerException("DimScreenManager is null.")
    }

    when (call.method) {
      "setColor" -> setDimColor(arguments["color"]!!.asInt(), result::success)
      "setVisible" -> setDimVisible(arguments["visible"]!!.asBoolean(), result::success)
      "setDimCorver" -> setDimCorver(arguments["cover"]!!.asString().let { value: String ->
          DimScreenCover.entries.first { it.name == value }
      }, result::success)
      "addHighlightPolygonShape" -> {}
      "removeHighlightPolygonShape" -> {}
    }
  }

  fun setDimColor(color: Int, onSuccess: (Any?) -> Unit);

  fun setDimVisible(visible: Boolean, onSuccess: (Any?) -> Unit);

  fun setDimCorver(cover: DimScreenCover, onSuccess: (Any?) -> Unit);

  fun addDimHighlightPolygonShape(shape: PolygonOptions, onSuccess: (String) -> Unit)

  fun removeDimHighlightPolygonShape(polygonId: String, onSuccess: (Any?) -> Unit);
}
