import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sdkChannel = ChannelType.sdk.channel;
  final sdk = KakaoMapSdkImplement();

  const dummyHashKey = 'MOCK_ANDROID_HASH_KEY_ABC123=';
  const dummyIsInitialized = true;

  var hashKeyCallCount = 0;
  var isInitializeCallCount = 0;

  setUp(() {
    hashKeyCallCount = 0;
    isInitializeCallCount = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sdkChannel, (call) async {
          switch (call.method) {
            case 'hashKey':
              hashKeyCallCount += 1;
              return dummyHashKey;
            case 'isInitialize':
              isInitializeCallCount += 1;
              return dummyIsInitialized;
            case 'initialize':
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sdkChannel, null);
  });

  group('SDK Initializer Mocking Tests', () {
    test(
      'isInitialize returns bool mapped from platform channel response',
      () async {
        final result = await sdk.isInitialize();

        expect(result, isA<bool>());
        expect(result, dummyIsInitialized);
        expect(isInitializeCallCount, 1);
      },
    );

    test(
      'hashKey returns null safely on unsupported platform and does not invoke channel',
      () async {
        final result = await sdk.hashKey();

        expect(
          Platform.isAndroid,
          isFalse,
          reason:
              'This test validates the non-Android defensive branch in hashKey().',
        );
        expect(result, isNull);
        expect(hashKeyCallCount, 0);
      },
    );

    test(
      'hashKey returns String from channel response on Android runtime',
      () async {
        if (!Platform.isAndroid) {
          return;
        }

        final result = await sdk.hashKey();

        expect(result, isA<String>());
        expect(result, dummyHashKey);
        expect(hashKeyCallCount, 1);
      },
    );

    test(
      'hashKey returns null when Android native side responds result.success(null)',
      () async {
        if (!Platform.isAndroid) {
          return;
        }

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(sdkChannel, (call) async {
              if (call.method == 'hashKey') {
                hashKeyCallCount += 1;
                return null;
              }
              if (call.method == 'isInitialize') {
                isInitializeCallCount += 1;
                return dummyIsInitialized;
              }
              return null;
            });

        final result = await sdk.hashKey();

        expect(result, isNull);
        expect(hashKeyCallCount, 1);
      },
    );

    test(
      'hashKey keeps returning null when Flutter target platform is changed to iOS in test environment',
      () async {
        final previous = debugDefaultTargetPlatformOverride;
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        try {
          final result = await sdk.hashKey();

          expect(result, isNull);
          expect(hashKeyCallCount, 0);
        } finally {
          debugDefaultTargetPlatformOverride = previous;
        }
      },
    );
  });
}
