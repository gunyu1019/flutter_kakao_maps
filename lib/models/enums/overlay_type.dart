part of '../../kakao_map_sdk.dart';

/// 지도를 나타내는 오버레이의 컨트롤러 유형입니다.
enum OverlayType {
  /// [Poi], [PolylineText]를 관리하는 컨트롤러입니다.
  label(value: 1),

  /// [LodPoi]를 관리하는 컨트롤러입니다.
  lodLabel(value: 2),

  /// [Polyline], [Polygon]를 관리하는 컨트롤러입니다.
  shape(value: 3),

  /// [Route], [MultipleRoute]를 관리하는 컨트롤러입니다.
  route(value: 4),

  /// [Polyline] 또는 [Polygon]으로 화면을 가리는 컨트롤러입니다.
  dimScreen(value: 5),

  /// [Poi]의 이동을 추적하는 컨트롤러입니다.
  tracking(value: 6);

  final int value;

  const OverlayType({required this.value});
}
