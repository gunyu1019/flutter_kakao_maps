import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewId = 777;
  final viewChannel = ChannelType.view.channelWithId(viewId);
  final overlayChannel = ChannelType.overlay.channelWithId(viewId);

  late KakaoMapController controller;

  String orFallback(String? requested, String fallback) {
    return (requested != null && requested.isNotEmpty) ? requested : fallback;
  }

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(viewChannel, (call) async => null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(overlayChannel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final type = args['type'] as int?;

      switch (call.method) {
        case 'addPoiStyle':
          return orFallback(
            args['styleId'] as String?,
            'mock-poi-style-id',
          );

        case 'addPoi':
          final poi = Map<String, dynamic>.from(args['poi'] as Map);
          final requested = poi['id'] as String?;
          if (type == OverlayType.lodLabel.value) {
            return orFallback(requested, 'mock-lod-poi-id');
          }
          return orFallback(requested, 'mock-poi-id');

        case 'addLodPoi':
          final poi = Map<String, dynamic>.from(args['poi'] as Map);
          return orFallback(poi['id'] as String?, 'mock-lod-poi-id');

        case 'addPolylineText':
          final label = Map<String, dynamic>.from(args['label'] as Map);
          return orFallback(
            label['id'] as String?,
            'mock-polyline-text-id',
          );

        case 'addPoiBadge':
          final badge = Map<String, dynamic>.from(args['badge'] as Map);
          final requestedBadgeId = badge['id'] as String?;
          final poiId = args['poiId'] as String?;
          return orFallback(requestedBadgeId, '${poiId ?? 'poi'}-badge-id');

        case 'addPolylineShapeStyle':
          return orFallback(
            args['styleId'] as String?,
            'mock-polyline-style-id',
          );

        case 'addPolygonShapeStyle':
          return orFallback(
            args['styleId'] as String?,
            'mock-polygon-style-id',
          );

        case 'addPolylineShape':
          final polyline = Map<String, dynamic>.from(
            args['polyline'] as Map,
          );
          return orFallback(polyline['id'] as String?, 'mock-polyline-id');

        case 'addPolygonShape':
          final polygon = Map<String, dynamic>.from(args['polygon'] as Map);
          return orFallback(polygon['id'] as String?, 'mock-polygon-id');

        case 'addRouteStyle':
          return orFallback(
            args['styleId'] as String?,
            'mock-route-style-id',
          );

        case 'addRoute':
        case 'addMultipleRoute':
          final route = Map<String, dynamic>.from(args['route'] as Map);
          final fallback = call.method == 'addRoute'
              ? 'mock-route-id'
              : 'mock-multi-route-id';
          return orFallback(route['id'] as String?, fallback);

        case 'addHighlightPolygonShape':
          final polygon = Map<String, dynamic>.from(args['polygon'] as Map);
          return orFallback(
            polygon['id'] as String?,
            'mock-dim-polygon-id',
          );

        default:
          return null;
      }
    });

    controller = KakaoMapControllerImplement(
      viewChannel,
      overlayChannel: overlayChannel,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(overlayChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(viewChannel, null);
  });

  group('Marker Mocking Tests', () {
    test(
      'addPoiStyle returns style id from overlay channel response',
      () async {
        final style = PoiStyle(
          id: 'poi-style-explicit-id',
          icon: KImage.fromData(Uint8List.fromList([1, 2, 3]), 20, 20),
        );

        final styleId = await controller.addPoiStyle(style);

        expect(styleId, 'poi-style-explicit-id');
        expect(style.id, 'poi-style-explicit-id');
      },
    );

    test('addPoi returns Poi with id from overlay channel response', () async {
      final style = PoiStyle(
        id: 'poi-style-for-poi',
        icon: KImage.fromData(Uint8List.fromList([3, 2, 1]), 16, 16),
      );
      await controller.addPoiStyle(style);

      final poi = await controller.labelLayer.addPoi(
        const LatLng(37.55, 126.98),
        style: style,
        id: 'poi-explicit-id',
        text: 'marker-title',
        rank: 9,
      );

      expect(poi.id, 'poi-explicit-id');
      expect(poi.position.latitude, 37.55);
      expect(poi.position.longitude, 126.98);
      expect(poi.text, 'marker-title');
      expect(poi.rank, 9);
    });

    test(
      'addBadge returns Badge with id from overlay channel response',
      () async {
        final style = PoiStyle(
          id: 'poi-style-badge',
          icon: KImage.fromData(Uint8List.fromList([10, 11]), 12, 12),
        );
        await controller.addPoiStyle(style);
        final poi = await controller.labelLayer.addPoi(
          const LatLng(37.4, 127.1),
          style: style,
          id: 'poi-badge-target',
        );

        final badge = await poi.addBadge(
          KImage.fromData(Uint8List.fromList([8, 8, 8]), 10, 10),
          4,
          -3,
          badgeId: 'badge-explicit-id',
        );

        expect(badge.id, 'poi-badge-target-badge-id');
        expect(badge.offsetX, 4);
        expect(badge.offsetY, -3);
        expect(badge.image.width, 10);
        expect(badge.image.height, 10);
      },
    );
  });

  group('PolylineText Mocking Tests', () {
    test('addPolylineText returns PolylineText with channel id', () async {
      final style = PolylineTextStyle(16, const Color(0xFF111111));

      final text = await controller.labelLayer.addPolylineText(
        'hello path',
        const [LatLng(37.1, 127.1), LatLng(37.2, 127.2)],
        style: style,
        id: 'polyline-text-explicit-id',
      );

      expect(text.id, 'polyline-text-explicit-id');
      expect(text.text, 'hello path');
      expect(text.points.length, 2);
      expect(text.points.first.latitude, 37.1);
      expect(text.points.last.longitude, 127.2);
    });
  });

  group('LodPoi Mocking Tests', () {
    test('addLodPoi returns LodPoi with id from channel response', () async {
      final style = PoiStyle(
        id: 'lod-poi-style',
        icon: KImage.fromData(Uint8List.fromList([4, 5, 6]), 18, 18),
      );
      await controller.addPoiStyle(style);

      final lodPoi = await controller.lodLabelLayer.addLodPoi(
        const LatLng(35.2, 128.2),
        style: style,
        id: 'lod-poi-explicit-id',
        text: 'lod-text',
        rank: 3,
      );

      expect(lodPoi.id, 'lod-poi-explicit-id');
      expect(lodPoi.position.latitude, 35.2);
      expect(lodPoi.position.longitude, 128.2);
      expect(lodPoi.text, 'lod-text');
      expect(lodPoi.rank, 3);
    });

    test('addBadge on LodPoi returns badge id from channel response', () async {
      final style = PoiStyle(
        id: 'lod-style-badge',
        icon: KImage.fromData(Uint8List.fromList([9, 9, 9]), 14, 14),
      );
      await controller.addPoiStyle(style);
      final lodPoi = await controller.lodLabelLayer.addLodPoi(
        const LatLng(36.0, 127.0),
        style: style,
        id: 'lod-badge-target',
      );

      final badge = await lodPoi.addBadge(
        KImage.fromData(Uint8List.fromList([7, 7]), 11, 11),
        1,
        2,
        badgeId: 'lod-badge-explicit-id',
      );

      expect(badge.id, 'lod-badge-target-badge-id');
      expect(badge.offsetX, 1);
      expect(badge.offsetY, 2);
    });
  });

  group('Polyline Mocking Tests', () {
    test(
      'addPolylineShapeStyle returns style id from channel response',
      () async {
        final style = PolylineStyle(
          const Color(0xFF00AAFF),
          4,
          id: 'polyline-style-explicit-id',
        );

        final styleId = await controller.addPolylineShapeStyle(
          style,
          PolylineCap.round,
        );

        expect(styleId, 'polyline-style-explicit-id');
        expect(style.id, 'polyline-style-explicit-id');
      },
    );

    test(
      'addPolylineShape returns Polyline with id from channel response',
      () async {
        final style = PolylineStyle(
          const Color(0xFF335577),
          3,
          id: 'polyline-style-shape',
        );
        await controller.addPolylineShapeStyle(style, PolylineCap.round);

        final polyline = await controller.shapeLayer.addPolylineShape<MapPoint>(
          MapPoint(const [LatLng(37.5, 126.8), LatLng(37.6, 126.9)]),
          style,
          PolylineCap.round,
          id: 'polyline-shape-explicit-id',
        );
        final polylinePoint = polyline.position as MapPoint;

        expect(polyline.id, 'polyline-shape-explicit-id');
        expect(polylinePoint.points.length, 2);
        expect(polylinePoint.points.first.latitude, 37.5);
        expect(polyline.style.id, 'polyline-style-shape');
      },
    );
  });

  group('Polygon Mocking Tests', () {
    test(
      'addPolygonShapeStyle returns style id from channel response',
      () async {
        final style = PolygonStyle(
          const Color(0x55332211),
          id: 'polygon-style-explicit-id',
        );

        final styleId = await controller.addPolygonShapeStyle(style);

        expect(styleId, 'polygon-style-explicit-id');
        expect(style.id, 'polygon-style-explicit-id');
      },
    );

    test(
      'addPolygonShape returns Polygon with id from channel response',
      () async {
        final style = PolygonStyle(
          const Color(0x44112233),
          id: 'polygon-style-shape',
        );
        await controller.addPolygonShapeStyle(style);

        final polygon = await controller.shapeLayer.addPolygonShape<MapPoint>(
          MapPoint(const [
            LatLng(37.51, 126.91),
            LatLng(37.52, 126.92),
            LatLng(37.53, 126.93),
          ]),
          style,
          id: 'polygon-shape-explicit-id',
        );
        final polygonPoint = polygon.position as MapPoint;

        expect(polygon.id, 'polygon-shape-explicit-id');
        expect(polygonPoint.points.length, 3);
        expect(polygonPoint.points.first.latitude, 37.51);
        expect(polygon.style.id, 'polygon-style-shape');
      },
    );
  });

  group('Route Mocking Tests', () {
    test('addRouteStyle returns style id from channel response', () async {
      final style = RouteStyle(
        const Color(0xFF123456),
        5,
        id: 'route-style-explicit-id',
      );

      final styleId = await controller.addRouteStyle(style);

      expect(styleId, 'route-style-explicit-id');
      expect(style.id, 'route-style-explicit-id');
    });

    test('addRoute returns Route with id from channel response', () async {
      final style = RouteStyle(
        const Color(0xFF446688),
        4,
        id: 'route-style-single',
      );
      await controller.addRouteStyle(style);

      final route = await controller.routeLayer.addRoute(
        const [LatLng(35.0, 129.0), LatLng(35.1, 129.1)],
        style,
        id: 'route-explicit-id',
      );

      expect(route.id, 'route-explicit-id');
      expect(route.points.length, 2);
      expect(route.points.first.latitude, 35.0);
      expect(route.style.id, 'route-style-single');
    });

    test(
      'addMultipleRoute returns MultipleRoute with id and segment mapping',
      () async {
        final style = RouteStyle(
          const Color(0xFFAA5500),
          3,
          id: 'route-style-multiple',
        );
        await controller.addRouteStyle(style);

        final option =
            MultipleRouteOption([style], id: 'multi-route-explicit-id')
              ..addRouteWithIndex(
                const [LatLng(36.1, 127.1), LatLng(36.2, 127.2)],
                0,
                CurveType.right,
              );

        final route = await controller.routeLayer.addMultipleRoute(option);

        expect(route.id, 'multi-route-explicit-id');
        expect(route.segments.length, 1);
        expect(route.segments.first.points.length, 2);
        expect(route.segments.first.curveType, CurveType.right);
        expect(route.styles.first.id, 'route-style-multiple');
      },
    );
  });

  group('DimScreen Mocking Tests', () {
    test('addHighlightPolygonShape returns Polygon with channel id', () async {
      final style = PolygonStyle(
        const Color(0x66999999),
        id: 'dim-polygon-style',
      );
      await controller.addPolygonShapeStyle(style);

      final polygon = await controller.dimScreen.addPolygonShape<MapPoint>(
        MapPoint(const [
          LatLng(37.0, 127.0),
          LatLng(37.1, 127.1),
          LatLng(37.2, 127.2),
        ]),
        style,
        id: 'dim-polygon-explicit-id',
      );
      final polygonPoint = polygon.position as MapPoint;

      expect(polygon.id, 'dim-polygon-explicit-id');
      expect(polygonPoint.points.length, 3);
      expect(polygon.style.id, 'dim-polygon-style');
    });
  });
}
