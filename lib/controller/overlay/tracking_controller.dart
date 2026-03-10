part of '../../kakao_map_sdk.dart';

/// [Poi]의 위치를 카메라가 추적하는 기능을 제어하는 컨트롤러입니다.
class TrackingController extends OverlayController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.tracking;

  TrackingController._(this.channel, this.manager);

  /// 카메라가 이동을 추적할 [Poi] 입니다.
  /// 지정되어 있지 않다면, null을 반환합니다.
  Poi? poi;

  /// 카메라가 [Poi]의 회전도 추적할지의 여부입니다.
  bool get trackingRotation => _trackingRotation;
  bool _trackingRotation = false;

  /// [poi] 인수에 입력된 [Poi]를 추적합니다.
  /// [Poi]가 이동한다면 카메라는 [Poi]를 따라 이동합니다.
  /// [poi]가 지정되지 않았으면 반응하지 않습니다.
  Future<void> start() async {
    if (poi == null) return;
    await _invokeMethod("startTracking", {
      "poiId": poi!.id,
      "layerId": poi!._controller.id,
    });
  }

  Future<void> stop() async {
    await _invokeMethod("stopTracking", {});
  }

  /// 카메라가 [Poi]의 회전도 추적할 여부를 설정합니다.
  /// [Poi.rotate] 등에 의해 [Poi]가 회전한다면, 카메라도 따라서 회전합니다.
  Future<void> setTrackingRotate(bool rotation) async {
    _trackingRotation = rotation;
    await _invokeMethod("setTrackingPosition", {"rotation": rotation});
  }
}
