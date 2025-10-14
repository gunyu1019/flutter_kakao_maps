part of '../kakao_map_sdk_web.dart';

class WebTrackingController with WebTrackingControllerHandler {
  final WebMapController controller;

  WebPoi? _trackPoi;

  @override
  final WebOverlayController manager;

  WebTrackingController._(this.controller, this.manager);

  @override
  Future<void> startTracking(String layerId, String poiId) async {
    _trackPoi = manager._labelLayer[layerId]?._webPoi[poiId]!;
    controller.setCenter(_trackPoi!.getPosition());
    controller.setDraggable(false);
  }

  @override
  Future<void> stopTracking() async {
    _trackPoi = null;
    controller.setDraggable(true);
  }
}
