import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  test('documented overlay and curve enum names match the public API', () {
    expect(MapOverlay.hillsading.value, 'HILLSHADING');
    expect(CurveType.left.value, 1);
    expect(CurveType.right.value, 2);
  });

  test('documented zoom-level style examples compile', () {
    final polylineStyle = PolylineStyle(Colors.grey, 4, zoomLevel: 0)
      ..addStyle(14, color: Colors.blue, lineWidth: 8)
      ..addStyle(17, color: Colors.blue, lineWidth: 12);
    final routeStyle = RouteStyle(Colors.grey, 4, zoomLevel: 0)
      ..addStyle(14, Colors.blue, 8)
      ..addStyle(17, Colors.blue, 12);

    expect(polylineStyle.otherStyleLevel, [14, 17]);
    expect(routeStyle.otherStyleLevel, [14, 17]);
  });
}
