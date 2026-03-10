part of '../../kakao_map_sdk.dart';

/// [Badge]를 관리하는 [Poi], [LodPoi]를 위한 객체입니다.
mixin BadgeablePoi {
  BaseLabelController get _controller;

  /// [Poi] 또는 [LodPoi]에서 사용되는 고유 ID입니다.
  String get id;

  final Map<String, Badge> _badges = {};

  /// 등록된 [Badge]의 개수를 불러옵니다.
  int get badgeCount => _badges.length;

  /// [Poi] 또는 [LodPoi]에 다른 이미지를 표현하는 [Badge]를 추가합니다.
  /// [image] 매개변수에는 [Poi] 또는 [LodPoi] 근처에 표현할 이미지 인수가 입력됩니다.
  /// [x]와 [y]는 [Poi], [LodPoi]의 이미지 중앙을 기준으로 오프셋을 설정합니다.
  /// 주어진 인자가 올바른 값이 입력되지 않아 등록에 실패하게 되면 [OverlayRegistrationFailedError] 오류를 호출합니다.
  Future<Badge> addBadge(
    KImage image,
    double x,
    double y, {
    String? badgeId,
    int? zOrder,
  }) async {
    String? badgeIdResult = await _controller._addPoiBadge(
      id,
      image: image,
      offsetX: x,
      offsetY: y,
    );
    if (badgeIdResult == null) {
      throw OverlayRegistrationFailedError(badgeId, _controller.type);
    }
    return Badge._(this, badgeIdResult, x, y, image, zOrder);
  }

  /// [Poi] 또는 [LodPoi]에 등록된 [Badge]를 삭제합니다.
  Future<void> removeBadge(Badge badge) async {
    await _controller._removePoiBadge(id, badge.id);
  }

  /// [Poi] 또는 [LodPoi]에 등록된 모든 [Badge]를 삭제합니다.
  Future<void> removeAllBadge() async {
    _badges.values.forEach(removeBadge);
  }
}
