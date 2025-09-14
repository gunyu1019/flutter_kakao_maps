package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import com.kakao.vectormap.shape.DimScreenCover
import com.kakao.vectormap.shape.DimScreenLayer
import com.kakao.vectormap.shape.DimScreenManager
import com.kakao.vectormap.shape.DotPoints
import com.kakao.vectormap.shape.MapPoints
import com.kakao.vectormap.shape.Polygon
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

interface DimScreenControllerHandler {
  val dimScreenManager: DimScreenManager?

  val dimScreenLayer: DimScreenLayer?
    get() = dimScreenManager?.getDimScreenLayer()

  fun dimScreenHandle(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments!!.asMap<Any?>()
    if (dimScreenManager == null || dimScreenLayer == null) {
      throw NullPointerException("DimScreenManager is null.")
    }

    val polygonShape = arguments["polygonId"]?.asString()?.let(dimScreenLayer!!::getPolygon)

    when (call.method) {
      "setColor" -> setDimColor(arguments["color"]!!.asInt(), result::success)
      "setVisible" -> setDimVisible(arguments["visible"]!!.asBoolean(), result::success)
      "setDimCover" ->
        setDimCorver(
          arguments["cover"]!!.asString().let { value: String ->
            DimScreenCover.entries.first { it.name == value }
          },
          result::success,
        )
      "addHighlightPolygonShape" -> {
        val rawOption = arguments["polygon"]!!.asMap<Any>()
        val style = dimScreenManager!!.getPolygonStyles(rawOption["styleId"]!!.asString())
        val option = rawOption.asPolygonOption(style)
        addDimHighlightPolygonShape(option, result::success)
      }
      "removeHighlightPolygonShape" ->
        removeDimHighlightPolygonShape(arguments["polygonId"]!!.toString(), result::success)
      "changePolygonVisible" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolygonVisible(polygonShape!!, visible, result::success)
      }
      "changePolygon" -> {
        val styleId = arguments["styleId"]?.asString()
        val position = arguments["position"]!!.asMap<Any?>()
        if (position["type"]!!.asInt() == 0) {
          val mapPosition = position.asMapPoints().let { Arrays.asList(it) }
          changePolygonFromMapPoints(polygonShape!!, styleId!!, mapPosition, result::success)
        } else {
          val dotPosition: List<DotPoints> = position.asDotPoints().let { Arrays.asList(it) }
          changePolygonFromDotPoints(polygonShape!!, styleId!!, dotPosition, result::success)
        }
      }
    }
  }

  fun setDimColor(color: Int, onSuccess: (Any?) -> Unit)

  fun setDimVisible(visible: Boolean, onSuccess: (Any?) -> Unit)

  fun setDimCorver(cover: DimScreenCover, onSuccess: (Any?) -> Unit)

  fun addDimHighlightPolygonShape(shape: PolygonOptions, onSuccess: (String?) -> Unit)

  fun removeDimHighlightPolygonShape(polygonId: String, onSuccess: (Any?) -> Unit)

  fun changePolygonVisible(shape: Polygon, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changePolygonFromMapPoints(
    shape: Polygon,
    styleId: String,
    position: List<MapPoints>,
    onSuccess: (Any?) -> Unit,
  )

  fun changePolygonFromDotPoints(
    shape: Polygon,
    styleId: String,
    position: List<DotPoints>,
    onSuccess: (Any?) -> Unit,
  )
}
