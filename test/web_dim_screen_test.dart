@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk/web/kakao_map_sdk_web.dart';

void main() {
  test('WebShapePoint decodes every MapPoint hole as a LatLng ring', () {
    const exterior = [
      LatLng(37.0, 127.0),
      LatLng(37.0, 128.0),
      LatLng(38.0, 128.0),
      LatLng(38.0, 127.0),
    ];
    const hole = [
      LatLng(37.2, 127.2),
      LatLng(37.2, 127.8),
      LatLng(37.8, 127.8),
      LatLng(37.8, 127.2),
    ];
    final source = MapPoint(const [
      LatLng(37.0, 127.0),
      LatLng(37.0, 128.0),
      LatLng(38.0, 128.0),
      LatLng(38.0, 127.0),
    ]);
    source.addHole(hole);

    final decoded = WebShapePoint.fromMapPoint(source.toMessageable());
    final rings = decoded.rings.toList();

    expect(rings, hasLength(2));
    expect(rings.first, exterior);
    expect(rings.last, hole);
    expect(rings.expand((ring) => ring), everyElement(isA<LatLng>()));
  });
}
