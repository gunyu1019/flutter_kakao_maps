import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk_example/components/control_component.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/models/menu_info.dart';

class CameraOptionMenu extends StatefulWidget {
  const CameraOptionMenu({super.key});

  @override
  State<CameraOptionMenu> createState() => _CameraOptionMenuState();

  static const MenuInfo menuInfo = MenuInfo("/camera", "카메라 기능",
      "지도를 비추고 있는 카메라를 조작합니다.", FontAwesomeIcons.camera, true);
}

class _CameraOptionMenuState extends State<CameraOptionMenu>
 with TitleComponent, ControlComponent {
  Widget title() =>
    Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          children: [
            backButtom(),
            titleText(CameraOptionMenu.menuInfo.title),
          ],
        ));

  Widget _positionInfoText(String title, String data) => Row(
    spacing: 2,
    children: [
      Text(title, style: positionTitleText),
      Flexible(child: Text(data, style: positionValueText, overflow: TextOverflow.ellipsis,))
    ],
  );

  Widget positionInfoText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 1.0,
      children: [
        _positionInfoText("경도: ", "1234512345123451234512345"),
        _positionInfoText("위도: ", "12345"),
      ]
    );
  }

  Widget positionInfoCard(String title, String data) {
    return Card(
      child: Container(
        constraints: const BoxConstraints(minHeight: 60, minWidth: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 1,
          children: [
            Text(title, style: positionTitleText),
            Text(data, style: positionValueText, overflow: TextOverflow.fade)
          ]
        ),
      )
    );
  }

  Widget cameraInfoText() {
    return Row(children: [
      Expanded(flex: 2, child: positionInfoText()),
      Expanded(flex: 1, child: positionInfoCard("기울기", "0도")),
      Expanded(flex: 1, child: positionInfoCard("틸트", "0도")),
      Expanded(flex: 1, child: positionInfoCard("높이", "0m")),
    ]);
  }

  Widget applyCameraButton(String title, void Function() onPressed) => OutlinedButton(
    onPressed: onPressed, 
    child: SizedBox(width: double.infinity, child: Text(title, style: buttonText, textAlign: TextAlign.center,))
  );

  @override
  Widget build(BuildContext context) => Column(
      children: [
        title(),
        Expanded(child: SingleChildScrollView(
          child: Column(
            spacing: 2,
            children: [
              cameraInfoText(),
              slider("애니메이션", 0, (value) {}),
              slider("기울기", 0, (value) {}),
              slider("틸트", 0, (value) {}),
              applyCameraButton("적용", () {})
            ]
          ),
        ))
      ],
    );
  
  final positionTitleText = const TextStyle(
      fontSize: 14, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.bold);
  final positionValueText = const TextStyle(
      fontSize: 14, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.normal);
  final buttonText = const TextStyle(
      fontSize: 16, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.normal);
}
