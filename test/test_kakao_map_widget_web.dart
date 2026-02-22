@TestOn('browser')
library;

import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:web/web.dart' as web;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        'plugin/kakao_map',
        (int viewId, {Object? params}) {
          return web.HTMLDivElement()
            ..id = 'test_map_$viewId'
            ..style.width = '100%'
            ..style.height = '100%';
        },
      );
    } catch (_) {}
  });

  Widget _wrapApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: child),
      ),
    );
  }

  testWidgets('should render KakaoMap as HtmlElementView on web',
      (tester) async {
    await tester.pumpWidget(
      _wrapApp(
        KakaoMap(
          onMapReady: (_) {},
        ),
      ),
    );

    expect(find.byType(KakaoMap), findsOneWidget);
    expect(find.byType(HtmlElementView), findsOneWidget);

    final htmlElementView =
        tester.widget<HtmlElementView>(find.byType(HtmlElementView));
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
      _wrapApp(
        KakaoMap(
          onMapReady: (_) {},
          option: option,
        ),
      ),
    );

    final htmlElementView =
        tester.widget<HtmlElementView>(find.byType(HtmlElementView));
    final creationParams =
        Map<String, dynamic>.from(htmlElementView.creationParams as Map);

    expect(creationParams, equals(option.toMessageable()));
  });
}
