part of '../../kakao_map_sdk.dart';

enum EventType {
  onCameraMoveStart(1),
  onCameraMoveEnd(2),
  onCompassClick(4),
  onMapClick(8),
  onTerrainClick(16),
  onTerrainLongClick(32),
  onPoiClick(64),
  onLodPoiClick(128);

  final int id;

  bool compareTo(int bitMask) => bitMask & id == id;

  const EventType(this.id);
}
