part of '../../kakao_map_sdk.dart';


/// [MultipleRoute]에서 구성하는 선형의 요소입니다.
class RouteSegment {
  int styleIndex;

  List<LatLng> points;
  
  BaseMultipleRoute parent;

  RouteSegment._(this.points, this.styleIndex, this.parent);

  RouteStyle get style => parent.styles[styleIndex];
}