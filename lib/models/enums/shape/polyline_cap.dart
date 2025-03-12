part of '../../../kakao_map_sdk.dart';

/// [Polyline] 도형의 끝을 구성합니다.
enum PolylineCap {
  /// [Polyline] 의 끝이 잘린 형태
  butt(0),

  /// [Polyline] 의 끝이 둥근 형태
  round(1),

  /// [Polyline] 의 끝이 각진 형태
  square(2);

  final int value;

  const PolylineCap(this.value);
}
