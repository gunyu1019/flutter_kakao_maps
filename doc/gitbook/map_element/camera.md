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

