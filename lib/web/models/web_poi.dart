part of '../../kakao_map_sdk.dart';

class WebPoi {
  final WebCustomOverlay? imageElement;
  final WebCustomOverlay? textElement;

  WebPoi(this.imageElement, this.textElement);

  List<WebCustomOverlay> get elements {
    final element = <WebCustomOverlay>[];
    if (imageElement != null) {
      element.add(imageElement!);
    }
    if (textElement != null) {
      element.add(textElement!);
    }
    return element;
  }
}
