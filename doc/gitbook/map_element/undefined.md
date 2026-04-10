# 지도 이벤트 수신하기

지도에는 사용자에 의해 카메라 위치가 변경되는 등의 여러 이벤트가 있습니다. 애플리케이션은 지도에서 발생한 이벤트를 추적하여 특정 상황에 따라 발생한 정보를 기반으로 사용자에게 기능을 제공할 수 있습니다.

지도 이벤트는 [KakaoMap](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMap-class.html) 위젯에 클로저 함수를 인수로 제공하여 이벤트를 수신받을 수 있습니다.

```dart
Widget mapWidget(BuildContext context) => KakaoMap(
    onMapReady: (KakaoMapController controller) {
      print("Map Ready!")
    },
    option: const KakaoMapOption(),
  );
```

&#x20;`onMapReady` 이벤트를 수신하여, 지도가 활성화되었을 때 콘솔창에 "Map Ready!"라는 문구를 띄워줍니다.

## 1. 상태주기 관리

상태주기 관리는 지도의 상태에 따라 호출되는 이벤트이며, 대표적으로 `onMapReady`가 있습니다. \
상태 관리 이벤트는 상황에 따라 다음과 같이 함수가 호출됩니다.

```dart
Widget mapWidget(BuildContext context) => KakaoMap(
    onMapReady: (KakaoMapController controller) {},
    onMapError: (Error err) {},
    onMapLifecycle: ...
    option: const KakaoMapOption(),
  );
```

* onMapReady: 애플리케이션에 지도가 완전히 불러와져서 조작을 할 수 있을때 호출되는 함수입니다.
* onMapError: 인증 실패 등의 지도를 처리하는 과정에서 예상치 못한 오류가 발생하면 호출되는 함수입니다.
* onMapLifecycle: 백그라운드 상황 등으로 지도가 일시정지되거나, 정지되면 호출됩니다. 해당 인수는 Mixin 형태의 객체가 인수로 입력되며, 다음과 같이 소스코드를 작성해주셔야 합니다.\
  \
  예제의 소스코드와 같이 함수를 override 하여 필요한 이벤트를 수신받을 수 있습니다.

```dart
class ExampleApplication with KakaoMapLifecycle {
  @override
  void onMapDestroy {}

  @override
  void onMapPaused {}
  
  @override
  void onMapResumed {}
}
```

## 2. 카메라 이동

[카메라 조작 함수](camera.md#id-2) 또는 사용자의 조작에 의해 지도에 보여지는 카메라가 움직일 경우 호출되는 이벤트로 `onCameraMoveStart`와 `onCameraMoveEnd`가 있습니다.

```dart
Widget mapWidget(BuildContext context) => KakaoMap(
    onMapReady: ...,
    onCameraMoveStart: (GestureType gesture) {},
    onCameraMoveEnd: (GestureType gesture, CameraPosition position),
    option: const KakaoMapOption(),
  );
```

두 이벤트 모두 [GestureType](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/GestureType.html) 형태의 인수가 제공되며, 카메라를 이동한 방법을 의미합니다. \
[카메라 조작 함수](camera.md#id-2)에 의해 카메라의 위치가 변경되었다면 `GestureType.unknown`이 인수로 제공됩니다.

`onCameraMoveEnd` 함수에는 최종 카메라의 위치를 담은 [CameraPosition](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraPosition-class.html) 형태의 인수도 제공됩니다.

## 3. 클릭 이벤트

사용자가 지도 표면을 클릭하거나, 지도에 그려진 특정 요소를 클릭하였을 때 발생하는 이벤트로 `on...Click` 형태의 이벤트로 호출됩니다.

```dart
Widget mapWidget(BuildContext context) => KakaoMap(
    onMapReady: ...,
    onMapClick: (KPoint point, LatLng position) {},
    onPoiClick: (LabelController controller, Poi poi) {},
    option: const KakaoMapOption(),
  );
```

클릭 이벤트는 지도 표면을 클릭하는 이벤트와 지도에 그려진 특정 요소를 클릭하는 이벤트로 구분되며, 지도 표면을 클릭하는 이벤트는 다음과 같습니다.&#x20;

* onMapClick: 지도 화면을 클릭하면 호출되는 이벤트 함수입니다.
* onTerrainClick: 지도 표면(특정 요소가 그려지지 않은 부분)을 클릭하면 호출되는 이벤트 함수입니다.
* onTerrainLongClick: 지도 표면(특정 요소가 그려지지 않은 부분)을 길게 클릭하면 호출되는 이벤트 함수입니다.

위에 나열된 함수는 모두 [KPoint](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KPoint-class.html)와 [LatLng](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LatLng-class.html) 형태의 데이터가 인수로 입력되며 [KPoint](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KPoint-class.html)는 0 부터 화면 크기까지 값으로 구성되며 사용자가 클릭한 화면의 위치를 반환합니다. [LatLng](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LatLng-class.html) 형태의 데이터는 사용자가 클릭한 지도의 WGS84 좌표를 불러옵니다.

특정 요소의 클릭을 감지하는 이벤트는 다음과 같이 구성되어 있습니다.

* onCompassClick: 지도에 활성화되어 있는 나침판을 클릭하면 호출되는 이벤트 함수입니다.
* onPoiClick: 지도에 그려저있는 Poi를 클릭하면 호출되는 이벤트입니다.
* onLodPoiClick: 지도에 그려저있는 LodPoi를 클릭하면 호출되는 이벤트입니다.

onPoiClick과 onLodPoiClick 이벤트 함수는 클릭된 Poi의 컨트롤러 객체와 Poi 객체와 함께 제공합니다.
