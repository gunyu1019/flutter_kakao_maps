part of '../../kakao_map_sdk.dart';

class WebRoute {
  final WebPolyline? strokeElement;
  final WebPolyline? bodyElement;
  final WebPolyline? patternElement;

  WebRoute(this.strokeElement, this.bodyElement, this.patternElement);

  List<WebPolyline> get allElement {
    final elements = <WebPolyline>[];
    if (bodyElement != null) elements.add(bodyElement!);
    if (patternElement != null) elements.add(patternElement!);
    if (strokeElement != null) elements.add(strokeElement!);
    return elements;
  }
}
