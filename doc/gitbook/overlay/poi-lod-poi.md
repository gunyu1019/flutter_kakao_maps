# 특정 요소 (Poi, LodPoi)

Poi(Point of Interest)는 지도 위의 특정 위치에 이미지와 텍스트로 정보를 표시할 수 있는 지도 요소입니다.\
[LabelController](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LabelController-class.html)를 통해 Poi를 생성하고 관리할 수 있습니다.

LodPoi는 Poi의 변형으로, 다수의 Poi를 지도에 표시할 때 성능을 향상시키기 위한 LOD(Level of Detail) 기능이 적용된 요소입니다.\
[LodLabelController](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LodLabelController-class.html)를 통해 LodPoi를 생성하고 관리할 수 있습니다.

## 1. Poi 스타일 등록하기

Poi를 지도에 추가하기 위해서는 먼저 [PoiStyle](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiStyle-class.html) 객체를 생성하고 등록해야 합니다.\
[KakaoMapController.addPoiStyle()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/addPoiStyle.html) 함수를 이용하여 스타일을 등록할 수 있습니다.

```dart
Future<void> addPoiStyleExample(KakaoMapController controller) async {
  final style = PoiStyle(
    icon: KImage.fromAsset('assets/marker.png', 40, 60),
    anchor: KPoint(0.5, 1.0),
  );
  await controller.addPoiStyle(style);
}
```

[PoiStyle](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiStyle-class.html)을 통해 Poi의 아이콘 이미지, 텍스트 스타일, 표시 전환 효과 등을 설정할 수 있습니다.

<table><thead><tr><th width="155">Property</th><th>Description</th></tr></thead><tbody><tr><td>icon</td><td>Poi에 표시할 아이콘 이미지입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KImage-class.html">KImage</a> 형태로 에셋, 파일, 바이너리 데이터를 지원합니다.</td></tr><tr><td>anchor</td><td>아이콘 이미지의 기준점(앵커)을 설정합니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KPoint-class.html">KPoint</a>로 정의하며, (0.0, 0.0)은 좌상단, (1.0, 1.0)은 우하단에 해당합니다.</td></tr><tr><td>padding</td><td>Poi 아이콘 이미지의 패딩 값입니다.</td></tr><tr><td>textStyle</td><td>Poi에 표시할 텍스트의 스타일 목록입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiTextStyle-class.html">PoiTextStyle</a> 객체의 배열로 설정합니다.</td></tr><tr><td>iconTransition</td><td>Poi 아이콘의 등장/퇴장 애니메이션입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiTransition-class.html">PoiTransition</a> 객체로 설정합니다.</td></tr><tr><td>textTransition</td><td>Poi 텍스트의 등장/퇴장 애니메이션입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiTransition-class.html">PoiTransition</a> 객체로 설정합니다.</td></tr><tr><td>zoomLevel</td><td>Poi가 표시되기 시작하는 최소 줌 레벨입니다.</td></tr><tr><td>applyDpScale</td><td>기기의 해상도(DP)를 아이콘 크기에 반영할지 여부입니다.</td></tr></tbody></table>

### 1-1. 줌 레벨별 스타일 설정

줌 레벨에 따라 서로 다른 스타일을 적용하여 Poi를 표시할 수 있습니다.\
[PoiStyle.addStyle()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiStyle/addStyle.html) 함수를 이용하여 특정 줌 레벨에서 적용될 스타일을 추가할 수 있습니다.

```dart
Future<void> addZoomLevelStyleExample(KakaoMapController controller) async {
  final style = PoiStyle(
    icon: KImage.fromAsset('assets/marker_small.png', 20, 30),
    zoomLevel: 0,
  );
  // 줌 레벨 14 이상에서는 더 큰 아이콘으로 변경합니다.
  style.addStyle(
    zoomLevel: 14,
    icon: KImage.fromAsset('assets/marker_large.png', 40, 60),
  );
  await controller.addPoiStyle(style);
}
```

> 줌 레벨 값은 낮은 값부터 순서대로 입력해야 정상적으로 동작합니다.

## 2. Poi 추가하기

[스크린샷]

Poi는 [LabelController.addPoi()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LabelController/addPoi.html) 함수를 이용하여 지도에 추가할 수 있습니다.\
[KakaoMapController.labelLayer](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/labelLayer.html)를 통해 기본 LabelLayer에 접근할 수 있습니다.

```dart
Future<void> addPoiExample(KakaoMapController controller) async {
  final style = PoiStyle(
    icon: KImage.fromAsset('assets/marker.png', 40, 60),
  );
  await controller.addPoiStyle(style);

  final poi = await controller.labelLayer.addPoi(
    const LatLng(37.394776, 127.11116),
    style: style,
    text: '카카오 판교캠퍼스',
    onClick: () {
      print('Poi가 클릭되었습니다!');
    },
  );
}
```

[addPoi()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LabelController/addPoi.html) 함수에 입력 가능한 인수는 다음과 같습니다.

<table><thead><tr><th width="155">Parameter</th><th>Description</th></tr></thead><tbody><tr><td>position</td><td>Poi를 표시할 위치입니다. WGS84 형식의 <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LatLng-class.html">LatLng</a> 객체로 입력합니다.</td></tr><tr><td>style</td><td>Poi에 적용할 스타일입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PoiStyle-class.html">PoiStyle</a> 객체로 입력합니다.</td></tr><tr><td>id</td><td>Poi의 고유 ID입니다. 입력하지 않으면 임의의 고유 ID가 자동으로 생성됩니다.</td></tr><tr><td>text</td><td>Poi에 표시할 텍스트입니다.</td></tr><tr><td>transform</td><td>지도 회전 및 기울기 변화 시 Poi의 방향 처리 방식을 설정합니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/TransformMethod.html">TransformMethod</a>로 입력합니다.</td></tr><tr><td>rank</td><td>Poi의 표시 우선순위입니다. 값이 낮을수록 더 높은 우선순위를 가집니다.</td></tr><tr><td>onClick</td><td>Poi를 클릭했을 때 호출되는 콜백 함수입니다.</td></tr><tr><td>visible</td><td>Poi의 초기 표시 여부입니다. 기본값은 <code>true</code>입니다.</td></tr></tbody></table>

### 2-1. TransformMethod 설정

지도를 회전하거나 기울일 때 Poi의 방향이 어떻게 반응할지를 설정합니다.

<table><thead><tr><th width="260">Value</th><th>Description</th></tr></thead><tbody><tr><td>TransformMethod.none</td><td>지도가 회전 및 기울어져도 Poi는 항상 화면 기준 위를 향합니다. (기본값)</td></tr><tr><td>TransformMethod.absoluteRotation</td><td>Poi 자체의 회전 각도를 유지합니다.</td></tr><tr><td>TransformMethod.decal</td><td>지도가 기울어질 때 Poi도 함께 기울어집니다.</td></tr><tr><td>TransformMethod.absoluteRotationDecal</td><td>회전 각도 유지와 기울기 추종이 모두 적용됩니다.</td></tr></tbody></table>

### 2-2. 클릭 이벤트 처리

Poi 클릭 이벤트는 두 가지 방식으로 처리할 수 있습니다.\
`addPoi()` 함수의 `onClick` 인수를 이용하거나, [KakaoMap.onPoiClick](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMap/onPoiClick.html) 콜백을 통해 처리할 수 있습니다.

```dart
// 방법 1: addPoi()의 onClick 인수를 이용합니다.
final poi = await controller.labelLayer.addPoi(
  const LatLng(37.394776, 127.11116),
  style: style,
  onClick: () {
    print('Poi가 클릭되었습니다!');
  },
);

// 방법 2: KakaoMap 위젯의 onPoiClick 콜백을 이용합니다.
KakaoMap(
  onMapReady: (controller) { /* ... */ },
  onPoiClick: (LabelController layer, Poi poi) {
    print('${poi.text} Poi가 클릭되었습니다!');
  },
);
```

## 3. Poi 조작하기

[Poi](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/Poi-class.html) 객체를 통해 지도에 추가된 Poi를 다양하게 조작할 수 있습니다.

### 3-1. 위치 이동

```dart
// 즉시 이동
await poi.move(const LatLng(37.56664, 126.97822));

// 애니메이션과 함께 이동 (3000ms)
await poi.move(const LatLng(37.56664, 126.97822), 3000);

// 경로를 따라 이동 (5초)
await poi.movePath(
  [
    const LatLng(37.394776, 127.11116),
    const LatLng(37.450, 127.050),
    const LatLng(37.56664, 126.97822),
  ],
  5000,
);

// 경로를 따라 이동하며 방향 회전
await poi.movePathWithRotate(
  [
    const LatLng(37.394776, 127.11116),
    const LatLng(37.450, 127.050),
    const LatLng(37.56664, 126.97822),
  ],
  0.0, // 기준 각도 (라디안)
  5000,
);
```

### 3-2. 스타일 및 텍스트 변경

```dart
// 스타일 변경
final newStyle = PoiStyle(icon: KImage.fromAsset('assets/new_marker.png', 40, 60));
await controller.addPoiStyle(newStyle);
await poi.changeStyles(newStyle);

// 텍스트 변경
await poi.changeText('새로운 텍스트');

// 회전 (각도 단위)
await poi.rotate(45.0);

// 크기 변환
await poi.scale(1.5, 1.5); // X, Y 축으로 1.5배 확대
```

### 3-3. 표시/숨기기 및 삭제

```dart
// 단일 Poi 제어
await poi.show();
await poi.hide();
await poi.remove();

// 레이어 내 모든 Poi 일괄 제어
await controller.labelLayer.showAllPoi();
await controller.labelLayer.hideAllPoi();
```

### 3-4. Poi 공유 (Share)

한 Poi가 이동할 때 다른 Poi나 도형도 함께 움직이도록 연결할 수 있습니다.

```dart
// 위치 공유: mainPoi가 이동하면 directionPoi도 같은 위치로 이동합니다.
await mainPoi.addSharePosition(directionPoi);

// 변환 공유: mainPoi의 위치, 회전, 변환이 모두 targetPoi에 적용됩니다.
await mainPoi.addShareTransformPoi(targetPoi);

// 공유 해제
await mainPoi.removeSharePosition(directionPoi);
await mainPoi.removeShareTransformPoi(targetPoi);
```

## 4. 뱃지 추가하기

[스크린샷]

[Badge](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/Badge-class.html)는 Poi 위에 추가로 표시할 수 있는 작은 이미지 요소입니다.\
[Poi.addBadge()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/Poi/addBadge.html) 함수를 이용하여 Poi에 뱃지를 추가할 수 있습니다.

```dart
Future<void> addBadgeExample(Poi poi) async {
  // 뱃지 추가 (X, Y 오프셋: 0.0~1.0 범위, Poi 아이콘 기준 상대 위치)
  final badge = await poi.addBadge(
    KImage.fromAsset('assets/badge_sale.png', 24, 24),
    0.15, // X 오프셋
    0.7,  // Y 오프셋
  );

  // 뱃지 표시/숨기기 및 삭제
  await badge.hide();
  await badge.show();
  await badge.remove();

  // 모든 뱃지 한번에 삭제
  await poi.removeAllBadge();
}
```

## 5. LodPoi 추가하기

[스크린샷]

LodPoi는 수많은 Poi를 지도에 표시할 때 성능을 최적화하는 요소입니다.\
LOD(Level of Detail) 기술을 통해 줌 레벨에 따라 표시될 LodPoi를 사전에 계산하여 효율적으로 렌더링합니다.

> LodPoi는 일반 Poi와 달리 이동(move) 및 회전(rotate) 기능을 지원하지 않습니다.

LodPoi는 [LodLabelController.addLodPoi()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LodLabelController/addLodPoi.html) 함수로 추가하며,\
[KakaoMapController.lodLabelLayer](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/lodLabelLayer.html)를 통해 기본 LodLabelLayer에 접근합니다.

```dart
Future<void> addLodPoiExample(KakaoMapController controller) async {
  final style = PoiStyle(
    icon: KImage.fromAsset('assets/store.png', 30, 30),
  );
  await controller.addPoiStyle(style);

  // 대량의 LodPoi 추가
  final locations = [
    const LatLng(37.394776, 127.11116),
    const LatLng(37.395012, 127.112043),
    const LatLng(37.393988, 127.110201),
    // ...
  ];

  for (final location in locations) {
    await controller.lodLabelLayer.addLodPoi(
      location,
      style: style,
      text: '가게',
    );
  }
}
```

LodLabelLayer는 `radius` 인수로 LOD 판별 반경(픽셀)을 설정할 수 있습니다.\
이 반경을 기준으로 동일 반경 내의 LodPoi 중 표시할 요소를 결정합니다.

```dart
// 커스텀 LodLabelLayer 생성 (반경 50픽셀)
final lodLayer = await controller.addLodLabelLayer(
  'custom_lod_layer',
  radius: 50.0,
);
```

LodPoi 클릭 이벤트는 [KakaoMap.onLodPoiClick](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMap/onLodPoiClick.html) 콜백을 통해 처리할 수 있습니다.

```dart
KakaoMap(
  onMapReady: (controller) { /* ... */ },
  onLodPoiClick: (LodLabelController layer, LodPoi poi) {
    print('${poi.text} LodPoi가 클릭되었습니다!');
  },
);
```

## 6. Poi 추적하기 (Tracking)

카메라가 특정 Poi의 위치를 자동으로 따라가도록 설정할 수 있습니다.\
[KakaoMapController.tracking](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/tracking.html)을 통해 [TrackingController](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/TrackingController-class.html)에 접근합니다.

```dart
Future<void> trackingExample(KakaoMapController controller, Poi poi) async {
  // 추적할 Poi 설정
  controller.tracking.poi = poi;

  // 추적 시작 (Poi가 이동하면 카메라가 따라갑니다.)
  await controller.tracking.start();

  // Poi 회전도 함께 추적
  await controller.tracking.setTrackingRotate(true);

  // 추적 종료
  await controller.tracking.stop();
}
```

## 7. 커스텀 레이어 생성하기

기본 레이어 외에 별도의 레이어를 생성하여 Poi를 독립적으로 관리할 수 있습니다.\
[KakaoMapController.addLabelLayer()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/addLabelLayer.html) 함수를 이용하여 새 레이어를 추가할 수 있습니다.

```dart
Future<void> customLayerExample(KakaoMapController controller) async {
  final myLayer = await controller.addLabelLayer(
    'my_custom_layer',
    zOrder: 10002,
  );

  // 레이어에 Poi 추가
  await myLayer.addPoi(
    const LatLng(37.394776, 127.11116),
    style: style,
  );

  // ID로 레이어 가져오기
  final sameLayer = controller.getLabelLayer('my_custom_layer');

  // 레이어 삭제
  await controller.removeLabelLayer(myLayer);
}
```
