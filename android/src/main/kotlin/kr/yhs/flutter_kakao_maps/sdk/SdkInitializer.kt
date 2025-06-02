package kr.yhs.flutter_kakao_maps.SDK

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.util.Base64
import com.kakao.vectormap.KakaoMapSdk
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import kotlin.Result

class SdkInitializer(private val context: Context, private val channel: MethodChannel) :
  SdkInitializerHandler {
  init {
    channel.setMethodCallHandler(::handle)
  }

  override fun isInitialize(result: MethodChannel.Result) {
    KakaoMapSdk.isInitialized().let(result::success)
  }

  override fun hashKey(result: MethodChannel.Result) {
    var packageInfo: PackageInfo? = null
    try {
      packageInfo = context.packageManager.getPackageInfo(context.packageName, 64)
    } catch (e: PackageManager.NameNotFoundException) {
      result.success(null)
    }
    if (packageInfo == null) {
      result.success(null) // Authentication failure. PackageInfo is null.
      return
    }

    @Suppress("Deprecation") val signatures = packageInfo.signatures
    if (signatures == null || signatures.size < 1) {
      result.success(null) // Authentication failure. Signature is invalid.
      return
    }
    val signature = signatures[0]

    lateinit var md: MessageDigest
    try {
      md = MessageDigest.getInstance("SHA")
    } catch (e: NoSuchAlgorithmException) {
      result.success(null)
      return
    }

    md.update(signature.toByteArray())
    Base64.encodeToString(md.digest(), Base64.DEFAULT).trim().let(result::success)
    return
  }

  override fun initialize(appKey: String, result: MethodChannel.Result) {
    KakaoMapSdk.init(context, appKey)
    result.success(null)
  }
}
