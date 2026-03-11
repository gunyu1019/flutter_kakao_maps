part of '../../kakao_map_sdk.dart';

/// [Poi] 또는 [LodPoi] 주변에 다른 이미지를 표현하는 객체입니다.
class Badge {
  /// [Poi] 주변을 표현하는 [Badge]의 고유 ID입니다.
  final String id;

  /// 이미지 정중앙을 기준으로 다른 이미지를 표현할 X 좌표입니다.
  final double offsetX;

  /// 이미지 정중앙을 기준으로 다른 이미지를 표현할 Y 좌표입니다.
  final double offsetY;

  /// [Badge]간 이미지 렌더링 우선 순위입니다.
  final int? zOrder;

  /// [Poi] 또는 [LodPoi] 주변에 표현할 다른 이미지입니다.
  final KImage image;

  bool _visible;

  /// [Badge]가 지도에 표시되고 있는 여부를 불러옵니다.
  bool get visible => _visible;

  final BadgeablePoi _parent;

  Badge._(
    BadgeablePoi parent,
    this.id,
    this.offsetX,
    this.offsetY,
    this.image,
    this.zOrder,
  )   : _parent = parent,
        _visible = true;

  /// [Badge]를 지도에서 삭제합니다.
  Future<void> remove() async {
    await _parent._controller._removePoiBadge(_parent.id, id);
  }

  /// [Badge]를 지도에서 보이지 않도록 합니다.
  Future<void> hide() async {
    _visible = false;
    await _parent._controller._setPoiBadgeVisible(_parent.id, id, _visible);
  }

  /// [Badge]를 지도에서 보이도록 합니다.
  Future<void> show() async {
    _visible = true;
    await _parent._controller._setPoiBadgeVisible(_parent.id, id, _visible);
  }
}
