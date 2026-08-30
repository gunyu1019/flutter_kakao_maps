# 지도 그리기

`KakaoMap` 위젯을 화면에 배치하면 플랫폼에 맞는 지도 View가 생성됩니다. 지도를 조작하는 코드는 `onMapReady`에서 전달되는 `KakaoMapController`를 기준으로 시작합니다.

## 1. 기본 지도 위젯

```dart
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  KakaoMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KakaoMap(
        option: const KakaoMapOption(
          position: LatLng(37.394776, 127.11116),
          zoomLevel: 16,
          mapType: MapType.normal,
        ),
        onMapReady: (controller) {
          setState(() => _controller = controller);
        },
        onMapError: (error) {
          debugPrint('지도 오류: $error');
        },
      ),
    );
  }
}
```

> `onMapReady`가 호출되기 전에는 컨트롤러와 오버레이를 사용하지 마세요. Android의 비상 재생성 옵션을 켠 경우에는 복귀 과정에서 `onMapReady`가 다시 호출될 수 있습니다.

## 2. KakaoMapOption

`KakaoMapOption`은 최초 지도를 생성할 때 적용되는 값입니다.

| Property | 기본값 | 설명 |
| --- | --- | --- |
| `position` | 카카오 판교캠퍼스 | 최초 카메라 중심 좌표 |
| `zoomLevel` | `15` | 최초 줌 레벨 |
| `mapType` | `MapType.normal` | 일반 지도 또는 스카이뷰 |
| `viewName` | 자동 생성 | iOS native view 식별자. 여러 지도에서 중복 금지 |
| `visible` | `true` | 지도 초기 표시 여부 |
| `tag` | `null` | 지도 View에 전달하는 선택적 태그 |

```dart
const option = KakaoMapOption(
  position: LatLng(37.566649, 126.978221),
  zoomLevel: 15,
  mapType: MapType.skyview,
  viewName: 'main-map',
  tag: 'home',
);
```

## 3. 지도 유형 변경

최초 유형은 `KakaoMapOption.mapType`으로 지정하고, 생성 후에는 `changeMapType()`으로 변경합니다.

| 값 | 설명 |
| --- | --- |
| `MapType.normal` | 일반 지도 |
| `MapType.skyview` | 위성 지도 |

| 일반 지도 | 스카이뷰 |
| --- | --- |
| ![일반 지도](../.gitbook/assets/imageservice.png) | ![스카이뷰](../.gitbook/assets/skyviewimageservice.jpg) |

```dart
await controller.changeMapType(MapType.skyview);
```

## 4. 지도 기본 오버레이

Kakao 지도 자체에서 제공하는 정보를 `showOverlay()`와 `hideOverlay()`로 제어합니다.

| 값 | 설명 |
| --- | --- |
| `MapOverlay.bicycleRoad` | 자전거 도로 |
| `MapOverlay.roadviewLine` | 로드뷰 촬영 경로 |
| `MapOverlay.hillsading` | 지형 음영 |
| `MapOverlay.hybrid` | 스카이뷰 위 도로·지명 레이블 |

```dart
await controller.showOverlay(MapOverlay.bicycleRoad);
await controller.hideOverlay(MapOverlay.bicycleRoad);
```

> 교통정보 오버레이는 기본 제공 범위가 아니며 별도 협의가 필요할 수 있습니다.

## 5. 여러 지도를 배치할 때

각 `KakaoMap`은 서로 다른 컨트롤러와 레이어 저장소를 가집니다. 특히 iOS에서는 `viewName`을 고유하게 지정하세요.

```dart
Row(
  children: [
    Expanded(
      child: KakaoMap(
        option: const KakaoMapOption(viewName: 'left-map'),
        onMapReady: (controller) {},
      ),
    ),
    Expanded(
      child: KakaoMap(
        option: const KakaoMapOption(viewName: 'right-map'),
        onMapReady: (controller) {},
      ),
    ),
  ],
);
```

## 6. 다음 단계

* 지도를 움직이려면 [카메라 조작하기](../map_element/camera.md)를 참고합니다.
* 탭과 카메라 이벤트를 받으려면 [지도 이벤트 수신하기](../map_element/events.md)를 참고합니다.
* Poi나 경로를 추가하려면 [오버레이와 레이어 이해하기](../overlay/architecture.md)를 먼저 읽어보세요.
