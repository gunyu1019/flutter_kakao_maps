part of '../../kakao_map_sdk.dart';

/// 도형의 위치를 구현하는 객체입니다.
/// [BasePoint]을 사용하는 객체를 이용하여 [Polyline]과 [Polygon] 도형을 구성합니다.
/// [BasePoint]을 상속받는 객체로는 [MapPoint], [CirclePoint], [RectanglePoint]가 있습니다.
abstract class BasePoint with KMessageable {
  abstract final int type;
}
