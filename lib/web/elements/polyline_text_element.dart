part of '../kakao_map_sdk_web.dart';

const _svgNs = "http://www.w3.org/2000/svg";

/// SVG 루트
web.SVGSVGElement svgRootElement() =>
    (web.document.createElementNS(_svgNs, "svg") as web.SVGSVGElement)
      ..setAttribute("width", "1")
      ..setAttribute("height", "1")
      ..setAttribute("overflow", "visible")
      ..style.pointerEvents = "none";

/// 경로
web.SVGPathElement svgPathElement(String pathId, String pathData) =>
    (web.document.createElementNS(_svgNs, "path") as web.SVGPathElement)
      ..id = pathId
      ..setAttribute("d", pathData)
      ..setAttribute("fill", "none")
      ..setAttribute("stroke", "none");

/// 텍스트
web.SVGTextElement polylineTextElement(
  String pathId,
  String text,
  PolylineTextStyle style,
) {
  final textElement = (web.document.createElementNS(_svgNs, "text") as web.SVGTextElement)
    ..setAttribute("font-size", "${style.size}px")
    ..setAttribute("fill", _getColorCode(style.color));
  if (style.strokeSize != null && style.strokeSize! > 0) {
    textElement
      ..setAttribute("stroke", _getColorCode(style.strokeColor!))
      ..setAttribute("stroke-width", "${style.strokeSize}px")
      ..setAttribute("paint-order", "stroke");
  }
  return textElement
    ..append(
      web.document.createElementNS(_svgNs, "textPath")
        ..setAttribute("href", "#$pathId")
        ..setAttribute("startOffset", "50%")
        ..setAttribute("text-anchor", "middle")
        ..textContent = text,
    );
}
