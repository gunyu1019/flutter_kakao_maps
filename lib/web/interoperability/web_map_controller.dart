part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.Map")
extension type WebMapController._(JSObject _) implements JSObject {
  external WebMapController(web.Element element, WebMapOption option);

  external void setCenter(WebLatLng latlng);
  external WebLatLng getCenter();

  external void setMapTypeId(int mapTypeId);
  external int getMapTypeId();

  external void setLevel(int level, [JSAny? options]);
  external int getLevel();

  external void setBounds(WebLatLngBound bounds,
      [int paddingTop, int paddingRight, int paddingBottom, int paddingLeft]);
  external WebLatLngBound getBounds();

  external void setMinLevel(int minLevel);
  external void setMaxLevel(int maxLevel);

  external void panBy(int dx, int dy);
  external void panTo(WebLatLng latlng, int padding);
  external void jump(WebLatLng center, int level, [JSAny? animate]);

  external void addControl(JSObject control, int position);
  external void removeControl(JSObject control);

  external void setDraggable(bool draggable);
  external bool getDraggable();

  external void setZoomable(bool zoomable);
  external bool getZoomable();

  external void relayout();

  external void addOverlayMapTypeId(int mapTypeId);
  external void removeOverlayMapTypeId(int mapTypeId);

  external void setKeyboardShortcuts(bool active);
  external void getKeyboardShortcuts();

  external void setCopyrightPosition(int copyrightPosition, bool reversed);
  external WebMapProjection getProjection();
  external void setCursor(String cursor);
}
