import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk_example/main.dart' as app;

Future<void> _launchExampleApp(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 5));
}

Future<KakaoMapController> _waitForController(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    try {
      final dynamic mapViewState = tester.state(find.byType(app.KakaoMapView));
      return mapViewState.controller as KakaoMapController;
    } catch (_) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  throw TestFailure('KakaoMapController was not ready in time.');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Kakao Map Integration Tests', () {
    testWidgets('example app(MyApp) boots and renders KakaoMap',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);

      expect(find.byType(KakaoMap), findsOneWidget);
    });

    testWidgets('getCameraPosition returns initial center from native SDK',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      final CameraPosition initialCamera = await controller.getCameraPosition();

      expect(initialCamera.position.latitude, isNotNaN);
      expect(initialCamera.position.longitude, isNotNaN);
    });

    testWidgets('moveCamera changes map center in native map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      const LatLng target = LatLng(37.56664910407437, 126.97822134589721);

      final CameraPosition beforeMove = await controller.getCameraPosition();

      await controller.moveCamera(
        CameraUpdate.newCenterPosition(target),
        animation: const CameraAnimation(3000),
      );

      await tester.pump(const Duration(seconds: 4));

      final CameraPosition afterMove = await controller.getCameraPosition();

      expect(beforeMove.position.latitude != afterMove.position.latitude, isTrue);
      expect(beforeMove.position.longitude != afterMove.position.longitude, isTrue);
      expect(afterMove.position.latitude,
          closeTo(target.latitude, 0.0005));
      expect(afterMove.position.longitude,
          closeTo(target.longitude, 0.0005));
    });

    testWidgets('addPoi succeeds without crash on real native map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      final PoiStyle style =
          PoiStyle(icon: KImage.fromAsset('assets/image/location.png', 40, 60));

      final Poi poi = await controller.labelLayer.addPoi(
        const LatLng(37.5651, 126.98955),
        style: style,
        text: 'integration-poi',
      );

      expect(poi.id.isNotEmpty, isTrue);
    });
  });
}
