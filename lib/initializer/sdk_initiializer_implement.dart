part of '../kakao_map_sdk.dart';

class KakaoMapSdkImplement implements KakaoMapSdk {
  MethodChannel channel = ChannelType.sdk.channel;

  @override
  Future<String?> hashKey() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return await channel.invokeMethod("hashKey");
  }

  @override
  Future<void> initialize(String appKey) async {
    if (kIsWeb) {
      WebInitializer.initialize();
      return;
    }
    await channel.invokeMethod("initialize", {"appKey": appKey});
  }

  @override
  Future<bool> isInitialize() async {
    return await channel.invokeMethod("isInitialize");
  }
}
