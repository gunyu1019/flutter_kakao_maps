part of '../../../kakao_map_sdk.dart';

/// [DimScreenController]가 덮는 영역을 지정합니다.
enum DimScreenCover {
  /// 지도의 모든 영역을 덮습니다.
  all(2),

  /// 지도 배경만 덮습니다.
  map(0),

  /// 지도 배경과 [Poi]를 덮습니다.
  mapAndLabel(1);

  final int value;

  const DimScreenCover(this.value);
}
