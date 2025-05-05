part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.AbstractOverlay")
extension type WebAbstractOverlay._(JSObject _) implements JSObject {
  external WebAbstractOverlay();

  external JSFunction onAdd;
  external JSFunction onRemove;
  external JSFunction draw;
}
