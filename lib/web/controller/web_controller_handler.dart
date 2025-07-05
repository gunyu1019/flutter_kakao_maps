part of '../kakao_map_sdk_web.dart';

mixin KakaoMapWebControllerHandler {
  Future<dynamic> webHandle(MethodCall call) async {
    final arguments = call.arguments;
    switch (call.method) {
      case "getCameraPosition":
        return await getCameraPosition();
      case "moveCamera":
        final cameraUpdate =
            CameraUpdate.fromMessageable(arguments["cameraUpdate"]);
        final animation = (arguments.containsKey("cameraAnimation") &&
                arguments["cameraAnimation"] != null)
            ? CameraAnimation.fromMessageable(arguments["cameraAnimation"])
            : null;
        await moveCamera(cameraUpdate, animation: animation);
        break;
      case "setGestureEnable":
        final gesture = GestureType.values
            .firstWhere((e) => e.value == arguments["gestureType"]);
        await setGesture(gesture, arguments["enable"]);
        break;
      case "setEventHandler":
        await setEventTrigger(arguments);
        break;
      case "fromScreenPoint":
        return await fromScreenPoint(arguments['x'], arguments['y']);
      case "toScreenPoint":
        return await toScreenPoint(LatLng.fromMessageable(arguments));
      case "canPositionVisible":
        final zoomLevel = arguments["zoomLevel"];
        final position =
            arguments["position"].map(LatLng.fromMessageable).toList();
        return await canShowPosition(zoomLevel, position);
      case "changeMapType":
        await changeMapType(
            MapType.values.firstWhere((e) => e.value == arguments["mapType"]));
        break;
      case "overlayVisible":
        final overlay = MapOverlay.values
            .firstWhere((e) => e.value == arguments["overlayType"]);
        if (arguments["visible"]) {
          await showOverlay(overlay);
        } else {
          await hideOverlay(overlay);
        }
        break;
      case "getBuildingHeightScale":
        return 0.0;
      case "defaultGUIposition":
        final gui = DefaultGUIType.values
            .firstWhere((e) => e.value == arguments["type"]);
        final gravity = MapGravity.fromValue(arguments["gravity"]);
        defaultGUIposition(gui, gravity, arguments["x"], arguments["y"]);
        break;
      case "clearCache" ||
            "clearDiskCache" ||
            "setBuildingHeightScale" ||
            "defaultGUIvisible" ||
            "scaleAutohide" ||
            "scaleAnimationTime":
        break;
      default:
        throw UnimplementedError();
    }
  }

  Future<dynamic> getCameraPosition();

  Future<void> moveCamera(CameraUpdate camera, {CameraAnimation? animation});

  Future<void> setGesture(GestureType gesture, bool enable);

  Future<void> setEventTrigger(int event);

  Future<dynamic> fromScreenPoint(int x, int y);

  Future<dynamic> toScreenPoint(LatLng position);

  Future<void> clearCache();

  Future<void> clearDiskCache();

  Future<bool> canShowPosition(int zoomLevel, List<LatLng> position);

  Future<void> changeMapType(MapType mapType);

  Future<void> hideOverlay(MapOverlay overlay);

  Future<void> showOverlay(MapOverlay overlay);

  Future<double> getBuildingHeightScale();

  // Future<void> setBuildingHeightScale(double scale);

  // Future<void> defaultGUIvisible(DefaultGUIType type, bool visible);

  Future<void> defaultGUIposition(
      DefaultGUIType type, MapGravity gravity, double x, double y);

  // Future<void> scaleAutohide(bool autohide);

  // Future<void> scaleAnimationTime(int fadeIn, int fadeOut, int retention);
}
