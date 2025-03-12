part of '../../../kakao_map_sdk.dart';

/// [Route] 또는 [MultipleRoute]를 구현하는 객체의 곡선을 설정합니다.
enum CurveType {
  /// [Route] 또는 [MultipleRoute]가 왼쪽으로 곡선을 구성하도록 합니다.
  left(1),

  /// [Route] 또는 [MultipleRoute]에 아무런 설정을 하지않습니다.
  none(0),

  /// [Route] 또는 [MultipleRoute]가 오른쪽으로 곡선을 구성하도록 합니다.
  right(2);

  final int value;

  const CurveType(this.value);
}
