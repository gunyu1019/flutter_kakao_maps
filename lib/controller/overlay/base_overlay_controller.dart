part of '../../kakao_map_sdk.dart';

abstract class OverlayController {
  abstract final MethodChannel channel;
  abstract final OverlayType type;
  abstract final OverlayManager manager;

  Future<T> _invokeMethod<T>(
      String method, Map<String, dynamic> payload) async {
    payload['type'] = type.value;
    return await channel.invokeMethod(method, payload);
  }
}
