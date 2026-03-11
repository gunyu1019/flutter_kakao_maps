import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewId = 999;
  final viewChannel = ChannelType.view.channelWithId(viewId);
  final overlayChannel = ChannelType.overlay.channelWithId(viewId);

  const dummyCameraPayload = <String, dynamic>{
    'latitude': 37.5665,
    'longitude': 126.9780,
    'zoomLevel': 13,
    'tiltAngle': 25.0,
    'rotationAngle': 45.0,
    'height': 300.0,
  };

  const dummyFromScreenPointPayload = <String, dynamic>{
    'latitude': 37.1234,
    'longitude': 127.5678,
  };

  const dummyToScreenPointPayload = <String, dynamic>{'x': 320.5, 'y': 640.25};

  const dummyCanPositionVisiblePayload = true;
  const dummyBuildingHeightScalePayload = 1.75;

  late KakaoMapController controller;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(viewChannel, (call) async {
      switch (call.method) {
        case 'getCameraPosition':
          return dummyCameraPayload;
        case 'fromScreenPoint':
          return dummyFromScreenPointPayload;
        case 'toScreenPoint':
          return dummyToScreenPointPayload;
        case 'canPositionVisible':
        case 'canShowPosition':
          return dummyCanPositionVisiblePayload;
        case 'getBuildingHeightScale':
          return dummyBuildingHeightScalePayload;
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(overlayChannel, (call) async => null);

    controller = KakaoMapControllerImplement(
      viewChannel,
      overlayChannel: overlayChannel,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(viewChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(overlayChannel, null);
  });

  test(
    'getCameraPosition returns CameraPosition mapped from channel payload',
    () async {
      final result = await controller.getCameraPosition();

      expect(result, isA<CameraPosition>());
      expect(result.position.latitude, dummyCameraPayload['latitude']);
      expect(result.position.longitude, dummyCameraPayload['longitude']);
      expect(result.zoomLevel, dummyCameraPayload['zoomLevel']);
      expect(result.tiltAngle, dummyCameraPayload['tiltAngle']);
      expect(result.rotationAngle, dummyCameraPayload['rotationAngle']);
      expect(result.height, dummyCameraPayload['height']);
    },
  );

  test('fromScreenPoint returns LatLng mapped from channel payload', () async {
    final result = await controller.fromScreenPoint(100, 200);

    expect(result, isNotNull);
    expect(result, isA<LatLng>());
    expect(result!.latitude, dummyFromScreenPointPayload['latitude']);
    expect(result.longitude, dummyFromScreenPointPayload['longitude']);
  });

  test('toScreenPoint returns KPoint mapped from channel payload', () async {
    final result = await controller.toScreenPoint(const LatLng(37.0, 127.0));

    expect(result, isNotNull);
    expect(result, isA<KPoint>());
    expect(result!.x, dummyToScreenPointPayload['x']);
    expect(result.y, dummyToScreenPointPayload['y']);
  });

  test('canShowPosition returns boolean from channel response', () async {
    final result = await controller.canShowPosition(10, const [
      LatLng(37.1, 127.1),
      LatLng(37.2, 127.2),
    ]);

    expect(result, isA<bool>());
    expect(result, dummyCanPositionVisiblePayload);
  });

  test(
    'fetchBuildingHeightScale returns double and updates cached property',
    () async {
      final result = await controller.fetchBuildingHeightScale();

      expect(result, isA<double>());
      expect(result, dummyBuildingHeightScalePayload);
      expect(controller.buildingHeightScale, dummyBuildingHeightScalePayload);
    },
  );
}
