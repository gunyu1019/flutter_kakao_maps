part of '../kakao_map_sdk_web.dart';

class WebPolylineText {
  final String id;
  final List<LatLng> points;
  String text;
  PolylineTextStyle style;
  int currentLevel;
  bool visible;

  late final WebCustomOverlay overlay;
  late final LatLng anchor;
  late final web.SVGSVGElement rootElement;
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
    textElement.setAttribute(
        "visibility", pathLength < textLength ? "hidden" : "visible");
  }

  void setDimScreenFilter(String? filter) {
    rootElement.style.filter = filter ?? 'none';
  }

  void _updateGeometry(WebSvgPathRouteGeometry geometry) {
    rootElement
      ..setAttribute("width", "${geometry.width}")
      ..setAttribute("height", "${geometry.height}")
      ..setAttribute(
        "viewBox",
        "${geometry.minX} ${geometry.minY} ${geometry.width} ${geometry.height}",
      )
      ..style.transform = "translate(${geometry.minX}px, ${geometry.minY}px)";
    pathElement.setAttribute("d", geometry.pathData);
  }

  void updateText(String text) {
    this.text = text;
    textElement.querySelector("textPath")?.textContent = text;
  }

  void applyStyle(PolylineTextStyle style) {
    applyPolylineTextStyle(textElement, style);
  }
}
