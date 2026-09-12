part of '../../kakao_map_sdk.dart';

/// 도형의 위치를 구현하는 객체입니다.
/// [BasePoint]을 사용하는 객체를 이용하여 [Polyline]과 [Polygon] 도형을 구성합니다.
/// [BasePoint]을 상속받는 객체로는 [MapPoint], [CirclePoint], [RectanglePoint]가 있습니다.
abstract class BasePoint with KMessageable {
  BasePoint({this.mergeOverlappingHoles = false});

  /// 서로 겹치거나 꼭지점/변을 공유하는 Polygon hole을 하나로 합칠지 여부입니다.
  ///
  /// 기본값은 `false`이며 Polygon을 생성하거나 위치를 변경할 때 적용됩니다.
  bool mergeOverlappingHoles;

  /// 서로 겹치는 Polygon hole을 하나로 합칠지 설정합니다.
  void setMergeOverlappingHoles(bool mergeOverlappingHoles) {
    this.mergeOverlappingHoles = mergeOverlappingHoles;
  }

  abstract final int type;
}
