import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  void expectKPointEquals(KPoint a, KPoint b) {
    expect(b.x, a.x);
    expect(b.y, a.y);
  }

  void expectLatLngEquals(LatLng a, LatLng b) {
    expect(b.latitude, a.latitude);
    expect(b.longitude, a.longitude);
  }

  void expectKImageEquals(KImage a, KImage b) {
    expect(b.type, a.type);
    expect(b.width, a.width);
    expect(b.height, a.height);
    expect(b.toMessageable(), a.toMessageable());
  }

  void expectPoiTextStyleEquals(PoiTextStyle a, PoiTextStyle b) {
    expect(b.aspectRatio, a.aspectRatio);
    expect(b.characterSpace, a.characterSpace);
    expect(b.color, a.color);
    expect(b.font, a.font);
    expect(b.lineSpace, a.lineSpace);
    expect(b.size, a.size);
    expect(b.stroke, a.stroke);
    expect(b.strokeColor, a.strokeColor);
  }

  void expectPoiTransitionEquals(PoiTransition a, PoiTransition b) {
    expect(b.entrance, a.entrance);
    expect(b.exit, a.exit);
  }

  void expectCameraPositionEquals(CameraPosition a, CameraPosition b) {
    expectLatLngEquals(a.position, b.position);
    expect(b.zoomLevel, a.zoomLevel);
    expect(b.tiltAngle, a.tiltAngle);
    expect(b.rotationAngle, a.rotationAngle);
    expect(b.height, a.height);
  }

  void expectRoutePatternEquals(RoutePattern a, RoutePattern b) {
    expectKImageEquals(a.patternImage, b.patternImage);
    expect(b.distance, a.distance);
    expect(b.pinStart, a.pinStart);
    expect(b.pinEnd, a.pinEnd);
    if (a.symbolImage == null) {
      expect(b.symbolImage, isNull);
    } else {
      expect(b.symbolImage, isNotNull);
      expectKImageEquals(a.symbolImage!, b.symbolImage!);
    }
  }

  void expectRouteStyleEquals(RouteStyle a, RouteStyle b) {
    expect(b.id, a.id);
    expect(b.color, a.color);
    expect(b.lineWidth, a.lineWidth);
    expect(b.strokeColor, a.strokeColor);
    expect(b.strokeWidth, a.strokeWidth);
    expect(b.zoomLevel, a.zoomLevel);

    if (a.pattern == null) {
      expect(b.pattern, isNull);
    } else {
      expect(b.pattern, isNotNull);
      expectRoutePatternEquals(a.pattern!, b.pattern!);
    }

    expect(b.otherStyleCount, a.otherStyleCount);
    for (final level in a.otherStyleLevel) {
      final originalOther = a.getStyle(level);
      final restoredOther = b.getStyle(level);
      expect(restoredOther, isNotNull);
      expect(restoredOther!.zoomLevel, originalOther!.zoomLevel);
      expect(restoredOther.color, originalOther.color);
      expect(restoredOther.lineWidth, originalOther.lineWidth);
      expect(restoredOther.strokeColor, originalOther.strokeColor);
      expect(restoredOther.strokeWidth, originalOther.strokeWidth);
      if (originalOther.pattern == null) {
        expect(restoredOther.pattern, isNull);
      } else {
        expect(restoredOther.pattern, isNotNull);
        expectRoutePatternEquals(
          originalOther.pattern!,
          restoredOther.pattern!,
        );
      }
    }
  }

  void expectPolylineStyleEquals(PolylineStyle a, PolylineStyle b) {
    expect(b.id, a.id);
    expect(b.color, a.color);
    expect(b.lineWidth, a.lineWidth);
    expect(b.strokeColor, a.strokeColor);
    expect(b.strokeWidth, a.strokeWidth);
    expect(b.zoomLevel, a.zoomLevel);
    expect(b.otherStyleCount, a.otherStyleCount);

    for (final level in a.otherStyleLevel) {
      final originalOther = a.getStyle(level);
      final restoredOther = b.getStyle(level);
      expect(restoredOther, isNotNull);
      expect(restoredOther!.zoomLevel, originalOther!.zoomLevel);
      expect(restoredOther.color, originalOther.color);
      expect(restoredOther.lineWidth, originalOther.lineWidth);
      expect(restoredOther.strokeColor, originalOther.strokeColor);
      expect(restoredOther.strokeWidth, originalOther.strokeWidth);
    }
  }

  void expectPolygonStyleEquals(PolygonStyle a, PolygonStyle b) {
    expect(b.id, a.id);
    expect(b.color, a.color);
    expect(b.strokeColor, a.strokeColor);
    expect(b.strokeWidth, a.strokeWidth);
    expect(b.zoomLevel, a.zoomLevel);
    expect(b.otherStyleCount, a.otherStyleCount);

    for (final level in a.otherStyleLevel) {
      final originalOther = a.getStyle(level);
      final restoredOther = b.getStyle(level);
      expect(restoredOther, isNotNull);
      expect(restoredOther!.zoomLevel, originalOther!.zoomLevel);
      expect(restoredOther.color, originalOther.color);
      expect(restoredOther.strokeColor, originalOther.strokeColor);
      expect(restoredOther.strokeWidth, originalOther.strokeWidth);
    }
  }

  void expectRouteSegmentEquals(RouteSegment a, RouteSegment b) {
    expect(b.styleIndex, a.styleIndex);
    expect(b.curveType, a.curveType);
    expect(b.points.length, a.points.length);
    for (var index = 0; index < a.points.length; index++) {
      expectLatLngEquals(a.points[index], b.points[index]);
    }
  }

  group('KPoint Serialization', () {
    test('round-trip preserves x and y', () {
      const original = KPoint(12.34, 56.78);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = KPoint.fromMessageable(payload);
      expectKPointEquals(original, restored);
    });
  });

  group('KImage Serialization', () {
    test('round-trip preserves data image fields', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final original = KImage.fromData(bytes, 24, 36);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = KImage.fromMessageable(payload);
      expectKImageEquals(original, restored);
    });

    test('round-trip preserves asset image fields', () {
      final original = KImage.fromAsset('assets/test/icon.png', 14, 20);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = KImage.fromMessageable(payload);
      expectKImageEquals(original, restored);
    });
  });

  group('LatLng Serialization', () {
    test('round-trip preserves latitude and longitude', () {
      const original = LatLng(37.5665, 126.9780);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = LatLng.fromMessageable(payload);
      expectLatLngEquals(original, restored);
    });
  });

  group('Relative Shape Serialization', () {
    test('preserves each mixed hole type and winding direction', () {
      final point = RectanglePoint(
        400,
        300,
        const LatLng(37.394776, 127.11116),
        clockwise: false,
      )
        ..addHole(
          CirclePoint(
            80,
            const LatLng(0, 0),
            clockwise: false,
          ),
        )
        ..addHole(
          RectanglePoint(
            120,
            60,
            const LatLng(0, 0),
            clockwise: false,
          ),
        );

      final payload = point.toMessageable();
      final holes = (payload['holes'] as List).cast<Map<String, dynamic>>();

      expect(payload['dotType'], PointShapeType.rectangle.value);
      expect(payload['clockwise'], isFalse);
      expect(holes, hasLength(2));
      expect(holes[0]['dotType'], PointShapeType.circle.value);
      expect(holes[0]['radius'], 80);
      expect(holes[0]['clockwise'], isFalse);
      expect(holes[1]['dotType'], PointShapeType.rectangle.value);
      expect(holes[1]['width'], 120);
      expect(holes[1]['height'], 60);
      expect(holes[1]['clockwise'], isFalse);
    });
  });

  group('PoiTextStyle Serialization', () {
    test('round-trip preserves all style fields', () {
      const original = PoiTextStyle(
        aspectRatio: 1.2,
        characterSpace: 3,
        color: Color(0xFF123456),
        font: 'Pretendard',
        lineSpace: 1.4,
        size: 18,
        stroke: 2,
        strokeColor: Color(0xFF654321),
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = PoiTextStyle.fromMessageable(payload);
      expectPoiTextStyleEquals(original, restored);
    });
  });

  group('PoiTransition Serialization', () {
    test('round-trip preserves entrance and exit', () {
      const original = PoiTransition(
        entrance: Transition.scale,
        exit: Transition.none,
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = PoiTransition.fromMessageable(payload);
      expectPoiTransitionEquals(original, restored);
    });
  });

  group('PoiStyle Serialization', () {
    final unsupportedDesktop = !Platform.isAndroid && !Platform.isIOS;

    test(
      'round-trip preserves nested fields and other styles',
      () {
        final original = PoiStyle(
          id: 'poi-style-main',
          applyDpScale: false,
          anchor: const KPoint(0.25, 0.75),
          padding: 8.0,
          icon: KImage.fromData(Uint8List.fromList([11, 22, 33]), 20, 20),
          iconTransition: const PoiTransition(
            entrance: Transition.alpha,
            exit: Transition.scale,
          ),
          textGravity: const MapGravity(
            HorizontalAlign.right,
            VerticalAlign.bottom,
          ),
          textStyle: const [
            PoiTextStyle(font: 'A', size: 16, color: Color(0xFF111111)),
            PoiTextStyle(font: 'B', size: 14, color: Color(0xFF222222)),
          ],
          textTransition: const PoiTransition(
            entrance: Transition.scale,
            exit: Transition.alpha,
          ),
          zoomLevel: 5,
        )..addStyle(
            zoomLevel: 9,
            applyDpScale: true,
            anchor: const KPoint(0.5, 1.0),
            padding: 2,
            icon: null,
            textStyle: const [],
            textTransition: const PoiTransition(
              entrance: Transition.none,
              exit: Transition.none,
            ),
          );

        final payload = original.toMessageable();
        expect(payload, isA<Map<String, dynamic>>());

        final restored = PoiStyle.fromMessageable(payload, original.id);

        expect(restored.id, original.id);
        expect(restored.applyDpScale, original.applyDpScale);
        expectKPointEquals(original.anchor, restored.anchor);
        expect(restored.padding, original.padding);
        expect(restored.icon, isNotNull);
        expectKImageEquals(original.icon!, restored.icon!);
        expectPoiTransitionEquals(
          original.iconTransition,
          restored.iconTransition,
        );
        expect(
          restored.textGravity.horizontalAlign,
          original.textGravity.horizontalAlign,
        );
        expect(
          restored.textGravity.verticalAlign,
          original.textGravity.verticalAlign,
        );
        expect(restored.textStyle.length, original.textStyle.length);
        for (var i = 0; i < original.textStyle.length; i++) {
          expectPoiTextStyleEquals(
            original.textStyle[i],
            restored.textStyle[i],
          );
        }
        expectPoiTransitionEquals(
          original.textTransition,
          restored.textTransition,
        );
        expect(restored.zoomLevel, original.zoomLevel);
        expect(restored.otherStyleCount, original.otherStyleCount);

        final originalOther = original.getStyle(9)!;
        final restoredOther = restored.getStyle(9)!;
        expect(restoredOther.icon, isNull);
        expect(restoredOther.textStyle, isEmpty);
        expect(restoredOther.zoomLevel, originalOther.zoomLevel);
      },
      skip: unsupportedDesktop
          ? 'MapGravity.value returns -1 on desktop platforms, which breaks PoiStyle round-trip payload.'
          : false,
    );
  });

  group('CameraAnimation Serialization', () {
    test('round-trip preserves duration and flags', () {
      const original = CameraAnimation(
        700,
        autoElevation: true,
        isConsecutive: true,
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraAnimation.fromMessageable(payload);
      expect(restored.duration, original.duration);
      expect(restored.autoElevation, original.autoElevation);
      expect(restored.isConsecutive, original.isConsecutive);
    });

    test('round-trip with missing optional flags defaults correctly', () {
      final payload = {'duration': 300};
      final restored = CameraAnimation.fromMessageable(payload);

      expect(restored.duration, 300);
      expect(restored.autoElevation, isFalse);
      expect(restored.isConsecutive, isFalse);
    });
  });

  group('CameraPosition Serialization', () {
    test('round-trip preserves all explicit fields', () {
      const original = CameraPosition(
        LatLng(35.0, 129.0),
        11,
        tiltAngle: 25.0,
        rotationAngle: 70.0,
        height: 400.0,
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraPosition.fromMessageable(payload);
      expectCameraPositionEquals(original, restored);
    });

    test('round-trip with nullable fields set to null', () {
      const original = CameraPosition(LatLng(35.1, 129.1), 10);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraPosition.fromMessageable(payload);
      expectLatLngEquals(original.position, restored.position);
      expect(restored.zoomLevel, original.zoomLevel);
      expect(restored.tiltAngle, 0.0);
      expect(restored.rotationAngle, 0.0);
      expect(restored.height, -1.0);
    });
  });

  group('CameraUpdate Serialization', () {
    test('round-trip preserves newCenterPoint update', () {
      final original = CameraUpdate.newCenterPosition(
        const LatLng(37.55, 126.97),
        zoomLevel: 13,
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraUpdate.fromMessageable(payload);
      expect(restored.type, original.type);
      expectLatLngEquals(original.position!, restored.position!);
      expect(restored.zoomLevel, original.zoomLevel);
    });

    test('round-trip preserves newCameraPos update', () {
      final original = CameraUpdate.newCameraPos(
        const CameraPosition(
          LatLng(37.58, 126.99),
          9,
          tiltAngle: 30.0,
          rotationAngle: 45.0,
          height: 500.0,
        ),
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraUpdate.fromMessageable(payload);
      expect(restored.type, original.type);
      expect(restored.cameraPosition, isNotNull);
      expectCameraPositionEquals(
        original.cameraPosition!,
        restored.cameraPosition!,
      );
    });

    test('round-trip preserves zoomTo update', () {
      final original = CameraUpdate.zoomTo(15);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraUpdate.fromMessageable(payload);
      expect(restored.type, original.type);
      expect(restored.zoomLevel, original.zoomLevel);
    });

    test('round-trip preserves rotate update', () {
      final original = CameraUpdate.rotate(90.0);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = CameraUpdate.fromMessageable(payload);
      expect(restored.type, original.type);
      expect(restored.angle, original.angle);
    });

    test(
      'round-trip preserves fitMapPoints update and empty list edge case',
      () {
        final original = CameraUpdate.fitMapPoints(
          const [LatLng(37.5, 126.9), LatLng(37.6, 127.0)],
          padding: 20,
          zoomLevel: 12,
        );

        final payload = original.toMessageable();
        expect(payload, isA<Map<String, dynamic>>());

        final restored = CameraUpdate.fromMessageable(payload);
        expect(restored.type, original.type);
        expect(restored.padding, original.padding);
        expect(restored.zoomLevel, original.zoomLevel);
        expect(restored.fitPoints, isNotNull);
        expect(restored.fitPoints!.length, original.fitPoints!.length);
        for (var i = 0; i < original.fitPoints!.length; i++) {
          expectLatLngEquals(original.fitPoints![i], restored.fitPoints![i]);
        }

        final emptyOriginal = CameraUpdate.fitMapPoints(const [], padding: 0);
        final emptyPayload = emptyOriginal.toMessageable();
        final emptyRestored = CameraUpdate.fromMessageable(emptyPayload);
        expect(emptyRestored.fitPoints, isEmpty);
      },
    );
  });

  group('RoutePattern Serialization', () {
    test('round-trip preserves all fields', () {
      final original = RoutePattern(
        KImage.fromData(Uint8List.fromList([1, 2, 3]), 12, 12),
        33.3,
        symbolImage: KImage.fromAsset('assets/symbol.png', 8, 8),
        pinStart: true,
        pinEnd: false,
      );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = RoutePattern.fromMessageable(payload);
      expectRoutePatternEquals(original, restored);
    });

    test('round-trip with nullable symbolImage set to null', () {
      final original = RoutePattern(
        KImage.fromData(Uint8List.fromList([4, 5, 6]), 10, 10),
        12.0,
        symbolImage: null,
        pinStart: false,
        pinEnd: true,
      );

      final payload = original.toMessageable();
      final restored = RoutePattern.fromMessageable(payload);
      expectRoutePatternEquals(original, restored);
    });
  });

  group('RouteStyle Serialization', () {
    test('round-trip preserves nested pattern and otherStyle', () {
      final original = RouteStyle(
        const Color(0xFF00AAFF),
        6.5,
        id: 'route-style-main',
        strokeColor: const Color(0xFF005577),
        strokeWidth: 1.5,
        pattern: RoutePattern(
          KImage.fromData(Uint8List.fromList([9, 8, 7]), 11, 11),
          30,
          symbolImage: null,
          pinStart: false,
          pinEnd: true,
        ),
        zoomLevel: 7,
      )..addStyle(
          10,
          const Color(0xFFAA00FF),
          4.0,
          strokeColor: const Color(0xFF330055),
          strokeWidth: 2.0,
        );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = RouteStyle.fromMessageable(payload, original.id);
      expectRouteStyleEquals(original, restored);
    });

    test('round-trip with empty otherStyle list', () {
      final original = RouteStyle(
        const Color(0xFF101010),
        3.0,
        id: 'route-style-empty',
        zoomLevel: 1,
      );

      final payload = original.toMessageable();
      final restored = RouteStyle.fromMessageable(payload, original.id);
      expectRouteStyleEquals(original, restored);
      expect(restored.otherStyles, isEmpty);
    });
  });

  group('PolylineStyle Serialization', () {
    test('round-trip preserves all fields and otherStyle', () {
      final original = PolylineStyle(
        const Color(0xFF123123),
        5.0,
        id: 'polyline-style-main',
        strokeWidth: 1.0,
        strokeColor: const Color(0xFF456456),
        zoomLevel: 3,
      )..addStyle(
          8,
          color: const Color(0xFFABCDEF),
          lineWidth: 7.0,
          strokeWidth: 2.5,
          strokeColor: const Color(0xFFFEDCBA),
        );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = PolylineStyle.fromMessageable(payload, original.id);
      expectPolylineStyleEquals(original, restored);
    });

    test('round-trip with empty otherStyle list', () {
      final original = PolylineStyle(
        const Color(0xFF111111),
        2.0,
        id: 'polyline-style-empty',
      );

      final payload = original.toMessageable();
      final restored = PolylineStyle.fromMessageable(payload, original.id);
      expectPolylineStyleEquals(original, restored);
      expect(restored.otherStyles, isEmpty);
    });
  });

  group('PolygonStyle Serialization', () {
    test('round-trip preserves all fields and otherStyle', () {
      final original = PolygonStyle(
        const Color(0x33223344),
        id: 'polygon-style-main',
        strokeWidth: 1.3,
        strokeColor: const Color(0xFF8899AA),
        zoomLevel: 4,
      )..addStyle(
          9,
          const Color(0x55445566),
          strokeWidth: 2.2,
          strokeColor: const Color(0xFFAA9988),
        );

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = PolygonStyle.fromMessageable(payload, original.id);
      expectPolygonStyleEquals(original, restored);
    });

    test('round-trip with empty otherStyle list', () {
      final original = PolygonStyle(
        const Color(0x22112233),
        id: 'polygon-style-empty',
      );

      final payload = original.toMessageable();
      final restored = PolygonStyle.fromMessageable(payload, original.id);
      expectPolygonStyleEquals(original, restored);
      expect(restored.otherStyles, isEmpty);
    });
  });

  group('RouteSegment Serialization', () {
    test('round-trip preserves points, styleIndex and curveType', () {
      final style = RouteStyle(
        const Color(0xFF556677),
        4.0,
        id: 'route-style-1',
      );
      final option = MultipleRouteOption([style], id: 'multi-1');
      option.addRouteWithIndex(
        const [LatLng(37.1, 127.1), LatLng(37.2, 127.2)],
        0,
        CurveType.right,
      );
      final original = option.segments.first;

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = RouteSegment.fromMessageable(payload, option);
      expectRouteSegmentEquals(original, restored);
    });

    test('round-trip with empty points list', () {
      final style = RouteStyle(
        const Color(0xFF000000),
        2.0,
        id: 'route-style-2',
      );
      final option = MultipleRouteOption([style], id: 'multi-2');
      option.addRouteWithIndex(const [], 0, CurveType.none);
      final original = option.segments.first;

      final payload = original.toMessageable();
      final restored = RouteSegment.fromMessageable(payload, option);
      expect(restored.points, isEmpty);
      expect(restored.styleIndex, original.styleIndex);
      expect(restored.curveType, original.curveType);
    });
  });

  group('MultipleRouteOption Serialization', () {
    test('round-trip preserves id, zOrder, routes and styles mapping', () {
      final styleA = RouteStyle(const Color(0xFF001122), 3.0, id: 'style-a');
      final styleB = RouteStyle(const Color(0xFF334455), 5.0, id: 'style-b');
      final original = MultipleRouteOption(
        [styleA, styleB],
        id: 'route-option-1',
        zOrder: 77,
      )
        ..addRouteWithIndex(
          const [LatLng(36.1, 127.1), LatLng(36.2, 127.2)],
          0,
          CurveType.left,
        )
        ..addRouteWithIndex(const [LatLng(36.3, 127.3)], 1, CurveType.none);

      final payload = original.toMessageable();
      expect(payload, isA<Map<String, dynamic>>());

      final restored = MultipleRouteOption.fromMessageable(payload, [
        styleA,
        styleB,
      ]);

      expect(restored.id, original.id);
      expect(restored.zOrder, original.zOrder);
      expect(restored.styles.length, original.styles.length);
      expect(restored.segments.length, original.segments.length);

      for (var i = 0; i < original.segments.length; i++) {
        expectRouteSegmentEquals(original.segments[i], restored.segments[i]);
      }
    });

    test('round-trip with empty routes list', () {
      final style = RouteStyle(const Color(0xFFABC123), 2.5, id: 'style-empty');
      final original = MultipleRouteOption([style], id: 'route-option-empty');

      final payload = original.toMessageable();
      final restored = MultipleRouteOption.fromMessageable(payload, [style]);

      expect(restored.id, original.id);
      expect(restored.zOrder, original.zOrder);
      expect(restored.segments, isEmpty);
      expect(restored.styles.length, 1);
    });
  });
}
