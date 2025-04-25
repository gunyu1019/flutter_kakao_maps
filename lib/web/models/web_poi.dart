part of '../../kakao_map_sdk.dart';

class WebPoi {
  final WebCustomOverlay? imageOverlay;
  final WebCustomOverlay? textOverlay;

  WebPoi(this.imageOverlay, this.textOverlay);

  List<WebCustomOverlay> get overlays {
    final element = <WebCustomOverlay>[];
    if (imageOverlay != null) {
      element.add(imageOverlay!);
    }
    if (textOverlay != null) {
      element.add(textOverlay!);
    }
    return element;
  }
}
