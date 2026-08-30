# 좌표와 이미지 다루기

지도 API 전반에서 반복해서 사용하는 핵심 값은 `LatLng`, `KPoint`, `LatLngBounds`, `KImage`입니다.

## 1. LatLng

`LatLng`은 WGS84 위도와 경도를 저장합니다.

```dart
const pangyo = LatLng(37.394776, 127.11116);
const cityHall = LatLng(37.566649, 126.978221);
```

두 좌표 사이의 거리를 미터 단위로 계산하거나, 특정 방향과 거리만큼 이동한 새 좌표를 만들 수 있습니다.

```dart
final meters = pangyo.distance(cityHall);

// 현재 좌표에서 90도 방향으로 100m 이동한 좌표
final east100m = pangyo.offset(100, 90);
```

거리 계산은 성능을 고려한 Haversine 공식을 사용하므로 정밀 측량 목적에서는 약 1~2% 오차 가능성을 고려하세요.

## 2. KPoint

`KPoint`는 화면의 x·y 좌표 또는 이미지 anchor처럼 2차원 값을 표현합니다.

```dart
const anchor = KPoint(0.5, 1.0);
```

Poi anchor에서 `(0, 0)`은 이미지 좌상단, `(1, 1)`은 우하단이며 `(0.5, 1.0)`은 하단 중앙을 지도 좌표에 맞춥니다.

## 3. LatLngBounds

`LatLngBounds`는 북동쪽 `ne`와 남서쪽 `sw`를 저장하고 `nw`, `se`를 계산해 제공합니다.

```dart
final bounds = await controller.getBounds(mapContext);
if (bounds != null) {
  debugPrint('북서: ${bounds.nw}');
  debugPrint('남동: ${bounds.se}');
  debugPrint('rect: ${bounds.toRect()}');
}
```

`toRect()` 결과는 카카오 REST API에서 영역을 표현하는 `rect` 파라미터 형식으로 사용할 수 있습니다.

## 4. KImage

`KImage`는 Poi 아이콘, Badge, Route pattern 등에서 사용하는 플랫폼 공통 이미지 모델입니다.

### 4-1. Asset

```yaml
flutter:
  assets:
    - assets/marker.png
```

```dart
final marker = KImage.fromAsset('assets/marker.png', 40, 60);
```

### 4-2. 메모리 데이터

```dart
final image = KImage.fromData(bytes, 40, 60);
```

### 4-3. 파일

```dart
final image = KImage.fromFile(file, 40, 60);
```

`fromFile()`은 `dart:io` 파일을 사용할 수 있는 native 플랫폼용입니다. Web에서는 Asset이나 byte data를 사용하세요.

### 4-4. Flutter Widget

```dart
final image = await KImage.fromWidget(
  const DecoratedBox(
    decoration: BoxDecoration(color: Colors.blue),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Text('A'),
    ),
  ),
  const Size(48, 48),
  context: context,
);
```

`fromWidget()`은 위젯을 PNG 픽셀로 렌더링합니다. 버튼이나 제스처 같은 상호작용은 이미지에 포함되지 않습니다. 고해상도 출력이 필요하면 `pixelRatio`를 지정할 수 있습니다.

## 5. 값 객체 복사

주요 모델은 `copyWith()`, 값 비교 연산자와 `hashCode`를 제공합니다.

```dart
final next = pangyo.copyWith(latitude: 37.4);
final animated = const CameraAnimation(500).copyWith(
  duration: 1000,
  autoElevation: true,
);
```

스타일을 수정할 때 원본을 재사용해야 한다면 직접 필드를 변경하는 대신 `copyWith()`로 새 인스턴스를 만들고 등록하세요.
