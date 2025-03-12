part of '../../../kakao_map_sdk.dart';

/// [ShapeController]으로 도형을 구성하는 과정에서 다른 오브젝트과 겹치면 그려지는 우선순위를 설정합니다.
enum ShapeLayerPass {
  /// 기본 유형
  defaultPass(0),

  /// 지도 오버레이(나침판, 스케일)를 위에 도형을 구성하는 유형입니다.
  overlayPass(1),

  /// [Route], [MultipleRoute]를 위에 도형을 구성하는 유형입니다.
  routePass(2);

  final int value;

  const ShapeLayerPass(this.value);
}
