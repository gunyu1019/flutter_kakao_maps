import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodCall? lastPlatformViewsCreateCall;

  Future<dynamic> platformViewsHandler(MethodCall call) async {
    if (call.method == 'create') {
      lastPlatformViewsCreateCall = call;
      final args = Map<String, dynamic>.from(call.arguments as Map);
      return args['id'] as int? ?? 0;
    }
    return null;
  }

  setUp(() {
    lastPlatformViewsCreateCall = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform_views,
      platformViewsHandler,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, null);
    debugDefaultTargetPlatformOverride = null;
  });

  Widget wrapApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: child),
      ),
    );
  }

  testWidgets('should render KakaoMap by default', (tester) async {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    try {
      await tester.pumpWidget(
        wrapApp(
          KakaoMap(
            key: UniqueKey(),
            onMapReady: (_) {},
          ),
        ),
      );

      expect(find.byType(KakaoMap), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });

  testWidgets('should render platform-specific Platform View widget',
      (tester) async {
    final previous = debugDefaultTargetPlatformOverride;

    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        wrapApp(
          KakaoMap(
            key: UniqueKey(),
            onMapReady: (_) {},
          ),
        ),
      );

      expect(find.byType(PlatformViewLink), findsOneWidget);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        wrapApp(
          KakaoMap(
            key: UniqueKey(),
            onMapReady: (_) {},
          ),
        ),
      );

      expect(find.byType(UiKitView), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });

  testWidgets('should pass initial option as creationParams', (tester) async {
    const option = KakaoMapOption(
      position: LatLng(37.501, 127.039),
      zoomLevel: 12,
      mapType: MapType.skyview,
      viewName: 'widget-test-view',
      visible: false,
      tag: 'widget-test-tag',
    );

    final expectedParams = option.toMessageable();

    final previous = debugDefaultTargetPlatformOverride;

    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        wrapApp(
          KakaoMap(
            key: UniqueKey(),
            onMapReady: (_) {},
            option: option,
          ),
        ),
      );

      expect(lastPlatformViewsCreateCall, isNotNull);

      final androidCreateArgs = Map<String, dynamic>.from(
          lastPlatformViewsCreateCall!.arguments as Map);
      final encodedAndroidParams = androidCreateArgs['params'] as Uint8List?;

      expect(encodedAndroidParams, isNotNull);

      final decodedAndroidParams = const StandardMessageCodec().decodeMessage(
        ByteData.sublistView(encodedAndroidParams!),
      );

      expect(decodedAndroidParams, equals(expectedParams));

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        wrapApp(
          KakaoMap(
            key: UniqueKey(),
            onMapReady: (_) {},
            option: option,
          ),
        ),
      );

      final uiKitView = tester.widget<UiKitView>(find.byType(UiKitView));
      final iosCreationParams =
          Map<String, dynamic>.from(uiKitView.creationParams as Map);

      expect(iosCreationParams, equals(expectedParams));
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });
}
