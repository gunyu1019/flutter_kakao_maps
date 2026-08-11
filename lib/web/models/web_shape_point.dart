part of '../kakao_map_sdk_web.dart';

class WebShapePoint {
  final List<LatLng>? _absolutePath;
  final List<List<LatLng>> _absoluteHoles = [];
  final dynamic _relativePayload;
  final WebMapProjection? _projection;

  WebShapePoint([List<LatLng>? path])
      : _absolutePath = path ?? [],
        _relativePayload = null,
        _projection = null;

  WebShapePoint._relative(this._relativePayload, this._projection)
      : _absolutePath = null;

  List<LatLng> get path => _relativePayload == null
      ? _absolutePath!
      : _getRelativePoint(_relativePayload, _projection!);

  List<List<LatLng>> get holes {
    if (_relativePayload == null) return _absoluteHoles;
    final rawHoles = _relativePayload["holes"] as Iterable?;
    if (rawHoles == null) return [];
    return rawHoles
        .map<List<LatLng>>(
          (hole) => _getRelativePoint(hole, _projection!),
        )
        .toList();
  }

  Iterable<List<LatLng>> get rings sync* {
    yield path;
    yield* holes;
  }

  bool contains(LatLng point) {
    if (!_ringContains(path, point)) return false;
    return holes.every((hole) => !_ringContains(hole, point));
  }

  static bool _ringContains(List<LatLng> ring, LatLng point) {
    if (ring.length < 3) return false;
    var inside = false;
    for (var current = 0, previous = ring.length - 1;
        current < ring.length;
        previous = current++) {
      final currentPoint = ring[current];
      final previousPoint = ring[previous];
      final crossesLatitude = (currentPoint.latitude > point.latitude) !=
          (previousPoint.latitude > point.latitude);
      if (!crossesLatitude) continue;
      final intersectionLongitude =
          (previousPoint.longitude - currentPoint.longitude) *
                  (point.latitude - currentPoint.latitude) /
                  (previousPoint.latitude - currentPoint.latitude) +
              currentPoint.longitude;
      if (point.longitude < intersectionLongitude) inside = !inside;
    }
    return inside;
  }

  /// Native DimScreen polygon strokes are closed even when the serialized
  /// ring does not repeat its first point. Kakao Web draws the stroke with a
  /// separate Polyline, so close each usable ring explicitly.
  Iterable<List<LatLng>> get strokeRings => rings
      .where((ring) => ring.length >= 2)
      .map((ring) => ring.first == ring.last ? ring : [...ring, ring.first]);

  JSArray<JSArray<WebLatLng>> toPolygonPath() {
    return rings
        .map((ring) => ring.map(WebLatLng.fromLatLng).toList().toJS)
        .toList()
        .toJS;
  }

  JSArray<WebLatLng> toPolylinePath() =>
      path.map(WebLatLng.fromLatLng).toList().toJS;

  factory WebShapePoint.fromMessageable(
    dynamic payload, [
    WebMapProjection? projection,
  ]) =>
      switch (payload["type"]) {
        0 => WebShapePoint.fromMapPoint(payload),
        1 => WebShapePoint.fromDotPoint(payload, projection),
        Object() || null => throw UnimplementedError(),
      };

  factory WebShapePoint.fromMapPoint(dynamic payload) {
    final path = <LatLng>[];
    for (final rawPoint in payload["points"] as Iterable) {
      path.add(LatLng.fromMessageable(rawPoint));
    }
    final point = WebShapePoint(path);

    if (payload.containsKey("holes")) {
      for (final rawHole in payload["holes"] as Iterable) {
        final hole = <LatLng>[];
        for (final rawPoint in rawHole as Iterable) {
          hole.add(LatLng.fromMessageable(rawPoint));
        }
        point._absoluteHoles.add(hole);
      }
    }
    return point;
  }

  static List<KPoint> relativeOffsets(dynamic payload) {
    final dotType = PointShapeType.values.firstWhere(
      (e) => e.value == payload["dotType"],
    );
    final clockwise = payload["clockwise"] as bool? ?? true;
    late List<KPoint> offsets;

    switch (dotType) {
      case PointShapeType.circle:
        final radius = (payload["radius"] as num).toDouble();
        final vertexCount = (payload["vertexCount"] as num?)?.toInt() ?? 360;
        if (vertexCount < 3) {
          throw ArgumentError.value(
            vertexCount,
            "vertexCount",
            "CirclePoint requires at least 3 vertices",
          );
        }
        offsets = List.generate(vertexCount, (index) {
          final angle = 2 * math.pi * index / vertexCount;
          return KPoint(
            radius * math.sin(angle),
            -radius * math.cos(angle),
          );
        });
      case PointShapeType.rectangle:
        final halfWidth = (payload["width"] as num).toDouble() / 2;
        final halfHeight = (payload["height"] as num).toDouble() / 2;
        offsets = [
          KPoint(-halfWidth, -halfHeight),
          KPoint(halfWidth, -halfHeight),
          KPoint(halfWidth, halfHeight),
          KPoint(-halfWidth, halfHeight),
        ];
      case PointShapeType.points:
      case PointShapeType.none:
        throw UnimplementedError();
    }

    return clockwise ? offsets : offsets.reversed.toList();
  }

  static List<LatLng> _getRelativePoint(
    dynamic payload,
    WebMapProjection projection,
  ) {
    final basePoint = LatLng.fromMessageable(payload["basePoint"]);
    final baseContainerPoint = projection.containerPointFromCoords(
      WebLatLng.fromLatLng(basePoint),
    );
    return relativeOffsets(payload).map((offset) {
      final containerPoint = WebPoint(
        baseContainerPoint.x + offset.x.toDouble(),
        baseContainerPoint.y + offset.y.toDouble(),
      );
      return projection.coordsFromContainerPoint(containerPoint).toLatLng();
    }).toList();
  }

  factory WebShapePoint.fromDotPoint(
    dynamic payload, [
    WebMapProjection? projection,
  ]) {
    if (projection == null) {
      throw ArgumentError.notNull("projection");
    }
    return WebShapePoint._relative(payload, projection);
  }
}
