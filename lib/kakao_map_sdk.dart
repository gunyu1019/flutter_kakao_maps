import 'dart:convert';
import 'dart:io';
import 'dart:math' as math show Point;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'dart:ui_web' as ui_web;
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/* chnnael */
part 'channel/channel_type.dart';

/* controller */
part 'controller/controller_implement.dart';
part 'controller/handler.dart';
part 'controller/controller.dart';

part 'controller/overlay/base_overlay_controller.dart';
part 'controller/overlay/base_label_controller.dart';
part 'controller/overlay/overlay_manager.dart';
part 'controller/overlay/label_controller.dart';
part 'controller/overlay/lod_label_controller.dart';
part 'controller/overlay/route_controller.dart';
part 'controller/overlay/shape_controller.dart';

/* exception */
part 'exception/duplicated_overlay_exception.dart';
part 'exception/kakao_auth_error.dart';
part 'exception/kakao_map_error.dart';

/* initalizer */
part 'initializer/sdk_initalizer.dart';
part 'initializer/sdk_initiializer_implement.dart';

/* models */
part 'models/map_option.dart';
part 'models/map_lifecycle.dart';
part 'models/map_gravity.dart';
part 'models/base/point.dart';
part 'models/base/image.dart';
part 'models/base/messageable.dart';
part 'models/camera/camera_animation.dart';
part 'models/camera/camera_position.dart';
part 'models/camera/camera_update.dart';
part 'models/geolocation/latlng.dart';

part 'models/label/poi.dart';
part 'models/label/poi_style.dart';
part 'models/label/poi_text_style.dart';
part 'models/label/poi_transition.dart';
part 'models/label/lod_poi.dart';
part 'models/label/polyline_text.dart';
part 'models/label/polyline_text_style.dart';

part 'models/shape/base_point.dart';
part 'models/shape/base_dot_point.dart';
part 'models/shape/circle_point.dart';
part 'models/shape/map_point.dart';
part 'models/shape/polygon.dart';
part 'models/shape/polyline.dart';
part 'models/shape/polygon_style.dart';
part 'models/shape/polyline_style.dart';
part 'models/shape/rectangle_point.dart';

part 'models/route/base_route.dart';
part 'models/route/base_multiple_route.dart';
part 'models/route/multiple_route.dart';
part 'models/route/multiple_route_option.dart';
part 'models/route/route.dart';
part 'models/route/route_pattern.dart';
part 'models/route/route_style.dart';
part 'models/route/route_segment.dart';

part 'models/gui/default_gui.dart';
part 'models/gui/compass.dart';
part 'models/gui/scale_bar.dart';
part 'models/gui/logo.dart';

/* model(enumerate) */
part 'models/enums/default_gui_type.dart';
part 'models/enums/event_type.dart';
part 'models/enums/map_overlay.dart';
part 'models/enums/map_type.dart';
part 'models/enums/camera_update_type.dart';
part 'models/enums/gesture_type.dart';
part 'models/enums/image_type.dart';
part 'models/enums/overlay_type.dart';
part 'models/enums/horizontal_align.dart';
part 'models/enums/vertical_align.dart';

part 'models/enums/label/competition_type.dart';
part 'models/enums/label/competition_unit.dart';
part 'models/enums/label/ordering_type.dart';
part 'models/enums/label/transition.dart';
part 'models/enums/label/transform_method.dart';

part 'models/enums/shape/point_shape_type.dart';
part 'models/enums/shape/polyline_cap.dart';
part 'models/enums/shape/shape_layer_pass.dart';

part 'models/enums/route/curve_type.dart';

/* widget */
part 'widget/map_widget.dart';
part 'widget/platform_view.dart';

/* web (Experimentation) */
part 'web/web_controller.dart';
part 'web/web_initializer.dart';

part 'web/elements/image_element.dart';
part 'web/elements/poi_element.dart';
part 'web/elements/text_element.dart';

part 'web/models/web_custom_overlay_option.dart';
part 'web/models/web_map_option.dart';
part 'web/models/web_mouse_event.dart';
part 'web/models/web_polygon_option.dart';
part 'web/models/web_polyline_option.dart';
part 'web/models/web_route.dart';

part 'web/overlay/web_label_controller.dart';
part 'web/overlay/web_lod_label_controller.dart';
part 'web/overlay/web_route_controller.dart';
part 'web/overlay/web_shape_controller.dart';

part 'web/interoperability/web_abstract_overlay.dart';
part 'web/interoperability/web_custom_overlay.dart';
part 'web/interoperability/web_event_listener.dart';
part 'web/interoperability/web_latlng_bound.dart';
part 'web/interoperability/web_latlng.dart';
part 'web/interoperability/web_map_controller.dart';
part 'web/interoperability/web_map_projection.dart';
part 'web/interoperability/web_point.dart';
part 'web/interoperability/web_polygon.dart';
part 'web/interoperability/web_polyline.dart';

part 'web/utils/web_image_source.dart';
