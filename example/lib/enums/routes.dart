import 'package:flutter/material.dart';
import 'package:kakao_map_sdk_example/models/menu_info.dart';
import 'package:kakao_map_sdk_example/pages/menu/camera_option_menu.dart';
import 'package:kakao_map_sdk_example/pages/menu/home_menu.dart';
import 'package:kakao_map_sdk_example/pages/menu/map_setting_menu.dart';
// import 'package:kakao_map_sdk_example/pages/menu/poi_overlay_menu.dart';

enum Routes {
  homeMenu(HomeMenu.menuInfo, HomeMenu()),
  cameraOptionMenu(CameraOptionMenu.menuInfo, CameraOptionMenu()),
  // poiOvarlayMenu(PoiOverlayMenu.menuInfo, PoiOverlayMenu()),
  mapSettingMenu(MapSettingMenu.menuInfo, MapSettingMenu());

  final MenuInfo menuInfo;
  final StatefulWidget widget;

  const Routes(this.menuInfo, this.widget);
}
