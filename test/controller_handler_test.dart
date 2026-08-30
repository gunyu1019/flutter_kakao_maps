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
}

class _TestControllerHandler with KakaoMapControllerHandler {
  GestureType? lastGesture;

  @override
  void onCameraMoveStart(GestureType gestureType) {
    lastGesture = gestureType;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
