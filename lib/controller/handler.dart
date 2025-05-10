part of '../kakao_map_sdk.dart';

mixin KakaoMapControllerHandler {
  Future<dynamic> handle(MethodCall method) async {
    final arguments = method.arguments;
    switch (method.method) {
      case "onMapReady":
        onMapReady();
        break;
      case "onMapDestroy":
        onMapDestroy();
        break;
      case "onMapPaused":
        onMapPaused();
        break;
      case "onMapResumed":
        onMapResumed();
        break;
      case "onMapError":
        final String className = method.arguments['className'];
        switch (className) {
          case 'MapAuthException':
            onMapError(KakaoAuthError.fromMessageable(method.arguments));
            break;
          default:
            onMapError(KakaoMapError(
                method.arguments['className'], method.arguments['message']));
            break;
        }
        break;
      case "onCameraMoveStart":
        final gesture = Platform.isIOS
            ? GestureType._fromMoveByValue(arguments['gesture'] as int)
            : GestureType.fromValue(arguments['gesture'] as int);
        onCameraMoveStart(gesture);
        break;
      case "onCameraMoveEnd":
        final position = CameraPosition.fromMessageable(arguments['position']);
        final gesture = Platform.isIOS
            ? GestureType._fromMoveByValue(arguments['gesture'] as int)
            : GestureType.fromValue(arguments['gesture'] as int);
        onCameraMoveEnd(position, gesture);
        break;
      case "onCompassClick":
        onCompassClick();
        break;
      case "onPoiClick":
        onPoiClick(arguments['layerId'], arguments['poiId']);
        break;
      case "onLodPoiClick":
        onLodPoiClick(arguments['layerId'], arguments['poiId']);
        break;
      case "onMapClick":
        final rawPoint = arguments['point'];
        final point = KPoint(rawPoint['x'], rawPoint['y']);
        final position = LatLng.fromMessageable(arguments['position']);
        onMapClick(point, position);
        break;
      case "onTerrainClick":
        final rawPoint = arguments['point'];
        final point = KPoint(rawPoint['x'], rawPoint['y']);
        final position = LatLng.fromMessageable(arguments['position']);
        onTerrainClick(point, position);
        break;
      case "onTerrainLongClick":
        final rawPoint = arguments['point'];
        final point = KPoint(rawPoint['x'], rawPoint['y']);
        final position = LatLng.fromMessageable(arguments['position']);
        onTerrainLongClick(point, position);
        break;
      default:
        break;
    }
  }

  void onMapReady();

  void onMapDestroy();

  void onMapResumed();

  void onMapPaused();

  void onMapError(Error error);

  void onCameraMoveStart(GestureType gestureType);

  void onCameraMoveEnd(CameraPosition position, GestureType gestureType);

  void onCompassClick();

  void onPoiClick(String layerId, String poiId);

  void onLodPoiClick(String layerId, String poiId);

  void onMapClick(KPoint point, LatLng position);

  void onTerrainClick(KPoint point, LatLng position);

  void onTerrainLongClick(KPoint point, LatLng position);
}
