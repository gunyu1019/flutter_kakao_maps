part of '../kakao_map_sdk_web.dart';

String _getSingleColorCode(double value) =>
    (value * 255).toInt().toRadixString(16).padLeft(2, '0');

String _getColorCode(Color color) =>
    "#${_getSingleColorCode(color.r)}${_getSingleColorCode(color.g)}${_getSingleColorCode(color.b)}";
