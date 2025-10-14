part of '../kakao_map_sdk_web.dart';

mixin WebTrackingControllerHandler {
  WebOverlayController get manager;

  Future<dynamic> trackingHandle(MethodCall method) async {
    final arguments = method.arguments;

    switch (method.method) {
      case "startTracking":
        final layerId = arguments["layerId"];
        final poiId = arguments["poiId"];
        await startTracking(layerId, poiId);
        break;
      case "stopTracking":
        await stopTracking();
        break;
      case "setTrackingPosition":
        break;
      default:
        throw UnimplementedError();
    }
  }

  Future<void> startTracking(String layerId, String poiId);

  Future<void> stopTracking();
}
