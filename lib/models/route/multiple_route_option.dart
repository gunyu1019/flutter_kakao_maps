part of '../../kakao_map_sdk.dart';

/// 다중 선형([MultipleRoute])을 정의하기 위한 객체입니다.
/// [RouteController.addMultipleRoute] 함수에서 매개변수로 입력됩니다.
class MultipleRouteOption with KMessageable {
  /// 다중 선형([MultipleRoute])의 고유한 ID 입니다.
  final String? id;

  /// 다중 선형([MultipleRoute])의 zOrder 입니다.
  final int zOrder;

  final List<CurveType> _curveType;
  final List<List<LatLng>> _points;
  final List<int> _styleIndex;
  final List<RouteStyle> _styles;

  MultipleRouteOption(
    List<RouteStyle>? styles, {
    List<LatLng>? point,
    CurveType curveType = CurveType.none,
    this.zOrder = 10000,
    this.id,
  })  : _points = [],
        _styles = styles ?? [],
        _curveType = [],
        _styleIndex = [] {
    if (point != null && _styles.isNotEmpty) {
      addRouteWithIndex(point, 0, curveType);
    }
  }

  /// [MultipleRoute]에 구현할 선형을 추가합니다.
  /// [point] 매개변수에는 새롭게 추가할 선형의 지점과,
  /// [style] 매개변수에는 새롭게 구현할 선형의 스타일을 입력받습니다.
  void addRouteWithStyle(List<LatLng> point, RouteStyle style,
      [CurveType curveType = CurveType.none]) {
    _styles.add(style);
    _points.add(point);
    _styleIndex.add(_styles.length);
    _curveType.add(curveType);
  }

  /// [MultipleRoute]에 구현할 선형을 추가합니다.
  /// MultipleRouteOption.styles 배열 [styleIndex]에 따라 스타일으로 정의합니다.
  void addRouteWithIndex(List<LatLng> point, int styleIndex,
      [CurveType curveType = CurveType.none]) {
    _points.add(point);
    _styleIndex.add(styleIndex);
    _curveType.add(curveType);
  }

  /// [RouteStyle]를 [MultipleRouteOption]에 추가합니다.
  /// 추가된 [RouteStyle]은 [MultipleRouteOption.addRouteWithIndex] 함수에서 [styleIndex] 매개변수로 이용할 수 있습니다.
  void addRouteStyle(RouteStyle style) => _styles.add(style);

  /// [MultipleRouteOption]에 추가된 선형 순서대로 정의된 지점을 불러옵니다.
  List<LatLng>? getPoints(int index) => _points[index];

  /// [index]에 따라 [RouteStyle]을 불러옵니다.
  RouteStyle? getStyle(int index) => _styles[index];

  @override
  Map<String, dynamic> toMessageable() {
    return <String, dynamic>{
      "id": id,
      "zOrder": zOrder,
      "routes": _points.mapIndexed((index, points) => {
            <String, dynamic>{
              "points": points,
              "styleIndex": _styleIndex[index],
              "curveType": _curveType[index],
              "styleId": _styles[_styleIndex[index]].id
            }
          })
    };
  }

  bool _isStyleAdded() {
    return _styles.map((e) => e.id).any((e) => e == null);
  }
}
