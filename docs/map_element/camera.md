# 카메라 조작하기

평면 지도를(입체 지도)를 내려다 보는 카메라에 의해 애플리케이션에 지도 정보를 제공합니다. \
[CameraPosition](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraPosition-class.html) 객체를 통해 사용자에게 보여주는 카메라의 위치 알거나, 조작할 수 있습니다.

## 1. 카메라 위치 읽어오기

카메라 위치는 [KakaoMapController.getCameraPosition()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/getCameraPosition.html) 함수를 이용하려 불러올 수 있습니다.

```dart
Future<CameraPosition> getCameraPosition(KakaoMapController controller) async {
  return await controller.getCameraPosition();
}
```

위 함수를 사용하게 되면, [CameraPosition](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraPosition-class.html) 객체를 반환받습니다.

`CameraPosition` 객체에는 아래의 표와 같은 정보를 담고 있습니다.

<table><thead><tr><th width="125">Property</th><th>Description </th></tr></thead><tbody><tr><td>position</td><td>지도를 비추고 있는 카메라의 중심 위치를 WGS84 형식(<a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LatLng-class.html">LatLng</a>)으로 표현합니다.</td></tr><tr><td>zoomLevel</td><td>6단계부터 21단계로 구성된 정수로 값에 따라 카메라의 축소/확대 비율을 조정합니다.</td></tr><tr><td>rotateAngle</td><td>카메라의 회전 각도를 의미합니다. 북쪽을 기준으로 값에 따라 시계 방향으로 회전합니다.<br><sub>(웹 플랫폼에서 카메라의 회전 기능은 지원하지 않습니다.)</sub></td></tr><tr><td>tiltAngle</td><td>카메라의 기울기 각도를 의미합니다. 틸트를 조정하면 평면 지도가 입체 지도로 표현됩니다.<br><sub>(웹 플랫폼에서 카메라의 기울기의 기능은 지원하지 않습니다.)</sub></td></tr><tr><td>height</td><td> 카메라의 높이 값을 가져옵니다.</td></tr></tbody></table>

## 2. 카메라 이동하기

카메라 위치는 [KakaoMapController.moveCamera()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/moveCamera.html) 함수와 [CameraUpdate ](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraUpdate-class.html)객체 이용하여 이동할 수 있습니다.

```dart
Future<CameraPosition> moveCamera(KakaoMapController controller) async {
  final newPosition = CameraUpdate.newCameraPosition(...);
  return await controller.moveCamera(newPosition);
}
```

[CameraUpdate](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraUpdate-class.html) 객체는 다양한 형태의 생성자를 이용하여 카메라 위치를 이동할 수 있습니다.

<table><thead><tr><th width="180">Constructor</th><th>Description </th></tr></thead><tbody><tr><td>newCeneterPosition</td><td>WGS84(<a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LatLng-class.html">LatLng</a>) 위치로 카메라를 위치합니다.</td></tr><tr><td>newCameraPosition</td><td><a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraPosition-class.html">CameraPosition</a> 객체 정보를 기반으로 카메라를 이동합니다.</td></tr><tr><td>rotate</td><td>주어진 인수(소수 값)만큼 카메라를 회전합니다.<br><sub>(웹 플랫폼에서 카메라의 회전 기능은 지원하지 않습니다.)</sub></td></tr><tr><td>tilt</td><td>주어진 인수(소수 값)만큼 카메라를 기울게 합니다.<br><sub>(웹 플랫폼에서 카메라의 회전 기능은 지원하지 않습니다.)</sub></td></tr><tr><td>zoomTo</td><td>주어진 인수에 따라 6단계~21단계 형태의 축소/확대 비율을 조정합니다.</td></tr><tr><td>zoomIn</td><td>카메라를한 단계 확대합니다.</td></tr><tr><td>zoomOut</td><td>카메라를 한 단계 축소합니다.</td></tr><tr><td>fitMapPoints</td><td>주어진 좌표를 화면의 가장자리에 맞춰 보여지도록 카메라 위치를 조정합니다.</td></tr></tbody></table>

## 3. 카메라에 애니메이션 효과를 적용하며 이동하기

[KakaoMapController.moveCamera()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/moveCamera.html) 함수에 animation 인수를 제공하면 애니메이션 효과를 적용하며, 특정 시간 동안 카메라를 이동시킬 수 있습니다.

```dart
Future<CameraPosition> moveAnimatedCamera(KakaoMapController controller) async {
  final newPosition = CameraUpdate.newCameraPosition(...);
  final animation = const CameraAnimation(5000);
  return await controller.moveCamera(newPosition, animation: animation);
}
```

애니메이션 효과는 [CameraAnimation](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraAnimation-class.html) 객체를 moveCamera 함수의 animation 인수로 제공하여 적용할 수 있습니다. 위에 나열된 예제는 5000ms(5초) 동안 `newPosition`으로 카메라를 이동하는 소스코드입니다.
