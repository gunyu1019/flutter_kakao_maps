part of '../kakao_map_sdk.dart';


class WebInitializer {
  static void initialize() {
    ui_web.platformViewRegistry.registerViewFactory(
      KakaoMapWebController.VIEW_TYPE,
      (int viewId, {Object? params}) => web.HTMLDivElement()
          ..id = 'map_$viewId'
          ..style.width = '100%'
          ..style.height = '100%'
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (int i = 0; i < 100; i ++) {
        var element = web.document.getElementById("map_0");
        if (element != null) {
          WebMapController(element, WebMapOption(center: WebLatLng(37.39479412020964, 127.11116968185037), level: 6));
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    });
  }
}