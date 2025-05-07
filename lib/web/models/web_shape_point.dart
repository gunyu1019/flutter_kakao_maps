part of '../kakao_map_sdk_web.dart';

class WebShapePoint {
  final List<LatLng> path;
  final List<List<LatLng>> holes = [];

  WebShapePoint([List<LatLng>? path]) : path = path ?? [];

  JSArray<JSArray<WebLatLng>> toPolygonPath() {
    final path = [this.path.map(WebLatLng.fromLatLng).toList().toJS];
    holes
        .map((e) => e.map(WebLatLng.fromLatLng).toList().toJS)
        .forEach(path.add);
    return path.toJS;
  }

  JSArray<WebLatLng> toPolylinePath() =>
      path.map(WebLatLng.fromLatLng).toList().toJS;

  factory WebShapePoint.fromMessageable(dynamic payload) =>
      switch (payload["type"]) {
        0 => WebShapePoint.fromMapPoint(payload),
        1 => WebShapePoint.fromDotPoint(payload),
        Object() || null => throw UnimplementedError(),
      };

  factory WebShapePoint.fromMapPoint(dynamic payload) {
    final path = payload["points"].map<LatLng>(LatLng.fromMessageable).toList();
    final point = WebShapePoint(path);

    if (payload.containsKey("holes") && payload["holes"].length > 0) {
      payload["holes"]
          .map<List<LatLng>>(
              (e1) => e1.map<LatLng>((e2) => LatLng.fromMessageable).toList())
          .forEach(point.holes.add);
    }
    return point;
  }

  static List<LatLng> _getPointFromDotPoint(dynamic payload,
      [LatLng? basePoint]) {
    List<LatLng> absolutePoint = <LatLng>[];
    final basePoint0 =
        basePoint ?? LatLng.fromMessageable(payload["basePoint"]);
    final dotType =
        PointShapeType.values.firstWhere((e) => e.value == payload["dotType"]);
    final clockwise = payload["clockwise"];

    switch (dotType) {
      case PointShapeType.circle:
        final radius = payload["radius"];
        Iterable.generate(360)
            .map<LatLng>((deg) => basePoint0.offset(radius, deg.toDouble()))
            .forEach(absolutePoint.add);
      case PointShapeType.rectangle:
        final width = payload["width"];
        final height = payload["height"];
        absolutePoint.addAll([
          basePoint0.offset(-width * .5, 90).offset(height * .5, 0),
          basePoint0.offset(height * .5, 0).offset(width * .5, 90),
          basePoint0.offset(width * .5, 90).offset(-height * .5, 0),
          basePoint0.offset(-height * .5, 0).offset(-width * .5, 90),
          basePoint0.offset(-width * .5, 90).offset(height * .5, 0),
        ]);
      case PointShapeType.points:
      case PointShapeType.none:
        throw UnimplementedError();
    }

    if (clockwise) absolutePoint = absolutePoint.reversed.toList();
    return absolutePoint;
  }

  factory WebShapePoint.fromDotPoint(dynamic payload) {
    final point = WebShapePoint(_getPointFromDotPoint(payload));
    if (payload.containsKey("holes") && payload["holes"].length > 0) {
      payload["holes"].map(_getPointFromDotPoint).forEach(point.holes.add);
    }
    return point;
  }
}
