package kr.yhs.flutter_kakao_maps.converter

import com.kakao.vectormap.label.CompetitionType
import com.kakao.vectormap.label.CompetitionUnit
import com.kakao.vectormap.label.LabelLayerOptions
import com.kakao.vectormap.label.LabelManager
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyle
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.LabelTextBuilder
import com.kakao.vectormap.label.LabelTextStyle
import com.kakao.vectormap.label.LabelTransition
import com.kakao.vectormap.label.OrderingType
import com.kakao.vectormap.label.PolylineLabelOptions
import com.kakao.vectormap.label.PolylineLabelStyle
import com.kakao.vectormap.label.PolylineLabelStyles
import com.kakao.vectormap.label.TransformMethod
import com.kakao.vectormap.label.Transition
import com.kakao.vectormap.utils.MapUtils
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asLatLng
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asFloat
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asList
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asLong
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString
import kr.yhs.flutter_kakao_maps.converter.ReferenceTypeConverter.asBitmap
import kr.yhs.flutter_kakao_maps.converter.ReferenceTypeConverter.asPoint

object LabelTypeConverter {
  fun Any.asLabelTextStyle(): LabelTextStyle =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      LabelTextStyle.from(
          rawPayload["size"]!!.asInt(),
          rawPayload["color"]!!.asInt(),
          (rawPayload["strokeSize"] ?: 0).asInt(),
          (rawPayload["strokeColor"] ?: 0).asInt(),
        )
        .apply {
          rawPayload.get("font")?.asString()?.let(::setFont)
          rawPayload.get("characterSpace")?.asInt()?.let(::setCharacterSpace)
          rawPayload.get("lineSpace")?.asFloat()?.let(::setLineSpace)
          rawPayload.get("aspectRatio")?.asFloat()?.let(::setAspectRatio)
        }
    }

  fun Any.asLabelTransition(): LabelTransition =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      LabelTransition.from(
        Transition.getEnum(rawPayload["entrance"]!!.asInt()),
        Transition.getEnum(rawPayload["exit"]!!.asInt()),
      )
    }

  fun Any.asLabelStyle(): LabelStyle =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val labelStyle =
        if (rawPayload.get("icon") != null) {
          LabelStyle.from(rawPayload["icon"]!!.asBitmap())
        } else {
          LabelStyle.from()
        }
      labelStyle.apply {
        rawPayload["anchor"]?.asPoint().let(::setAnchorPoint)
        rawPayload["applyDpScale"]?.asBoolean()?.let(::setApplyDpScale)
        rawPayload["iconTransition"]
          ?.let { element -> element.asLabelTransition() }
          ?.let(::setIconTransition)
        rawPayload["textTransition"]
          ?.let { element -> element.asLabelTransition() }
          ?.let(::setTextTransition)
        rawPayload["padding"]?.asFloat()?.let(::setPadding)
        rawPayload["textGravity"]?.asInt()?.let(::setTextGravity)
        rawPayload["textStyle"]
          ?.asList<Map<String, Any>>()
          ?.map { element -> element.asLabelTextStyle() }
          ?.toTypedArray()
          ?.let { argument -> setTextStyles(*argument) }

        rawPayload["zoomLevel"]?.asInt()?.let(::setZoomLevel)
      }
    }

  fun Any.asLabelStyles(): LabelStyles? =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val rawStyle = rawPayload["styles"]?.asMap<Any?>()
      val style: MutableList<LabelStyle> = mutableListOf(rawStyle!!.asLabelStyle())
      rawStyle["otherStyle"]?.asList<Map<String, Any?>>()?.map { e -> style.add(e.asLabelStyle()) }
      return (rawPayload["styleId"]?.asString()?.let { LabelStyles.from(it, style.toList()) })
        ?: LabelStyles.from(style.toList())
    }

  fun String.asLabelTextBuilder() =
    asString().let { text: String ->
      LabelTextBuilder().apply { setTexts(*text.split("\n").toTypedArray()) }
    }

  fun Any.asLabelOptions(labelManager: LabelManager): LabelOptions =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      LabelOptions.from(
          (rawPayload["id"]?.asString()) ?: MapUtils.getUniqueId(),
          rawPayload.asLatLng(),
        )
        .apply {
          rawPayload["styleId"]?.asString()?.let {
            labelManager.getLabelStyles(it)?.let(::setStyles)
          }
          rawPayload["rank"]?.asLong()?.let(::setRank)
          rawPayload["clickable"]?.asBoolean()?.let(::setClickable)
          rawPayload["visible"]?.asBoolean()?.let(::setVisible)

          if (rawPayload["transformMethod"] != null) {
            rawPayload["transformMethod"]
              ?.asInt()
              ?.let(TransformMethod::getEnum)
              .let(::setTransform)
          }
          rawPayload["text"]?.asString()?.asLabelTextBuilder()?.let(::setTexts)
          rawPayload["tag"]?.asString()?.let(::setTag)
        }
    }

  fun Any.asLabelLayerOptions(): LabelLayerOptions =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      LabelLayerOptions.from(rawPayload["layerId"]!!.asString()).apply {
        rawPayload["competitionType"]
          ?.asInt()
          ?.let { value -> CompetitionType.values().filter { it.value == value }.getOrNull(0) }
          ?.let(::setCompetitionType)
        rawPayload["competitionUnit"]
          ?.asInt()
          ?.let { value -> CompetitionUnit.values().filter { it.value == value }.getOrNull(0) }
          ?.let(::setCompetitionUnit)
        rawPayload["orderingType"]
          ?.asInt()
          ?.let { value -> OrderingType.values().filter { it.value == value }.getOrNull(0) }
          ?.let(::setOrderingType)
        rawPayload["zOrder"]?.asInt()?.let(::setZOrder)
        rawPayload["visible"]?.asBoolean()?.let(::setVisible)
        rawPayload["clickable"]?.asBoolean()?.let(::setClickable)

        // For LodLayer
        rawPayload["radius"]?.asFloat()?.let(::setLodRadius)
      }
    }

  fun Any.asPolylineTextStyle(): PolylineLabelStyle =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      PolylineLabelStyle.from(
          (rawPayload["size"]?.asInt()) ?: 0,
          (rawPayload["color"]?.asInt()) ?: 0,
          (rawPayload["strokeWidth"]?.asInt()) ?: 0,
          (rawPayload["strokeColor"]?.asInt()) ?: 0,
        )
        .apply {
          // rawPayload["applyDpScale"]?.asBoolean()?.let(::setApplyDpScale)
          rawPayload["zoomLevel"]?.asInt()?.let(::setZoomLevel)
        }
    }

  fun Any.asPolylineTextStyles(): PolylineLabelStyles =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val rawStyle = rawPayload.asMap<Any?>()
      val style: MutableList<PolylineLabelStyle> = mutableListOf(rawStyle.asPolylineTextStyle())
      rawStyle["otherStyle"]?.asList<Map<String, Any?>>()?.map { e ->
        style.add(e.asPolylineTextStyle())
      }
      return (rawPayload["styleId"]?.asString()?.let {
        PolylineLabelStyles.from(it, style.toList())
      }) ?: PolylineLabelStyles.from(style.toList())
    }

  fun Any.asPolylineTextOption(): PolylineLabelOptions =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      PolylineLabelOptions.from(
          (rawPayload["id"]?.asString()) ?: MapUtils.getUniqueId(),
          rawPayload["text"]?.asString()!!,
          rawPayload["position"]?.asList<Map<String, Any>>()?.map { element -> element.asLatLng() },
        )
        .apply {
          rawPayload["style"]
            ?.asMap<Any?>()
            ?.let { element -> element.asPolylineTextStyles() }
            ?.let(::setStyles)
          rawPayload["visible"]?.asBoolean()?.let(::setVisible)
        }
    }
}
