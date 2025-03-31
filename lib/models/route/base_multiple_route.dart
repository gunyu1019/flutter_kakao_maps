part of '../../kakao_map_sdk.dart';

/// [MultipleRoute]를 구현하기 위해 필요한 기본 구성요소를 담고 있는 구현체입니다.
mixin BaseMultipleRoute {
  /// 다중 선형([MultipleRoute])를 구성하는 [RouteStyle]을 담은 배열입니다.
  List<RouteStyle> get styles;

  /// 다중 선형([MultipleRoute])를 구성하는 [RouteSegment]을 담은 배열입니다.
  List<RouteSegment> get segments;
}
