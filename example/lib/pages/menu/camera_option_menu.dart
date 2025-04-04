import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/models/menu_info.dart';

class CameraOptionMenu extends StatefulWidget {
  const CameraOptionMenu({super.key});

  @override
  State<CameraOptionMenu> createState() => _CameraOptionMenuState();

  static const MenuInfo menuInfo = MenuInfo("/camera", "카메라 기능",
      "지도를 비추고 있는 카메라 관련 기능의 예제입니다.", FontAwesomeIcons.camera, true);
}

class _CameraOptionMenuState extends State<CameraOptionMenu>
    with TitleComponent {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      title(),
    ];

    return Column(
      children: children,
    );
  }
}
