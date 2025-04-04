import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk_example/pages/routers.dart';

mixin TitleComponent {
  Widget titleText([String? text]) =>
      Text(text ?? "Kakao Map SDK", style: titleTextStyle, overflow: TextOverflow.ellipsis,);

  Widget baseSubCard(String text, IconData? icon,
      {Color? color, Color? backgroundColor}) {
    const size = 12.0;
    var cardTextStyle = TextStyle(
        fontSize: size,
        color: color ?? Colors.white,
        decoration: TextDecoration.none);

    return Container(
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black,
          borderRadius: const BorderRadius.all(Radius.circular(4))),
      padding: const EdgeInsets.all(4),
      child: Row(
        spacing: 8,
        children: [
          if (icon != null)
            FaIcon(icon, color: color ?? Colors.white, size: size),
          Text(text, style: cardTextStyle)
        ],
      ),
    );
  }

  Widget platformCard() {
    if (kIsWeb) {
      return baseSubCard("web", FontAwesomeIcons.globe);
    }
    return switch (Platform.operatingSystem) {
      "ios" => baseSubCard(Platform.operatingSystem, FontAwesomeIcons.apple,
          backgroundColor: iOSColor),
      "android" => baseSubCard(
          Platform.operatingSystem, FontAwesomeIcons.android,
          backgroundColor: androidColor),
      String() => baseSubCard("unknown", null),
    };
  }

  Widget flutterCard() => baseSubCard("Flutter", FontAwesomeIcons.flutter,
      backgroundColor: flutterColor);

  Widget backButtom([void Function()? onPressed]) => IconButton(
      onPressed: onPressed ?? () => router.pop(), icon: const FaIcon(FontAwesomeIcons.chevronLeft), padding: const EdgeInsets.all(0));

  final titleTextStyle = const TextStyle(
      fontSize: 24, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.bold);

  final Color flutterColor = const Color.fromARGB(255, 19, 137, 253);
  final Color androidColor = const Color.fromARGB(255, 50, 222, 132);
  final Color iOSColor = const Color.fromARGB(255, 0, 0, 0);
}
