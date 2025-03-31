part of '../kakao_map_sdk.dart';

/// 오버레이에 사용되는 스타일([PoiStyle], [PolygonStyle], [PolylineStlye] 또는 [RouteStlye]) 또는
/// 오버레이([Poi], [LodPoi], [PolylineText], [Polyline], [Polygon], [Route] 또는 [MultipleRoute])가
/// 중복 등록되면 발생하는 예외입니다.
/// 컨트롤러에는 고유의 ID를 가지고 있는 하나의 오버레이만 등록할 수 있으며 중복되는 ID를 가져서는 안됩니다.
class DuplicatedOverlayException implements Exception {
  /// 중복 오버레이의 등록된 ID입니다.
  final String id;

  const DuplicatedOverlayException(this.id);

  @override
  String toString() => "DuplicatedOverlayException(duplicated ID: $id)";
}
