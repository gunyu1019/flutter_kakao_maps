part of '../kakao_map_sdk.dart';

class WebInitializer {
  static String mapElementId(int viewId) => "map_$viewId";
  static const int maxAttempts = 100;
  static const int retryTime = 1;

  static void initialize() {
    ui_web.platformViewRegistry.registerViewFactory(
        KakaoMapWebController.VIEW_TYPE,
        (int viewId, {Object? params}) => web.HTMLDivElement()
          ..id = mapElementId(viewId)
          ..style.width = '100%'
          ..style.height = '100%');
  }

  static Future<WebMapController?> getController(
      int viewId, WebMapOption option) async {
    for (int i = 0; i < maxAttempts; i++) {
      var element = web.document.getElementById("map_$viewId");
      if (element != null) {
        return WebMapController(element, option);
      }
      await Future.delayed(const Duration(seconds: retryTime));
    }
    return null;
  }
}
