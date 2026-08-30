# 지도 컨트롤러 활용하기

`KakaoMapController`는 카메라 외에도 제스처, 좌표 변환, 지도 경계, 기본 GUI, 캐시와 지도 오버레이를 제어합니다. 모든 호출은 `onMapReady` 이후에 수행하세요.

## 1. 제스처 활성화

```dart
await controller.setGesture(GestureType.zoom, false);
await controller.setGesture(GestureType.rotate, false);

// 다시 활성화
await controller.setGesture(GestureType.zoom, true);
```

`KakaoMap.forceGesture`는 Flutter의 다른 GestureRecognizer보다 지도에 제스처를 우선 전달할지를 결정합니다. 기본값은 `true`입니다. 스크롤 뷰 안에 지도를 넣었을 때 부모 스크롤과 충돌한다면 이 값과 개별 `setGesture()` 설정을 함께 검토하세요.

## 2. 화면 좌표와 위·경도 변환

```dart
final screenPoint = await controller.toScreenPoint(
  const LatLng(37.394776, 127.11116),
);

final latLng = await controller.fromScreenPoint(120, 240);
```

플랫폼 View가 아직 레이아웃되지 않았거나 변환할 수 없는 시점에는 `null`이 반환될 수 있습니다.

## 3. 현재 화면 경계 조회

`getBounds()`는 보이는 지도 네 모서리를 조회하여 `LatLngBounds`를 반환합니다. 회전된 화면에서도 네 모서리의 최소·최대 위경도로 경계를 계산합니다.

```dart
final mapKey = GlobalKey();

KakaoMap(
  key: mapKey,
  onMapReady: (controller) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapContext = mapKey.currentContext;
      if (mapContext == null) return;

      final bounds = await controller.getBounds(mapContext);
      debugPrint('REST rect: ${bounds?.toRect()}');
    });
  },
);
```

`LatLngBounds`는 `ne`, `nw`, `se`, `sw` 네 모서리를 제공하고, `toRect()`는 `west,south,east,north` 문자열을 만듭니다. 지도 크기가 없거나 native 변환 결과가 일시적으로 준비되지 않았다면 `null`이 반환될 수 있으므로 반드시 처리하세요.

## 4. 여러 좌표의 표시 가능 여부

```dart
final visible = await controller.canShowPosition(
  15,
  const [
    LatLng(37.394776, 127.11116),
    LatLng(37.402005, 127.108621),
  ],
);
```

Web에서는 `zoomLevel` 인수를 적용하지 않고 현재 화면을 기준으로 판단합니다. 모든 좌표에 맞게 카메라를 옮기는 목적이라면 `CameraUpdate.fitMapPoints()`를 사용하세요.

## 5. 나침반·축척·로고

```dart
await controller.compass.show();
await controller.compass.changePosition(
  const MapGravity(HorizontalAlign.right, VerticalAlign.top),
  16,
  16,
);

await controller.scaleBar.show();
await controller.scaleBar.setAutohide(true);
await controller.scaleBar.setAnimationTime(200, 200, 1500);

await controller.logo.changePosition(
  const MapGravity(HorizontalAlign.left, VerticalAlign.bottom),
  12,
  12,
);
```

`Compass`와 `ScaleBar`는 표시·숨김과 위치 변경을 지원합니다. `Logo`는 위치만 변경할 수 있습니다.

## 6. 건물 높이 배율

```dart
final scale = await controller.fetchBuildingHeightScale();
await controller.setBuildingHeightScale(0.8);
```

`buildingHeightScale`에는 마지막으로 읽거나 설정한 값이 보관됩니다. Web에서는 항상 `0.0`이며 변경되지 않습니다.

## 7. 캐시 정리

```dart
await controller.clearCache();
await controller.clearDiskCache();
```

캐시 정리는 반복적으로 호출할 일반 UI 기능이 아닙니다. 지도 리소스 문제를 복구하거나 저장 공간 정책을 구현할 때 제한적으로 사용하세요.

## 8. 지도 자체 오버레이

```dart
await controller.showOverlay(MapOverlay.roadviewLine);
await controller.hideOverlay(MapOverlay.roadviewLine);
```

자전거 도로, 로드뷰 라인, 지형 음영, 스카이뷰 hybrid 레이블 목록은 [지도 그리기](../getting_started/configuration_map.md#4-지도-기본-오버레이)를 참고하세요.
