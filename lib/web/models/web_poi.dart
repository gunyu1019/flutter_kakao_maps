part of '../../kakao_map_sdk.dart';

class WebPoi {
  final WebCustomOverlay? imageElement;
  final WebCustomOverlay? textElement;

  int viewedLevel = 0;
  bool visible;

  final Map<int, WebCustomOverlay> otherImageElement;
  final Map<int, WebCustomOverlay> otherTextElement;

  WebPoi(this.imageElement, this.textElement, [this.visible = true])
      : otherImageElement = {},
        otherTextElement = {};

  List<WebCustomOverlay> get elements {
    final element = <WebCustomOverlay>[];
    if (imageElement != null) {
      element.add(imageElement!);
    }
    if (textElement != null) {
      element.add(textElement!);
    }
    element.addAll(otherImageElement.values);
    element.addAll(otherTextElement.values);
    return element;
  }
}
