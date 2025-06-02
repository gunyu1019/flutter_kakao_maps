package kr.yhs.flutter_kakao_maps.converter

import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Point
import android.graphics.PointF
import java.io.ByteArrayInputStream
import kr.yhs.flutter_kakao_maps.FlutterKakaoMapsPlugin
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString

object ReferenceTypeConverter {
  fun Any.asBitmap(): Bitmap =
    asMap<Any?>().let { rawPayload: Map<String, Any?> ->
      val width =
        (rawPayload["width"]!!.asInt() * Resources.getSystem().displayMetrics.density).toInt()
      val height =
        (rawPayload["height"]!!.asInt() * Resources.getSystem().displayMetrics.density).toInt()
      if (rawPayload["type"] == 2) {
        val inputStream = ByteArrayInputStream(rawPayload["data"] as ByteArray)
        Bitmap.createScaledBitmap(BitmapFactory.decodeStream(inputStream), width, height, true)
      } else if (rawPayload["type"] == 0) {
        val path = rawPayload["path"]!!.asString()
        Bitmap.createScaledBitmap(
          BitmapFactory.decodeStream(FlutterKakaoMapsPlugin.getAsset(path)),
          width,
          height,
          true,
        )
      } else {
        val path = rawPayload["path"]!!.asString()
        Bitmap.createScaledBitmap(BitmapFactory.decodeFile(path), width, height, true)
      }
    }

  fun Any.asPoint(): PointF =
    asMap<Float>().let { rawPayload: Map<String, Float> ->
      PointF(rawPayload["x"]!!, rawPayload["y"]!!)
    }

  fun Point.toMessageable(): Map<String, Int> = mapOf("x" to this.x, "y" to this.y)

  fun PointF.toMessageable(): Map<String, Float> = mapOf("x" to this.x, "y" to this.y)
}
