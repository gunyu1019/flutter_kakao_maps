part of '../kakao_map_sdk_web.dart';

class WebPolylineText {
  final String id;
  final List<LatLng> points;
  String text;
  PolylineTextStyle style;
  int currentLevel;
  bool visible;

  late final WebCustomOverlay overlay;
  late final web.SVGPathElement pathElement;
  late final web.SVGTextElement textElement;

  WebPolylineText(this.id, this.points, this.text, this.style)
      : currentLevel = style.zoomLevel,
        visible = true;

  void setMap(WebMapController? map) => overlay.setMap(map);

  void setVisibility(bool value) {
    visible = value;
    if (!visible) {
      textElement.setAttribute("visibility", "hidden");
      return;
    }
    final pathLength = pathElement.getTotalLength();
    final textLength = textElement.getComputedTextLength();
    if (pathLength == 0 || textLength == 0) {
      // SVG not yet in DOM; default to visible so zoom_changed can re-evaluate later.
      textElement.setAttribute("visibility", "visible");
      return;
    }
    textElement.setAttribute("visibility", isTooShort ? "hidden" : "visible");
  }

  void updatePath(String pathData) =>
      pathElement.setAttribute("d", pathData);

  void updateText(String text) {
    this.text = text;
    textElement.querySelector("textPath")?.textContent = text;
  }

  bool get isTooShort {
    final pathLength = pathElement.getTotalLength();
    final textLength = textElement.getComputedTextLength();
    if (pathLength == 0 || textLength == 0) return false;
    return pathLength < textLength;
  }

  void applyStyle(PolylineTextStyle style) {
    textElement
      ..setAttribute("font-size", "${style.size / 2}px")
      ..setAttribute("fill", _getColorCode(style.color));
    if (style.strokeSize != null && style.strokeSize! > 0) {
      textElement
        ..setAttribute("stroke", _getColorCode(style.strokeColor!))
        ..setAttribute("stroke-width", "${style.strokeSize}px")
        ..setAttribute("paint-order", "stroke");
    } else {
      textElement
        ..removeAttribute("stroke")
        ..removeAttribute("stroke-width")
        ..removeAttribute("paint-order");
    }
  }
}
