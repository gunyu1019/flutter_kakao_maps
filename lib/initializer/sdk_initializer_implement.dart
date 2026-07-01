part of '../kakao_map_sdk.dart';

class KakaoMapSdkImplement implements KakaoMapSdk {
  MethodChannel channel = ChannelType.sdk.channel;
  static bool _isInitalized = false;

  @override
  Future<String?> hashKey() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return await channel.invokeMethod("hashKey");
  }

  @override
  Future<void> initialize(String appKey) async {
    _isInitalized = true;
    await channel.invokeMethod("initialize", {"appKey": appKey});
  }

  @override
  Future<bool> isInitialize() async {
    if (kIsWeb) return _isInitalized;
    return await channel.invokeMethod("isInitialize");
  }
}
