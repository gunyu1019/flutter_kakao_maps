@TestOn('browser')
library;

import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:web/web.dart' as web;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    try {
      ui_web.platformViewRegistry.registerViewFactory('plugin/kakao_map', (
        int viewId, {
        Object? params,
      }) {
        return web.HTMLDivElement()
          ..id = 'test_map_$viewId'
          ..style.width = '100%'
          ..style.height = '100%';
      });
    } catch (_) {}
  });

  Widget wrapApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SizedBox.expand(child: child)),
    );
  }

  testWidgets('should render KakaoMap as HtmlElementView on web', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(KakaoMap(onMapReady: (_) {})));

    expect(find.byType(KakaoMap), findsOneWidget);
    expect(find.byType(HtmlElementView), findsOneWidget);

    final htmlElementView = tester.widget<HtmlElementView>(
      find.byType(HtmlElementView),
    );
    expect(htmlElementView.viewType, 'plugin/kakao_map');
  });

  testWidgets('should pass creationParams on web', (tester) async {
    const option = KakaoMapOption(
      position: LatLng(37.501, 127.039),
      zoomLevel: 12,
      mapType: MapType.skyview,
      viewName: 'web-widget-test-view',
      visible: false,
      tag: 'web-widget-test-tag',
    );

    await tester.pumpWidget(
      wrapApp(KakaoMap(onMapReady: (_) {}, option: option)),
    );

    final htmlElementView = tester.widget<HtmlElementView>(
      find.byType(HtmlElementView),
    );
    final creationParams = Map<String, dynamic>.from(
      htmlElementView.creationParams as Map,
    );

    expect(creationParams, equals(option.toMessageable()));
  });

  test('should preserve Web gesture values on an iOS browser', () async {
    final previous = debugDefaultTargetPlatformOverride;
    final handler = _TestControllerHandler();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    try {
      await handler.handle(
        const MethodCall('onCameraMoveStart', {'gesture': 5}),
      );
      expect(handler.lastGesture, GestureType.pan);

      await handler.handle(
        const MethodCall('onCameraMoveEnd', {
          'gesture': 7,
          'position': {
            'latitude': 37.3947,
            'longitude': 127.1112,
            'zoomLevel': 17,
            'rotationAngle': 0.0,
            'tiltAngle': 0.0,
          },
        }),
      );
      expect(handler.lastGesture, GestureType.zoom);
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });
}

class _TestControllerHandler with KakaoMapControllerHandler {
  GestureType? lastGesture;

  @override
  void onCameraMoveStart(GestureType gestureType) {
    lastGesture = gestureType;
  }

  @override
  void onCameraMoveEnd(
    CameraPosition position,
    GestureType gestureType,
  ) {
    lastGesture = gestureType;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
