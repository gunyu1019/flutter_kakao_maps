import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk_example/main.dart' as app;

Future<void> _launchExampleApp(WidgetTester tester) async {
  await dotenv.load(fileName: 'assets/config/.env');
  await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);
  await tester.pumpWidget(const app.MyApp());
  await tester.pumpAndSettle(const Duration(seconds: 5));
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
    testWidgets('launchExampleApp should render KakaoMap',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);

      expect(find.byType(KakaoMap), findsOneWidget);
    });

    testWidgets('getCameraPosition should return initial center from native SDK',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      final CameraPosition initialCamera = await controller.getCameraPosition();

      expect(initialCamera.position.latitude, isNotNaN);
      expect(initialCamera.position.longitude, isNotNaN);
    });

    testWidgets('moveCamera should change map center in native map',
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

    testWidgets('addPoi should successfully add poi to the map',
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

    testWidgets('addPolyline should successfully add polyline to the map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      final MapPoint polylinePoint = MapPoint(const [
        LatLng(37.5662952, 126.9779451),
        LatLng(37.5656947, 126.9851262),
        LatLng(37.5701481, 126.9921044),
      ]);

      final PolylineStyle polylineStyle =
          PolylineStyle(Colors.deepOrange, 8, strokeWidth: 2);

      expect(
        () => controller.shapeLayer
            .addPolylineShape(polylinePoint, polylineStyle, PolylineCap.round),
        returnsNormally,
      );
    });

    testWidgets('addPolygon should successfully add polygon to the map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      final MapPoint polygonPoint = MapPoint(const [
        LatLng(37.5718178, 126.9768877),
        LatLng(37.5697729, 126.9828279),
        LatLng(37.5658921, 126.9817724),
        LatLng(37.5668726, 126.9755622),
      ]);

      final PolygonStyle polygonStyle = PolygonStyle(
        Colors.blue.withValues(alpha: 0.35),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      );

      expect(
        () => controller.shapeLayer.addPolygonShape(polygonPoint, polygonStyle),
        returnsNormally,
      );
    });

    testWidgets('addRoute should successfully add route to the map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      const List<LatLng> routePoints = [
        LatLng(37.555946, 126.972317),
        LatLng(37.5662952, 126.9779451),
        LatLng(37.5703776, 126.9920616),
      ];

      final RouteStyle routeStyle = RouteStyle(
        Colors.green,
        8,
        strokeColor: Colors.white,
        strokeWidth: 2,
      );

      expect(
        () => controller.routeLayer.addRoute(routePoints, routeStyle),
        returnsNormally,
      );
    });

    testWidgets('addMultipleRoute should successfully add multiple routes to the map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      const List<List<LatLng>> routeGroups = [
        [
          LatLng(37.56664910407437, 126.97822134589721),
          LatLng(37.5703776, 126.9920616),
          LatLng(37.572814, 127.008973),
        ],
        [
          LatLng(37.39479412020964, 127.11116968185037),
          LatLng(37.399109, 127.108382),
          LatLng(37.403739, 127.107259),
        ],
      ];

      final List<RouteStyle> routeStyles = [
        RouteStyle(
          Colors.blue,
          7,
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
        RouteStyle(
          Colors.red,
          7,
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
      ];

      final MultipleRouteOption option = MultipleRouteOption(routeStyles);
      option.addRouteWithIndex(routeGroups[0], 0);
      option.addRouteWithIndex(routeGroups[1], 1);

      expect(
        () => controller.routeLayer.addMultipleRoute(option),
        returnsNormally,
      );
    });

    testWidgets('addLodPoi should successfully add lod poi to the map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      final List<Map<String, dynamic>> lodData = [
        {
          'position': const LatLng(37.56664910407437, 126.97822134589721),
          'text': 'seoul-city-hall-lod',
          'iconWidth': 36,
          'iconHeight': 54,
        },
        {
          'position': const LatLng(37.39479412020964, 127.11116968185037),
          'text': 'kakao-pangyo-lod',
          'iconWidth': 30,
          'iconHeight': 46,
        },
      ];

      expect(() async {
        for (final data in lodData) {
          final PoiStyle style = PoiStyle(
            icon: KImage.fromAsset(
              'assets/image/location.png',
              data['iconWidth'] as int,
              data['iconHeight'] as int,
            ),
          );

          await controller.lodLabelLayer.addLodPoi(
            data['position'] as LatLng,
            style: style,
            text: data['text'] as String,
          );
        }
      }, returnsNormally);
    });

    testWidgets('addPolylineText should successfully add polyline text to the map',
        (WidgetTester tester) async {
      await _launchExampleApp(tester);
      final KakaoMapController controller = await _waitForController(tester);

      const List<LatLng> textPath = [
        LatLng(37.56664910407437, 126.97822134589721),
        LatLng(37.5703776, 126.9920616),
      ];

      final PolylineTextStyle textStyle = PolylineTextStyle(
        16,
        Colors.black,
        strokeSize: 2,
        strokeColor: Colors.white,
      );

      expect(
        () => controller.labelLayer.addPolylineText(
          'Seoul City Hall route',
          textPath,
          style: textStyle,
        ),
        returnsNormally,
      );
    });
  });
}
