part of '../kakao_map_sdk_web.dart';

class WebPoi {
  final String id;
  final WebCustomOverlay overlay;

  int currentLevel;

  final Map<int, String> preEncodedImage = {};
  // final Map<String, ...> badge;
  // final List<...> shareTransformPoi;
  // final List<...> shareTransformShape;

  String? text;
  String styleId;

  WebPoi(this.id, this.overlay, {
    required this.currentLevel,
    required this.text,
    required this.styleId,
  });

  void setMap(WebMapController? map) => overlay.setMap(map);
  WebMapController getMap() => overlay.getMap();

  void setPosition(WebLatLng position) => overlay.setPosition(position);
  WebLatLng getPosition() => overlay.getPosition();

  void setContent(web.Element content) => overlay.setContent(content);
  web.Element getContent() => overlay.getContent();

  void setVisible(bool visible) => overlay.setVisible(visible);
  bool getVisible() => overlay.getVisible();

  void setZIndex(int zIndex) => overlay.setZIndex(zIndex);
  int getZIndex() => overlay.getZIndex();
}