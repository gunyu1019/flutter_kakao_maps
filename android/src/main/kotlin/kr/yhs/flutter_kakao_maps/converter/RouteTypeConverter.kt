package kr.yhs.flutter_kakao_maps.converter

import com.kakao.vectormap.CurveType
import com.kakao.vectormap.route.RouteLineManager
import com.kakao.vectormap.route.RouteLineOptions
import com.kakao.vectormap.route.RouteLinePattern
import com.kakao.vectormap.route.RouteLineSegment
import com.kakao.vectormap.route.RouteLineStyle
import com.kakao.vectormap.route.RouteLineStyles
import com.kakao.vectormap.route.RouteLineStylesSet
import com.kakao.vectormap.utils.MapUtils
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asLatLng
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asFloat
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asList
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString
import kr.yhs.flutter_kakao_maps.converter.ReferenceTypeConverter.asBitmap

object RouteTypeConverter {
  fun Any.asRouteLinePattern(): RouteLinePattern =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      return RouteLinePattern.from(
          rawPayload["patternImage"]!!.asBitmap(),
          rawPayload["symbolImage"]?.asBitmap(),
          rawPayload["distance"]!!.asFloat(),
        )
        .apply {
          rawPayload["pinStart"]?.asBoolean()?.let(::setPinStart)
          rawPayload["pinEnd"]?.asBoolean()?.let(::setPinEnd)
        }
    }

  fun Any.asRouteLineStyle(): RouteLineStyle =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      return RouteLineStyle.from(
          rawPayload["lineWidth"]!!.asFloat(),
          rawPayload["color"]!!.asInt(),
          rawPayload["strokeWidth"]?.asFloat() ?: 0.0F,
          rawPayload["strokeColor"]?.asInt() ?: 0,
        )
        .apply {
          rawPayload["pattern"]?.asRouteLinePattern()?.let(::setPattern)
          rawPayload["zoomLevel"]?.asInt()?.let(::setZoomLevel)
        }
    }

  fun Any.asRouteLineStyles(): RouteLineStyles =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val style: MutableList<RouteLineStyle> = mutableListOf(rawPayload.asRouteLineStyle())
      rawPayload["otherStyle"]?.asList<Map<String, Any?>>()?.map { e ->
        style.add(e.asRouteLineStyle())
      }
      return RouteLineStyles.from(style.toList())
    }

  fun Any.asRouteStylesSet(): RouteLineStylesSet =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      return RouteLineStylesSet.from(
        rawPayload["styleId"]?.asString() ?: MapUtils.getUniqueId(),
        rawPayload["styles"]!!.asList<Any>().map { element -> element.asRouteLineStyles() },
      )
    }

  fun Any.asRouteSegment(routeManager: RouteLineManager, index: Int? = null): RouteLineSegment =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      // val styleSets = routeManager.getStylesSet(rawPayload["styleId"]!!.asString())
      //
      // Temporary Actions
      // https://devtalk.kakao.com/t/bug-android-kakaomap-sdk-routemanager-getstylesset/142232
      val styleSets =
        routeManager.addStylesSet(
          RouteLineStylesSet.from(rawPayload["styleId"]!!.asString(), listOf())
        )
      val styleIndex = index ?: rawPayload["styleIndex"]?.asInt() ?: 0

      return RouteLineSegment.from().apply {
        styleSets.styles[styleIndex].let(::setStyles)
        rawPayload["points"]!!
          .asList<Any>()
          .map { element: Any -> element.asLatLng() }
          .let(::setPoints)
        rawPayload["curveType"]?.asInt()?.let(CurveType::getEnum)?.let(::setCurveType)
      }
    }

  fun Any.asRouteOption(routeManager: RouteLineManager): RouteLineOptions =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val segment = rawPayload.asRouteSegment(routeManager, 0)
      return ((rawPayload["id"]?.asString()?.let { RouteLineOptions.from(it, segment) })
          ?: RouteLineOptions.from(segment))
        .apply { rawPayload["zOrder"]?.asInt()?.let(::setZOrder) }
    }

  fun Any.asRouteMultipleOption(routeManager: RouteLineManager): RouteLineOptions =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val segment =
        rawPayload["routes"]!!.asList<Any>().map { payload -> payload.asRouteSegment(routeManager) }
      return ((rawPayload["id"]?.asString()?.let { RouteLineOptions.from(it, segment) })
          ?: RouteLineOptions.from(segment))
        .apply { rawPayload["zOrder"]?.asInt()?.let(::setZOrder) }
    }
}
