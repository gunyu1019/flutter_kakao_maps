package kr.yhs.flutter_kakao_maps.converter

object PrimitiveTypeConverter {
  fun Any.asBoolean(): Boolean = this as Boolean

  fun Any.asDouble(): Double = if (this is Float) toDouble() else this as Double

  fun Any.asFloat(): Float = if (this is Double) toFloat() else this as Float

  fun Any.asString(): String = this as String

  fun Any.asInt(): Int = if (this is Long) toInt() else this as Int

  fun Any.asLong(): Long = if (this is Int) toLong() else this as Long

  @Suppress("UNCHECKED_CAST") fun <T> Any.asMap(): Map<String, T> = this as Map<String, T>

  @Suppress("UNCHECKED_CAST") fun <T> Any.asList(): List<T> = this as List<T>
}
