import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('uses native MoveBy values on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final handler = _TestControllerHandler();

    await handler.handle(
      const MethodCall('onCameraMoveStart', {'gesture': 5}),
    );

    expect(handler.lastGesture, GestureType.tilt);
  });

  test('uses generic gesture values on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final handler = _TestControllerHandler();

    await handler.handle(
      const MethodCall('onCameraMoveStart', {'gesture': 5}),
    );

    expect(handler.lastGesture, GestureType.pan);
  });

  test('maps Android and iOS authentication failures consistently', () async {
    for (final className in ['MapAuthException', 'AuthenticatedFailed']) {
      final handler = _TestControllerHandler();

      await handler.handle(
        MethodCall('onMapError', {
          'className': className,
          'errorCode': 401,
          'message': 'Authentication failed',
        }),
      );

      expect(handler.lastError, isA<KakaoAuthError>());
      final error = handler.lastError! as KakaoAuthError;
      expect(error.code, 401);
      expect(error.message, 'Authentication failed');
    }
  });

  test('maps native non-authentication failures to KakaoMapError', () async {
    final handler = _TestControllerHandler();

    await handler.handle(
      const MethodCall('onMapError', {
        'className': 'MapViewLoadFailed',
        'message': 'Map initialization failed',
      }),
    );

    expect(handler.lastError, isA<KakaoMapError>());
    final error = handler.lastError! as KakaoMapError;
    expect(error.className, 'MapViewLoadFailed');
    expect(error.message, 'Map initialization failed');
  });
}

class _TestControllerHandler with KakaoMapControllerHandler {
  GestureType? lastGesture;
  Error? lastError;

  @override
  void onCameraMoveStart(GestureType gestureType) {
    lastGesture = gestureType;
  }

  @override
  void onMapError(Error error) {
    lastError = error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
