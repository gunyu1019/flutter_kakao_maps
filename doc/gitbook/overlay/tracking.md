# Poi 추적하기 (Tracking)

`TrackingController`는 이동하는 `Poi`를 카메라가 따라가도록 합니다. 일반 Poi 하나를 지정한 뒤 추적을 시작하고, 대상 교체 전에는 기존 추적을 중지합니다.

## 1. 기본 사용

```dart
Future<void> startTracking(KakaoMapController controller) async {
  final style = PoiStyle(
    icon: KImage.fromAsset('assets/vehicle.png', 48, 48),
  );

  final vehicle = await controller.labelLayer.addPoi(
    const LatLng(37.394776, 127.11116),
    id: 'vehicle',
    style: style,
    transform: TransformMethod.absoluteRotationDecal,
  );

  controller.tracking.poi = vehicle;
  await controller.tracking.start();
}
```

`poi`가 설정되지 않은 상태에서 `start()`를 호출하면 아무 동작도 하지 않습니다.

## 2. Poi 이동

```dart
await vehicle.move(
  const LatLng(37.402005, 127.108621),
  1000,
);
```

여러 좌표를 따라 이동할 수도 있습니다.

```dart
await vehicle.movePathWithRotate(
  const [
    LatLng(37.394776, 127.111160),
    LatLng(37.397000, 127.112000),
    LatLng(37.402005, 127.108621),
  ],
  0,    // 진행 방향을 계산할 수 없을 때 사용할 기준 라디안
  5000, // 전체 이동 시간(ms)
  cornerRadius: 40,
  jumpThreshold: 200,
);
```

## 3. 회전까지 추적

```dart
await controller.tracking.setTrackingRotate(true);
await controller.tracking.start();
```

활성화하면 Poi의 회전에 맞춰 카메라도 회전합니다. Web에서는 카메라 회전이 지원되지 않으므로 위치 추적 중심으로 동작을 설계하세요.

## 4. 중지와 대상 교체

```dart
await controller.tracking.stop();

controller.tracking.poi = anotherPoi;
await controller.tracking.start();
```

추적 중인 Poi를 삭제하기 전에는 `stop()`을 먼저 호출하는 편이 안전합니다.

## 5. LodPoi와의 차이

`TrackingController.poi`는 `Poi?` 타입이며 `LodPoi`를 추적 대상으로 받지 않습니다. 이동·회전이 필요한 차량이나 사용자의 위치는 일반 LabelLayer의 Poi로 구성하세요.
