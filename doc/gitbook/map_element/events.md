# 지도 이벤트 수신하기

지도 이벤트는 `KakaoMap` 생성자에 콜백을 전달하여 수신합니다. 컨트롤러가 필요한 초기화는 `onMapReady`, 사용자 입력은 클릭·카메라 콜백, 오류는 `onMapError`에서 처리합니다.

## 1. 이벤트 목록

| Callback | 전달 값 | 호출 시점 |
| --- | --- | --- |
| `onMapReady` | `KakaoMapController` | 지도 조작이 가능해졌을 때 |
| `onMapError` | `Error` | 인증 또는 지도 처리 오류가 발생했을 때 |
| `onCameraMoveStart` | `GestureType` | 카메라 이동 시작 |
| `onCameraMoveEnd` | `CameraPosition`, `GestureType` | 카메라 이동 완료 |
| `onMapClick` | `KPoint`, `LatLng` | 지도판 클릭 |
| `onTerrainClick` | `KPoint`, `LatLng` | Poi·LodPoi가 아닌 지형 클릭 |
| `onTerrainLongClick` | `KPoint`, `LatLng` | 지형 길게 누르기 |
| `onPoiClick` | `LabelController`, `Poi` | Poi 클릭 |
| `onLodPoiClick` | `LodLabelController`, `LodPoi` | LodPoi 클릭 |
| `onCompassClick` | 없음 | 나침반 클릭 |

## 2. 한 번에 연결하기

```dart
KakaoMap(
  option: const KakaoMapOption(),
  onMapReady: (controller) {
    debugPrint('지도 준비 완료');
  },
  onMapError: (error) {
    debugPrint('지도 오류: $error');
  },
  onCameraMoveStart: (gestureType) {
    debugPrint('카메라 이동 시작: $gestureType');
  },
  onCameraMoveEnd: (position, gestureType) {
    debugPrint(
      '카메라 이동 완료: ${position.position}, ${position.zoomLevel}',
    );
  },
  onMapClick: (screenPoint, latLng) {
    debugPrint('화면 $screenPoint / 좌표 $latLng');
  },
  onTerrainLongClick: (screenPoint, latLng) {
    debugPrint('길게 누른 좌표: $latLng');
  },
  onPoiClick: (layer, poi) {
    debugPrint('Poi 클릭: ${layer.id} / ${poi.id}');
  },
  onLodPoiClick: (layer, poi) {
    debugPrint('LodPoi 클릭: ${layer.id} / ${poi.id}');
  },
  onCompassClick: () {
    debugPrint('나침반 클릭');
  },
);
```

## 3. GestureType

`onCameraMoveStart`와 `onCameraMoveEnd`는 카메라를 움직인 원인을 `GestureType`으로 전달합니다.

* `oneFingerDoubleTap`
* `twoFingerSingleTap`
* `pan`
* `rotate`
* `zoom`
* `tilt`
* `longTapAndDrag`
* `rotateZoom`
* `oneFingerZoom`
* `unknown`

`moveCamera()`처럼 코드가 시작한 이동이나 플랫폼에서 구체적인 원인을 알 수 없는 이동은 `unknown`입니다.

## 4. Poi별 클릭 콜백

전체 지도 콜백 외에 Poi를 만들 때 개별 `onClick`도 지정할 수 있습니다.

```dart
await controller.labelLayer.addPoi(
  const LatLng(37.394776, 127.11116),
  style: PoiStyle(
    icon: KImage.fromAsset('assets/marker.png', 40, 60),
  ),
  onClick: () {
    debugPrint('이 Poi의 개별 콜백');
  },
);
```

개별 `onClick`과 `KakaoMap.onPoiClick`을 모두 등록하면 패키지 이벤트 처리 과정에서 개별 콜백이 먼저 호출되고, 이어서 지도 수준 콜백이 호출됩니다.

## 5. 상태주기 이벤트

`onMapLifecycle`은 함수 하나가 아니라 `KakaoMapLifecycle` 객체를 받습니다. 구성 방법과 Android 복구 옵션은 [상태주기와 Android 복구](lifecycle.md)를 참고하세요.
