import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk_example/components/control_component.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/models/menu_info.dart';

class MapSettingMenu extends StatefulWidget {
  const MapSettingMenu({super.key});

  @override
  State<MapSettingMenu> createState() => _MapSettingMenuState();

  static const MenuInfo menuInfo = MenuInfo("/map_setting", "지도 설정",
      "지도를 설정하는 기능입니다.", FontAwesomeIcons.gear, true);
}

class _MapSettingMenuState extends State<MapSettingMenu>
 with TitleComponent, ControlComponent {
  Widget title() =>
    Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          children: [
            backButtom(),
            titleText(MapSettingMenu.menuInfo.title),
          ],
        ));
    
  @override
  Widget build(BuildContext context) => Column(
      children: [
        title(),
        Expanded(child: SingleChildScrollView(
          child: Column(
            spacing: 2,
            children: [
              checkbox("나침판 활성화", false, (value) {}),
              checkbox("축적바 활성화", false, (value) {}),
              dropbox("지도 유형", ["일반", "스카이뷰"], 0, (value) {}),
              dropbox("나침판 위치", ["좌측 상단", "좌측 상단", "우측 하단", "우측 상단"], 0, (value) {}),
              dropbox("축적바 위치", ["좌측 상단", "좌측 상단", "우측 하단", "우측 상단"], 0, (value) {}),
              dropbox("로고 위치", ["좌측 상단", "좌측 상단", "우측 하단", "우측 상단"], 0, (value) {}),
            ]
          ),
        ))
      ],
  );
}
