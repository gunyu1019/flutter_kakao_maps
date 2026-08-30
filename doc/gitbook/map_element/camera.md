# 카메라 조작하기

지도에 보이는 영역은 `KakaoMapController`의 카메라 API로 조회하고 변경합니다. 카메라 이동 명령은 `CameraUpdate`, 애니메이션은 `CameraAnimation`으로 구성합니다.

## 1. 현재 카메라 조회

```dart
final position = await controller.getCameraPosition();

debugPrint('중심: ${position.position}');
debugPrint('줌: ${position.zoomLevel}');
debugPrint('회전: ${position.rotationAngle}');
debugPrint('기울기: ${position.tiltAngle}');
debugPrint('높이: ${position.height}');
```

| Property | 설명 |
| --- | --- |
| `position` | 카메라 중심의 WGS84 위·경도 |
| `zoomLevel` | 지도 확대·축소 단계 |
| `rotationAngle` | 북쪽 기준 회전 각도 |
| `tiltAngle` | 카메라 기울기 |
| `height` | 카메라 높이 |

> Web의 기반 JavaScript SDK는 회전과 기울기를 지원하지 않습니다. Web에서 두 값으로 카메라를 조작하려 하지 말고 중심과 줌을 기준으로 UI를 구성하세요.

## 2. CameraUpdate 종류

| Factory | 용도 |
| --- | --- |
| `newCenterPosition(position, zoomLevel:)` | 중심 좌표와 선택적 줌 이동 |
| `newCameraPos(cameraPosition)` | 전체 CameraPosition 적용 |
| `zoomTo(zoomLevel)` | 특정 줌 레벨로 이동 |
| `zoomIn()` / `zoomOut()` | 한 단계 확대 / 축소 |
| `rotate(angle)` | 회전 |
| `tilt(angle)` | 기울기 |
| `fitMapPoints(points, padding:, zoomLevel:)` | 모든 좌표가 화면에 들어오도록 맞춤 |

```dart
await controller.moveCamera(
  CameraUpdate.newCenterPosition(
    const LatLng(37.566649, 126.978221),
    zoomLevel: 16,
  ),
);
```

```dart
await controller.moveCamera(
  CameraUpdate.fitMapPoints(
    const [
      LatLng(37.394776, 127.111160),
      LatLng(37.566649, 126.978221),
    ],
    padding: 48,
  ),
);
```

## 3. 애니메이션 이동

`CameraAnimation`의 첫 번째 값은 밀리초 단위 지속 시간입니다.

```dart
await controller.moveCamera(
  CameraUpdate.newCenterPosition(
    const LatLng(37.394776, 127.11116),
    zoomLevel: 17,
  ),
  animation: const CameraAnimation(
    1200,
    autoElevation: true,
    isConsecutive: false,
  ),
);
```

| Property | 설명 |
| --- | --- |
| `duration` | 애니메이션 지속 시간(ms) |
| `autoElevation` | 먼 거리를 이동할 때 카메라 높이를 자동 조절할지 여부 |
| `isConsecutive` | 진행 중인 애니메이션에 연속하여 적용할지 여부 |

## 4. 회전·기울기와 전체 위치

```dart
final current = await controller.getCameraPosition();

await controller.moveCamera(
  CameraUpdate.newCameraPos(
    current.copyWith(
      zoomLevel: 17,
      rotationAngle: 30,
      tiltAngle: 45,
    ),
  ),
);
```

또는 현재 상태를 기준으로 회전·기울기 명령을 전달합니다.

```dart
await controller.moveCamera(CameraUpdate.rotate(30));
await controller.moveCamera(CameraUpdate.tilt(45));
```

## 5. 이동 완료 감지

카메라 상태가 필요한 검색이나 네트워크 요청은 매 프레임이 아니라 `onCameraMoveEnd`에서 처리하는 편이 안전합니다.

```dart
KakaoMap(
  onMapReady: (controller) {},
  onCameraMoveStart: (gestureType) {
    debugPrint('이동 시작: $gestureType');
  },
  onCameraMoveEnd: (position, gestureType) {
    debugPrint('이동 완료: ${position.position}');
  },
);
```

코드가 `moveCamera()`를 호출하여 이동한 경우 `GestureType.unknown`이 전달됩니다. 사용 가능한 전체 이벤트는 [지도 이벤트 수신하기](events.md)를 참고하세요.
