part of '../kakao_map_sdk_web.dart';

class WebShapePoint {
  /// Matches the effective size produced by Kakao Maps SDK for iOS primitives.
  ///
  /// Although the native API accepts meter values, its spherical-coordinate
  /// helper renders CirclePoint and RectanglePoint at approximately 80% of the
  /// requested distance. Apply the same scale on Web for platform parity.
  static const double nativePrimitiveScale = 0.8;

  final List<LatLng> _path;
  final List<List<LatLng>> _holes = [];
  final bool _isRelative;

  WebShapePoint([List<LatLng>? path])
      : _path = path ?? [],
        _isRelative = false;

  WebShapePoint._relative(this._path) : _isRelative = true;

  List<LatLng> get path => _path;

  List<List<LatLng>> get holes => _holes;

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

  /// MapPoint stroke paths preserve the caller's open/closed input, matching
  /// the native SDKs. CirclePoint and RectanglePoint paths represent closed
  /// shapes, so close their generated Web Polyline rings explicitly.
  Iterable<List<LatLng>> get strokeRings {
    final usableRings = rings.where((ring) => ring.length >= 2);
    if (!_isRelative) return usableRings;
    return usableRings.map(
      (ring) => ring.first == ring.last ? ring : [...ring, ring.first],
    );
  }

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
        point._holes.add(hole);
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
        final vertexCount = (payload["vertexCount"] as num?)?.toInt() ?? 720;
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

  /// Converts native relative model coordinates into geographic coordinates.
  ///
  /// Kakao Maps SDK for iOS builds these primitives on a spherical coordinate
  /// system. Their radius, width, and height therefore describe real-world
  /// distances rather than browser screen pixels. The resulting distances are
  /// scaled to match the effective native primitive size.
  static List<LatLng> geographicPoints(
    dynamic payload,
  ) {
    final basePoint = LatLng.fromMessageable(payload["basePoint"]);
    return relativeOffsets(payload).map((offset) {
      final distance = math.sqrt(
        offset.x * offset.x + offset.y * offset.y,
      );
      final bearing = math.atan2(offset.x, -offset.y) * 180 / math.pi;
      return basePoint.offset(distance * nativePrimitiveScale, bearing);
    }).toList();
  }

  factory WebShapePoint.fromDotPoint(
    dynamic payload, [
    WebMapProjection? projection,
  ]) {
    final point = WebShapePoint._relative(geographicPoints(payload));
    final rawHoles = payload["holes"] as Iterable?;
    if (rawHoles != null) {
      for (final rawHole in rawHoles) {
        point._holes.add(geographicPoints(rawHole));
      }
    }
    return point;
  }
}
