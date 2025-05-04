part of '../../kakao_map_sdk.dart';

/// [Route]와 [MultipleRoute]를 구현하기 위한 추상형 객체입니다.
/// 네이티브 Kakao Map SDK는 [MultipleRoute]를 기반으로 제공하여, 사용성 편의 강화를 위해
/// Flutter SDK에서는 단일 선형([Route])를 구현하였습니다.
/// 네이티브에서 처리하는 두 객체는 하나의 객체 유형과 동일합니다.
abstract class BaseRoute {
  abstract final RouteController _controller;
  abstract int _zOrder;
  abstract bool _visible;

  /// 선형([Route] 또는 [MultipleRoute])에서 사용하는 고유한 ID입니다.
  abstract final String id;

  /// 선형([Route] 또는 [MultipleRoute])의 렌더링 우선순위입니다.
  int get zOrder => _zOrder;

  /// 선형([Route] 또는 [MultipleRoute])가 현재 지도에 그려지는지 여부를 나타냅니다.
  bool get visible => _visible;

  /// 선형이 단일 선형([Route]), 다중 선형([MultipleRoute])인지 분별합니다.
  bool get multiple;

  /// 선형이 지도에서 보이도록 합니다.
  Future<void> show() async {
    await _controller._changeRouteVisible(id, true);
    _visible = true;
  }

  /// 선형이 지도에서 노출되지 않도록 합니다.
  Future<void> hide() async {
    await _controller._changeRouteVisible(id, false);
    _visible = false;
  }

  /// 선형의 렌더링 우선순위를 다시 정의합니다.
  Future<void> setZOrder(int zOrder) async {
    await _controller._changeRouteZOrder(id, zOrder);
    _zOrder = zOrder;
  }

  /// 선형 개체를 삭제합니다.
  Future<void> remove() async {
    await _controller.removeRoute(this);
  }
}
