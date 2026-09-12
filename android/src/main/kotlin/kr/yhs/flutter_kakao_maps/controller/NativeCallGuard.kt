package kr.yhs.flutter_kakao_maps.controller

import io.flutter.plugin.common.MethodChannel

private const val invalidNativeCallCode = "INVALID_NATIVE_CALL"

internal fun MethodChannel.Result.runSafely(method: String, action: () -> Unit) {
  try {
    action()
  } catch (exception: Exception) {
    reportNativeCallFailure(method, exception)
  } catch (error: NotImplementedError) {
    reportNativeCallFailure(method, error)
  }
}

private fun MethodChannel.Result.reportNativeCallFailure(method: String, failure: Throwable) {
  error(
    invalidNativeCallCode,
    "Failed to handle native method '$method': ${failure.message ?: failure.javaClass.simpleName}",
    mapOf("method" to method, "className" to failure.javaClass.name),
  )
}
