part of '../kakao_map_sdk_web.dart';

void applyPolylineTextStyle(
  web.SVGTextElement textElement,
  PolylineTextStyle style,
) {
  textElement
    ..setAttribute("font-size", "${style.size / 2}px")
    ..setAttribute("fill", _getColorCode(style.color));
  if (style.strokeSize != null && style.strokeSize! > 0) {
    textElement
      ..setAttribute("stroke", _getColorCode(style.strokeColor!))
      ..setAttribute("stroke-width", "${style.strokeSize}px")
      ..setAttribute("paint-order", "stroke");
  } else {
    textElement
      ..removeAttribute("stroke")
      ..removeAttribute("stroke-width")
      ..removeAttribute("paint-order");
  }
}
