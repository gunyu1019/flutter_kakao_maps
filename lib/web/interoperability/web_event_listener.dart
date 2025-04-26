part of '../../kakao_map_sdk.dart';

@JS("kakao.maps.event.addListener")
external void addEventListener(WebMapController controller, String event, JSFunction listener);


@JS("kakao.maps.event.removeListener")
external void removeEventListener(WebMapController controller, String event, [JSFunction listener]);
