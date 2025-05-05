import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/services.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/* web (Experimentation) */
part 'web_controller.dart';
part 'web_initializer.dart';

part 'elements/image_element.dart';
part 'elements/poi_element.dart';
part 'elements/text_element.dart';

part 'models/web_custom_overlay_option.dart';
part 'models/web_map_option.dart';
part 'models/web_mouse_event.dart';
part 'models/web_polygon_option.dart';
part 'models/web_polyline_option.dart';
part 'models/web_route.dart';

part 'overlay/web_label_controller.dart';
part 'overlay/web_lod_label_controller.dart';
part 'overlay/web_route_controller.dart';
part 'overlay/web_shape_controller.dart';

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
