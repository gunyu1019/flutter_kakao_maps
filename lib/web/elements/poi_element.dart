part of '../kakao_map_sdk_web.dart';

web.HTMLElement poiElement(WebPoi poi, PoiStyle style) {
  final element = web.HTMLDivElement()
    ..id = poi.id
    ..style.display = "flex"
    ..style.alignItems = "center"
    ..style.flexDirection = "column";

  if (style.icon != null && poi.preEncodedImage[style.zoomLevel] != null) {
    final preEncodedImage = poi.preEncodedImage[style.zoomLevel]!;
    element.appendChild(
        imageElement(preEncodedImage, style.icon!.width, style.icon!.height, poi.onClick));
  }
  if (poi.text != null) {
    final textGroupElement = web.HTMLSpanElement();
    final iconAvailable = element.children.length > 0;
    final splitedText = poi.text!.split("\n");
    final textStyles =
        style.textStyle.isEmpty ? const [PoiTextStyle()] : style.textStyle;
    var textStyleIndex = 0;
    splitedText.map((innerText) {
      final style = textStyles[textStyleIndex];
      if (textStyleIndex + 1 < textStyles.length) textStyleIndex++;
      final element = textElement(innerText, style, poi.onClick);
      return element;
    }).forEach((e) => textGroupElement.appendChild(e));
    if (iconAvailable) textGroupElement.style.height = "0";
    element.appendChild(textGroupElement);
  }
  return element;
}
