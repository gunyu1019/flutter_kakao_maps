import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

mixin ControllerBase {
  String get page;

  Widget title() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            titleText(),
            Row(spacing: 8, children: [
              flutterCard(),
              platformCard(),
            ])
          ],
        ));
  }

  Widget titleText([String? text]) =>
      Text(text ?? "Kakao Map SDK", style: titleTextStyle);

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

  Widget backButtom(void Function() onPressed) => IconButton(
      onPressed: onPressed, icon: const FaIcon(FontAwesomeIcons.chevronLeft));

  Widget divider() => const Divider(height: 20, thickness: 3, indent: 10, endIndent: 10, color: Color.fromARGB(128, 0, 0, 0));

  Widget cardButtom(Widget icon, String title, String description, [void Function()? onPressed]) =>
      Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed,
          child: ListTile(
            leading: icon,
            title: Text(title, style: cardTitleTextStyle,),
            subtitle: Text(description, style: cardDescriptionTextStyle,)
          ),
        )
      );

  final titleTextStyle = const TextStyle(
      fontSize: 24, color: Colors.black, decoration: TextDecoration.none);
  final cardTitleTextStyle = const TextStyle(
      fontSize: 16, color: Colors.black, decoration: TextDecoration.none);
  final cardDescriptionTextStyle = const TextStyle(
      fontSize: 12, color: Colors.black, decoration: TextDecoration.none);

  final Color flutterColor = const Color.fromARGB(255, 19, 137, 253);
  final Color androidColor = const Color.fromARGB(255, 50, 222, 132);
  final Color iOSColor = const Color.fromARGB(255, 0, 0, 0);
}
