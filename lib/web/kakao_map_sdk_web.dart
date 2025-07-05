import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

/* web (Experimentation) */
part 'controller/web_overlay_controller.dart';
part 'controller/web_controller.dart';
part 'controller/web_controller_handler.dart';

part 'elements/image_element.dart';
part 'elements/poi_element.dart';
part 'elements/text_element.dart';

part 'models/web_custom_overlay_option.dart';
part 'models/web_map_option.dart';
part 'models/web_mouse_event.dart';
part 'models/web_polygon_option.dart';
part 'models/web_polyline_option.dart';
part 'models/web_route.dart';
part 'models/web_shape_point.dart';

part 'overlay/web_label_controller.dart';
part 'overlay/web_route_controller.dart';
part 'overlay/web_shape_controller.dart';

part 'overlay/web_label_controller_handler.dart';
part 'overlay/web_route_controller_handler.dart';
part 'overlay/web_shape_controller_handler.dart';

part 'interoperability/web_abstract_overlay.dart';
part 'interoperability/web_custom_overlay.dart';
part 'interoperability/web_event_listener.dart';
part 'interoperability/web_latlng_bound.dart';
part 'interoperability/web_latlng.dart';
part 'interoperability/web_map_controller.dart';
part 'interoperability/web_map_projection.dart';
part 'interoperability/web_point.dart';
part 'interoperability/web_polygon.dart';
part 'interoperability/web_polyline.dart';

part 'utils/web_calculate_level.dart';
part 'utils/web_image_source.dart';
part 'utils/web_color.dart';

class KakaoMapWebPlugin {
  // ignore: constant_identifier_names
  static const VIEW_TYPE = "plugin/kakao_map";

  static const int maxAttempts = 100;
  static const int retryTime = 1;

  static const codec = StandardMethodCodec();
  static Registrar? registrar;

  static String mapElementId(int viewId) => "map_$viewId";

  static web.Element viewFactory(int viewId, {Object? params}) {
    final channel =
        ChannelType.view.channelWithParamAndId(viewId, codec, registrar);
    final overlayChannel =
        ChannelType.overlay.channelWithParamAndId(viewId, codec, registrar);
    final webMapOption = WebMapOption.fromMessageable(params!);

    getController(viewId, webMapOption).then((webController) {
      KakaoMapWebController(
          controller: webController,
          channel: channel,
          overlayChannel: overlayChannel);
    });

    return web.HTMLDivElement()
      ..id = mapElementId(viewId)
      ..style.zIndex = '0'
      ..style.width = '100%'
      ..style.height = '100%';
  }

  static void registerWith(Registrar registrar) {
    KakaoMapWebPlugin.registrar = registrar;
    ui_web.platformViewRegistry
        .registerViewFactory("plugin/kakao_map", viewFactory);

    // Unused in Web Environment
    final sdkChannel = ChannelType.sdk.channelWithParam(codec, registrar);
    sdkChannel.setMethodCallHandler((handler) async {});
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
