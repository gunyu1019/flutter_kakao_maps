part of '../kakao_map_sdk_web.dart';

web.HTMLElement poiElement(WebPoi poi, PoiStyle style) {
  final element = web.HTMLDivElement()
    ..id = poi.id
    ..style.display = "flex"
    ..style.alignItems = "center"
    ..style.flexDirection = "column"
    ..style.position = "relative";

  if (poi.badge.isNotEmpty) {
    String leftOffset(WebPoiBadge badge) => style.icon != null
        ? "calc((100% - ${style.icon!.width}px) / 2 + ${badge.image.width}px * ${badge.offsetY})"
        : "calc(${badge.offsetX * 100}% - ${badge.image.width}px * ${badge.offsetX})";
    String topOffset(WebPoiBadge badge) =>
        "calc(${badge.offsetY * 100}% - ${badge.image.width}px * ${badge.offsetY})";
    for (WebPoiBadge badge in poi.badge.values.where(
      (WebPoiBadge badge) => badge.visible,
    )) {
      web.HTMLElement badgeElement = imageElement(
        badge.preEncodedImage,
        badge.image.width,
        badge.image.height,
      )
        ..style.top = topOffset(badge)
        ..style.left = leftOffset(badge)
        ..style.position = "absolute"
        ..style.zIndex = badge.zOrder.toString();
      element.appendChild(badgeElement);
    }
  }
  if (style.icon != null && poi.preEncodedImage[style.zoomLevel] != null) {
    final preEncodedImage = poi.preEncodedImage[style.zoomLevel]!;
    element.appendChild(
      imageElement(
        preEncodedImage,
        style.icon!.width,
        style.icon!.height,
        poi.onClick,
      ),
    );
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
