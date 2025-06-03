part of '../../kakao_map_sdk.dart';

/// 다중 선형([MultipleRoute])을 정의하기 위한 객체입니다.
/// [RouteController.addMultipleRoute] 함수에서 매개변수로 입력됩니다.
class MultipleRouteOption with BaseMultipleRoute, KMessageable {
  /// 다중 선형([MultipleRoute])의 고유한 ID 입니다.
  final String? id;

  /// 다중 선형([MultipleRoute])의 zOrder 입니다.
  final int zOrder;

  @override
  final List<RouteStyle> styles;

  @override
  final List<RouteSegment> segments;

  MultipleRouteOption(
    List<RouteStyle>? style, {
    this.zOrder = 10000,
    this.id,
  })  : styles = style ?? [],
        segments = [];

  /// [MultipleRoute]에 구현할 선형을 추가합니다.
  /// [point] 매개변수에는 새롭게 추가할 선형의 지점과,
  /// [style] 매개변수에는 새롭게 구현할 선형의 스타일을 입력받습니다.
  void addRouteWithStyle(List<LatLng> point, RouteStyle style,
      [CurveType curveType = CurveType.none]) {
    styles.add(style);
    segments.add(RouteSegment._(point, styles.length, curveType, this));
  }

  /// [MultipleRoute]에 구현할 선형을 추가합니다.
  /// MultipleRouteOption.styles 배열 [styleIndex]에 따라 스타일으로 정의합니다.
  void addRouteWithIndex(List<LatLng> point, int styleIndex,
      [CurveType curveType = CurveType.none]) {
    segments.add(RouteSegment._(point, styleIndex, curveType, this));
  }

  /// [RouteStyle]를 [MultipleRouteOption]에 추가합니다.
  /// 추가된 [RouteStyle]은 [MultipleRouteOption.addRouteWithIndex] 함수에서 [styleIndex] 매개변수로 이용할 수 있습니다.
  void addRouteStyle(RouteStyle style) => styles.add(style);

  /// [MultipleRouteOption]에 추가된 선형 순서대로 정의된 지점을 불러옵니다.
  List<LatLng>? getPoints(int index) => segments[index].points;

  @override
  Map<String, dynamic> toMessageable() {
    return <String, dynamic>{
      "id": id,
      "zOrder": zOrder,
      "routes": segments.map((RouteSegment segment) {
        var parsedRoute = segment.toMessageable();
        parsedRoute["styleId"] = styles[segment.styleIndex].id;
        return parsedRoute;
      }).toList()
    };
  }

  factory MultipleRouteOption.fromMessageable(
      dynamic payload, List<RouteStyle> styles) {
    final option =
        MultipleRouteOption([], id: payload["id"], zOrder: payload["zOrder"]);
    payload["routes"]
        .map((e) => RouteSegment.fromMessageable(e, option))
        .forEach(option.segments.add);
    option.styles.addAll(styles);

    return option;
  }

  bool _isStyleAdded() => !styles.any((e) => !e._isAdded);
}
