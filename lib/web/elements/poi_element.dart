part of '../kakao_map_sdk_web.dart';

web.HTMLElement poiElement(String id, String? encodedIcon, KImage? icon,
    String? text, PoiStyle style, void Function()? onClick) {
  final element = web.HTMLDivElement()
    ..id = id
    ..style.display = "flex"
    ..style.alignItems = "center"
    ..style.flexDirection = "column";
  if (icon != null && encodedIcon != null) {
    element.appendChild(
        imageElement(encodedIcon, icon.width, icon.height, onClick));
  }
  if (text != null) {
    final textGroupElement = web.HTMLSpanElement();
    final iconAvailable = element.children.length > 0;
    final splitedText = text.split("\n");
    final textStyles =
        style.textStyle.isEmpty ? const [PoiTextStyle()] : style.textStyle;
    var textStyleIndex = 0;
    splitedText.map((innerText) {
      final style = textStyles[textStyleIndex];
      if (textStyleIndex + 1 < textStyles.length) textStyleIndex++;
      final element = textElement(innerText, style, onClick);
      return element;
    }).forEach((e) => textGroupElement.appendChild(e));
    if (iconAvailable) textGroupElement.style.height = "0";
    element.appendChild(textGroupElement);
  }
  return element;
}
