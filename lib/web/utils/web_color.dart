part of '../../../kakao_map_sdk.dart';

String _getSingleColorCode(double value) =>
    (value * 255).toInt().toRadixString(16);

String getColorCode(Color color) =>
    "#${_getSingleColorCode(color.r)}${_getSingleColorCode(color.g)}${_getSingleColorCode(color.b)}";
