part of '../kakao_map_sdk_web.dart';

class WebRoute {
  final WebPolyline bodyElement;
  WebPolyline? strokeElement;
  WebPolyline? patternElement;

  WebPolylineOption? strokeElementOption;
  WebPolylineOption bodyElementOption;
  WebPolylineOption? patternElementOption;

  WebRoute(
    this.bodyElement,
    this.strokeElement,
    this.patternElement,
    this.bodyElementOption,
    this.strokeElementOption,
    this.patternElementOption,
  );

  List<WebPolyline> get allElement {
    final elements = <WebPolyline>[bodyElement];
    if (patternElement != null) elements.add(patternElement!);
    if (strokeElement != null) elements.add(strokeElement!);
    return elements;
  }
}
