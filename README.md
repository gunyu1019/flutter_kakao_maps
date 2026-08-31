# kakao_map_sdk

![Pub Version](https://img.shields.io/pub/v/kakao_map_sdk)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/kakao_map_sdk)
![Pub Points](https://img.shields.io/pub/points/kakao_map_sdk)
![Pub Popularity](https://img.shields.io/pub/popularity/kakao_map_sdk)

Kakao Map SDK는 Flutter 환경에서 [카카오 지도](https://map.kakao.com/)을 사용할 수 있도록 하는 패키지입니다!

[시작하기](https://gunyu1019.gitbook.io/kakao-map-sdk/getting_started/installation) · [플랫폼 지원 범위](https://gunyu1019.gitbook.io/kakao-map-sdk/getting_started/platform-support) · [API Reference](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/) · [변경 이력](CHANGELOG.md)

| Android                | iOS             | Web(Experimental)      |
|------------------------|-----------------| ---------------------- |
| `SDK 6.0(API 23)` 이상 | `iOS 13` 이상    | [Flutter Web과 동일 환경](https://docs.flutter.dev/reference/supported-platforms) |
| `armeabi-v7a`, `arm64-v8a` 아키텍쳐 지원<br/>(`x86`, `x64` 아키텍쳐 미호환) |        |
| `OpenGL ES 2.0` 이상 |         |          |
| 인터넷 권한 필요   |         |             |

## 1. Getting Started
Flutter에서 카카오 지도를 이용하기 위해 [카카오 개발자 사이트](https://developers.kakao.com/)에서 앱 등록을 해야합니다.<br/>
앱 등록을 마치면 카카오 지도를 사용할 수 있는 **네이티브 앱 키(App Key)** 를 발급받을 수 있습니다.

먼저 프로젝트에 패키지를 추가합니다.

```bash
flutter pub add kakao_map_sdk
```

앱 키는 아래와 같이 `KakaoMapSdk.instance.initialize` 함수를 호출하여 클라이언트를 인증하실 수 있습니다.
```dart
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapSdk.instance.initialize('KAKAO_API_KEY');
  runApp( ... )
}
```

### Android Platform
안드로이드 환경에서 카카오맵을 이용하기 위해서는 아래에 서술된 추가 설정이 필요합니다.
1. `AndroidManifest.xml`에 아래와 같이 인터넷 권한과 위치 권한을 제공해야 합니다.
    ```xml
      <uses-permission android:name="android.permission.INTERNET" />
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
      <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ```
2. 애플리케이션을 배포하는 경우, Kakao Map SDK는 코드 축소, 난독화, 최적화 대상에서 제외해야 합니다.<br/>
  `android > app > proguard-rules.pro` 파일을 아래와 같이 설정주십시요.
    ```pro
    -keep class com.kakao.vectormap.** { *; }
    -keep interface com.kakao.vectormap.**
    ```
3. 안드로이드에서 카카오지도를 이용하려면 키해시 인증 과정이 필요합니다.<br/>
  자세한 내용은 [플랫폼 등록](https://developers.kakao.com/docs/latest/ko/getting-started/app#platform-android)과 [키 해시](https://developers.kakao.com/docs/latest/ko/android/getting-started#before-you-begin-add-key-hash)을 읽어주세요.<br/>

    Flutter Kakao Maps 플러그인은 디버깅, 릴리즈 해시키를 제공받을 수 있는 함수를 제공하고 있습니다.
    ```dart
    await KakaoMapSdk.instance.hashKey();
    ```
    안드로이드 플랫폼 외 다른 플랫폼에서 함수를 호출하면 `null`을 반환합니다.
4. 일부 Android 환경에서 앱이 백그라운드에서 복귀한 뒤 지도 영역이 검은 화면으로 멈춘다면, 아래 옵션으로 native `MapView`를 재생성하는 복구 경로를 사용할 수 있습니다.<br/>
   이 옵션은 복귀할 때 기존 native 지도 인스턴스를 종료하고 새로 시작하므로 `onMapReady`가 다시 호출됩니다. 앱에서 추가한 오버레이는 `onMapReady` 안에서 다시 구성할 수 있도록 작성해야 합니다.
    ```dart
    KakaoMap(
      recreateAndroidMapViewOnResume: true,
      androidMapViewRecreationDelay: const Duration(milliseconds: 300),
      onMapReady: (controller) {
        // 스타일, 레이어, 오버레이를 idempotent하게 다시 구성합니다.
      },
    )
    ```

### Web Environment
웹 환경에서 카카오맵을 이용하기 위해서는 아래에 서술된 추가 설정이 필요합니다.<br/>
아래에 기재된 소스코드를 `web/index.html`에 추가해주세요.

```html
...
<head>
  ...
  <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=<JavaScript 키>"></script>
  ...
</head>
...
```
`<JavaScript 키>` 는 `<네이티브 키>`와 다른 키로 [카카오 개발자 사이트](https://developers.kakao.com/)에서 앱 등록을 마치면 발급받을 수 있습니다.

## 2. Add MapView Widget
지도를 담고 있는 위젯(Widget)은 아래와 같이 `KakaoMap` 함수를 호출하여 사용할 수 있습니다.
```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: KakaoMap(
      option: const KakaoMapOption(
        position: LatLng(기본 위치),
        zoomLevel: 16,
        mapType: MapType.normal,
      ),
      onMapReady: (KakaoMapController controller) {
        print("카카오 지도가 정상적으로 불러와졌습니다.");
      },
    ),
  );
}
```
option 매게변수에는 초기화 과정에서 기본 값([KakaoMapOption](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapOption-class.html))을 설정할 수 있습니다.<br/>
아무 문제 없이 지도를 불러온다면, `onMapReady` 매개변수에 담긴 함수가 호출됩니다.<br/>
함수 매개변수에는 지도를 관리하기 위한 컨트롤러([KakaoMapController](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController-class.html))가 입력됩니다.

## 3. Move the Camera to show the map
Kakao Map SDK는 컨트롤러([KakaoMapController](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController-class.html))를 이용하여 카메라의 위치를 조회하거나, 카메라의 위치를 이동할 수 있습니다.
카메라의 위치는 `getCameraPosition` 함수를 이용하여 불러올 수 있습니다.

```dart
Future<void> getCameraPosition(KakaoMapController controller) async {
  final cameraPosition = await controller.getCameraPosition();
  print(cameraPosition.zoomLevel); // 카메라의 축적비입니다. 값이 높을 수록 지도에 보여지는 건물은 줄어들지만, 건물을 상세히 확인하실 수 있습니다.  
  print(cameraPosition.position); // 카메라의 위치입니다. WGS84(위도, 경도) 형식으로 불러옵니다. 
  print(cameraPosition.rotationAngle); // 카메라의 회전 각도를 불러옵니다.
}
```

카메라의 위치는 `moveCamera` 함수와 `CameraUpdate` 객체를 이용하여 움직일 수 있습니다.
자세한 내용은 [CameraUpdate Reference](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/CameraUpdate-class.html)를 참고해주세요. 

```dart
Future<void> setCameraPosition(KakaoMapController controller) async {
  final location = LatLng(37.394776, 127.11116);
  final cameraUpdate = CameraUpdate.newCenterPosition(location);
  await controller.moveCamera(cameraUpdate);
}
```

`moveCamera` 함수에는 `animation` 인수를 제공할 수 있으며 지정된 밀리초(ms)동안 지도를 비추는 카메라가 이동합니다.

```dart
Future<void> setCameraPositionWithAnimation(KakaoMapController controller) async {
  final location = LatLng(37.394776, 127.11116);
  final cameraAnimation = const CameraAnimation(5000); // 5초
  final cameraUpdate = CameraUpdate.newCenterPosition(location);
  await controller.moveCamera(cameraUpdate, animation: cameraAnimation);
}
```

## 4. Write Overlay(Grapic Element) to map
Kakao Map SDK는 사용자에게 표현하기 위한 다양한 그래픽 요소(오버레이 기능)를 제공하고 있습니다.<br/>
다양한 그래픽 요소는 `KakaoMapController`를 통해 제어하실 수 있습니다.

### 4-1. Poi (Label)
<img src="https://github.com/user-attachments/assets/d979c662-64cb-4ced-a96a-f94b67baace3" width="35%" />

특정 위치에 정보를 제공하기 위한 이미지 또는 텍스트를 제공합니다.<br/>
Poi에는 사용하는 방법에 따라 3가지로 구분할 수 있습니다.<br/>

* Poi: 특정 위치에 이미지나 텍스트로 정보를 표시 할 수 있습니다.
* Lod-Poi: LOD(Level of Detail)이 적용되어 한 번에 많은 양의 Poi를 지도에 표시할 수 있습니다. Lod-Poi에는 회전, 이동 기능이 없습니다.
* PolylineText: 선형으로 된 텍스트를 표현할 때 사용합니다.
  
```dart
// Poi
controller.labelLayer.addPoi(
  const LatLng(위도, 경도),
  style: PoiStyle(
    icon: KImage.fromAsset("assets/image/location.png", 68, 100),
  )
)

// Lod Poi
controller.lodLabelLayer.addLodPoi(
  const LatLng(위도, 경도),
  style: PoiStyle(
    icon: KImage.fromAsset("assets/image/location.png", 68, 100),
  )
)

// Polyline Text
// "휘어지는 글씨"라는 문구를 담고 있는 선형 텍스트를 만듭니다.
controller.labelLayer.addPolylineText(
  "휘어지는 글씨",
  const [
    LatLng(위도, 경도),
    ...
  ],
  style: PolylineTextStyle(28, Colors.blue)
);
```

### 4-2. Shape
<table>
  <thead>
    <th>Android</th>
    <th>iOS</th>
  </thead>
  <tbody>
    <td>
      <img src="https://github.com/user-attachments/assets/39cfe1b6-4349-4b1a-8527-a465c3964f57"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/fe9d50ae-e7a4-4b70-b09d-cdb603b7bb37"/>
    </td>
  </tbody>
</table>
지도에 선분이 담긴 도형을 제공합니다.<br/>
Kakao Map SDK에서 제공하는 도형은 두 가지가 있습니다.
* PolylineShape: 선형으로 된 도형입니다.
* PolygonShape: 선형 안에 내용물이 채워진 형태의 도형입니다.

도형을 구성하는 모델좌표계를 구성하는 방법은 2가지 형태가 있습니다.
* DotPoints: 특정 좌표(`LatLng`)을 기준으로 하여 상대 좌표를 이용하여 도형을 구성하는 방식
* MapPoints: 지도의 위도, 경도(`LatLng`)를 이용하여 좌표들의 꼭지점을 이어서 도형을 구성하는 방식

```dart
// DotPoints (RectanglePoint)를 이용하여 가로, 세로 300 크기의 선형(굵기: 10)이 있는 사각형
controller.shapeLayer.addPolylineShape(
  RectanglePoint(300, 300, const LatLng(위도, 경도)),
  PolylineStyle(Colors.green, 10.0),
  PolylineCap.round
);

// DotPoints (CirclePoint)를 이용하여 반지름이 200 크기인 원형
controller.shapeLayer.addPolygonShape(
  CirclePoint(200, const LatLng(위도, 경도)),
  PolygonStyle(Colors.green)
);
```

### 4-3. Route
<table>
  <thead>
    <th>Android</th>
    <th>iOS</th>
  </thead>
  <tbody>
    <td>
      <img src="https://github.com/user-attachments/assets/39c070a4-908f-4954-8683-e6f556eae34a"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/f04bcae4-7f39-4c4f-83c1-b0a59bf11217"/>
    </td>
  </tbody>
</table>
지도에 다양한 선분이 담긴 길찾기 경로 모양의 도형을 제공합니다.

```dart
// 두께가 10이고, 색상은 노란색인 경로 도형을 그립니다.
controller.routeLayer.addRoute(const [
    LatLng(위도, 경도),
    ...
  ],
 RouteStyle(
    Colors.yellow, 10,
  )
);
```

`Route` 기능에는 일정 간격마다 이미지를 삽입하는 패턴 효과를 제공할 수 있습니다.
패턴 효과는 `RouteStyle.withPattern` 생성자를 이용하거나, `pattern` 인수를 제공하여 정의할 수 있습니다.

```dart
// 6px 마다 원형의 도형의 패턴을 가지고 있는 스타일을 정의합니다.
RouteStyle.withPattern(
  RoutePattern(
    KImage.fromAsset("assets/image/circle.png", 30, 30), 6
  )
)
```

### 4-4. DimScreen 
`DimScreen`은 지도 전체를 특정 색으로 가리는 객체입니다. 
`Polygon` 도형을 추가하여 특정 부분을 지정된 색상으로 출력할 수 있습니다.

```dart
// 지도를 투명도 80%를 가지고 있는 회색으로 덮습니다.
await controller.dimScreen.setColor(Colors.grey.withAlpha(80));
await controller.dimScreen.setVisible(true);

// 특정 좌표에 있는 도형은 파란 색상의 테두리를 강조하고, 도형 안 색상을 걷어냅니다.
final polygonStyle = PolygonStyle(
  Colors.transparent,
  strokeWidth: 3.0,
  strokeColor: Colors.blue,
);
await controller.dimScreen.addPolygonShape(
  MapPoint(...),
  polygonStyle,
);
```

### 4-5. Tracking 
Tracking은 지도에 나타난 `Poi`가 `Poi.move()` 함수 등에 의해 이동하게 되었을 때, 지도를 바라보고 있는 카메라가 이동하는 `Poi`를 이동하도록 하는 기능입니다.
한 번에 하나의 `Poi`만 추적을 할 수 있으며, 다른 `Poi`를 추적하려면 `stop` 함수를 호출하여 추적을 멈춘 후 다른 `Poi`를 설정해주시면 됩니다.

```dart
// Label Controller를 이용하여 추적시킬 Poi를 하나 만든 다음, Tracking Controller에 추적할 Poi를 설정합니다.
final poi = await controller.labelLayer.addPoi(...);
controller.tracking.poi = poi;

// start 함수를 이용하여 Poi를 추적할 수 있습니다. 
// 반대로 멈추고 싶다면 stop 함수를 이용하시면 됩니다.
await controller.tracking.start();
```

## 5. Detect event on map.
지도에서 발생한 이벤트는 대부분 `KakaoMap` 위젯 객체에 전달되며 함수 이벤트는 각 인수로 호출됩니다.
각 인수별 이벤트 용도는 [KakaoMap Widget API Reference](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMap-class.html)를 확인해주세요.

예를 들어 `onCameraMoveEnd` 인수에 함수를 제공하여 카메라가 이동을 마칠 때 메시지를 호출받을 수 있습니다.
```dart
KakaoMap(
  option: const KakaoMapOption(...),
  onMapReady: ... // 지도를 불러오면 함수가 호출됩니다.
  onPoiClick: (LabelController labelController, Poi poi) {
    print("Poi (${poi.id})가 눌렸습니다!");
  },
  onCameraMoveEnd: (CameraPosition position, GestureType gestureType) {
    print("카메라가 위도 ${position.position.latitude}도, 경도 ${position.position.longitude}도로 이동하였습니다.");
  },
);
```

## 6. Sample Project
아래의 [샘플 프로젝트](https://github.com/gunyu1019/flutter_kakao_maps_sample)을 확인하여 카카오맵을 Flutter에 구현한 애플리케이션을 확인해보세요!

## 7. Web 지원 범위
<img src="https://github.com/user-attachments/assets/4f20ddb0-e678-4cbe-b6ca-39be0f9e6b18" width="70%" /><br/>
Kakao Map SDK는 Web 플랫폼을 지원합니다. v1.3.0부터 `PolylineText`와 `DimScreen`도 동일한 Dart API로 사용할 수 있습니다.<br/>
Web 구현은 Kakao Maps JavaScript SDK가 제공하는 기능 안에서 네이티브 API의 구조를 맞춥니다.

네이티브에 있는 기능과 달리 아래에 서술한 기능은 웹 환경에서 다르게 작동하거나 지원하지 않습니다.

* **카메라 회전, 틸트**: Kakao Map Web SDK는 카메라 회전 또는 틸트 기능을 제공하지 않습니다.<br/>
  따라서 카메라 회전 각도, 틸트 각도를 주어져도 무시됩니다.
* **LOD(Level Of Detail) 기능**: 웹 환경에서 LOD 기능은 적용되지 않은 상태로 작동합니다. <br/>
  예를 들어 웹 환경에서 `LOD Poi`는 LOD가 적용되지 않은 `Poi`와 동일하게 작동합니다. 
* **레이어와 LOD 설정**: 일부 레이어 경쟁·정렬 설정은 네이티브와 동일하게 적용되지 않으며, LodPoi는 일반 Poi처럼 동작합니다.
* **Route Pattern**: 웹 환경에서 경로에 패턴을 찍는 기능은 지원하지 않습니다.<br/>
  `RouteStyle` 객체에 `pattern`가 입력되면 카카오맵 웹 환경과 동일한 점선으로 대체됩니다.
  <details>
  <summary>
  웹 환경 내 경로에 패턴이 적용된 이미지
  </summary>
    <img src="https://github.com/user-attachments/assets/b604dcd2-c4e2-4334-b519-140409af543e" width="80%" />
  </details>
* 웹 환경에서 `canShowPosition` 함수의 `zoomLevel` 매개변수는 작동하지 않습니다.<br/>
  사용자에게 보여주는 시점에서 주어진 배열의 좌표만 보여지는 여부를 반환합니다.
* 웹 환경에서 `buildingHeightScale` 개체는 항상 `0.0`이며 수정할 수 없습니다.
* 웹 환경에서 Poi와 다른 도형 간 위치를 공유하는 `Poi.addShareTransfromWithShape`, `Poi.removeShareTransfromWithShape`는 지원하지 않습니다.

플랫폼별 세부 차이와 검증 결과는 [플랫폼 지원 범위](https://gunyu1019.gitbook.io/kakao-map-sdk/getting_started/platform-support)에서 확인하세요.

## 8. Documentation

* [GitBook 사용 문서](https://gunyu1019.gitbook.io/kakao-map-sdk/)
* [API Reference](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/)
* [변경 이력](CHANGELOG.md)
* [샘플 프로젝트](https://github.com/gunyu1019/flutter_kakao_maps_sample)

## 9. Collaboration / Report Issue

기능 개선이나 버그 수정은 Pull Request로 제안할 수 있습니다. 변경 사항에는 적용 대상 플랫폼과 검증 방법을 함께 작성하고, 가능하면 관련 테스트를 포함해 주세요.

패키지 사용 중 문제가 발생했다면 [Issue tracker](https://github.com/gunyu1019/flutter_kakao_maps/issues)에 양식을 준수하여 등록해주십시요.

보안상 민감한 정보는 공개 이슈와 로그에 포함하지 말고 [gunyu1019@yhs.kr](mailto:gunyu1019@yhs.kr)로 보내주세요. 
앱 키처럼 재발급 가능한 비밀값은 이메일에서도 원문을 보내기보다 필요한 부분만 마스킹하여 전달해 주세요.
