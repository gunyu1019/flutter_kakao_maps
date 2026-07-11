part of '../kakao_map_sdk_web.dart';

const _svgNs = "http://www.w3.org/2000/svg";

/// SVG 루트
web.SVGSVGElement svgRootElement({
  required double minX,
  required double minY,
  required double width,
  required double height,
}) =>
    (web.document.createElementNS(_svgNs, "svg") as web.SVGSVGElement)
      ..setAttribute("width", "$width")
      ..setAttribute("height", "$height")
      ..setAttribute("viewBox", "$minX $minY $width $height")
      ..setAttribute("overflow", "visible")
      ..style.transform = "translate(${minX}px, ${minY}px)"
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
  final textElement =
      (web.document.createElementNS(_svgNs, "text") as web.SVGTextElement)
        ..setAttribute("font-size", "${style.size / 2}px")
        ..setAttribute("fill", _getColorCode(style.color))
        ..style.display = "inline";
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
