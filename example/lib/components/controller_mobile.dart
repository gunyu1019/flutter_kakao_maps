import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk_example/components/controller_base.dart';

class MobileControllerWidget extends StatefulWidget {
  const MobileControllerWidget({super.key});

  @override
  State<MobileControllerWidget> createState() => _MobileControllerWidgetState();
}

class _MobileControllerWidgetState extends State<MobileControllerWidget>
    with ControllerBase {
  @override
  var page = "/home";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title(),
      ],
    );
  }
}
