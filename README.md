# kakao_map_sdk
![Pub Version](https://img.shields.io/pub/v/kakao_map_sdk)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/kakao_map_sdk)
![Pub Points](https://img.shields.io/pub/points/kakao_map_sdk)
![Pub Popularity](https://img.shields.io/pub/popularity/kakao_map_sdk)

네이티브 기반의 [카카오맵](https://map.kakao.com/)을 구동할 수 있는 Flutter 플러그인입니다.

| Android                | iOS             | Web(Experimental)      |
|------------------------|-----------------| ---------------------- |
| `SDK 6.0(API 23)` 이상 | `iOS 13` 이상    | [Flutter Web과 동일 환경](https://docs.flutter.dev/reference/supported-platforms) |
| `armeabi-v7a`, `arm64-v8a` 아키텍쳐 지원<br/>(`x86`, `x64` 아키텍쳐 미호환) |        |
| `OpenGL ES 2.0` 이상 |         |          |
| 인터넷 권한 필요   |         |             |

## 1. Getting Started
Flutter 환경에서 카카오지도를 이용하기 위해서는 [카카오 개발자 사이트](https://developers.kakao.com/)에서 앱 등록을 합니다.<br/>
앱 등록을 마치면, **네이티브 앱 키(App Key)** 를 발급받을 수 있습니다.

앱 키는 아래와 같이 `KakaoMapSdk.instance.initialize` 함수를 호출하여 인증하실 수 있습니다.
```dart
import 'package:kakao_map_sdk/kakao_map.dart';

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
2. 애플리케이셥을 배포하는 경우, Kakao Map SDK는 코드 축소, 난독화, 최적화 대상에서 제외해야 합니다.<br/>
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
지도를 담고 있는 위젯(Widget)은 아래와 같이 호출하여 사용하실 수 있습니다.
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

## 3. Write Overlay(Grapic Element) to Map
Kakao Map SDK는 사용자에게 표현하기 위한 다양한 그래픽 요소(오버레이 기능)를 제공하고 있습니다.<br/>
다양한 그래픽 요소는 `KakaoMapController`를 통해 제어하실 수 있습니다.

### 3-1. Poi (Label)
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

### 3-2. Shape
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

### 3-3. Route
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

## 4. Sample Project
아래의 [샘플 프로젝트](https://github.com/gunyu1019/flutter_kakao_maps_sample)을 확인하여 카카오맵을 Flutter에 구현한 애플리케이션을 확인해보세요!

## 5. (Expermential) Web
<img src="https://github.com/user-attachments/assets/4f20ddb0-e678-4cbe-b6ca-39be0f9e6b18" width="70%" /><br/>
Kakao Map SDK는 Web 플랫폼을 지원합니다.<br/>
본 플러그인은 네이티브를 중심으로 개발되었기 때문에 웹 SDK도 네이티브 환경에 알맞게 포팅 작업을 진행하였습니다.

네이티브에 있는 기능과 달리 아래에 서술한 기능은 웹 환경에서 다르게 작동하거나 지원하지 않습니다.
* **카메라 회전, 틸트**: Kakao Map Web SDK는 카메라 회전 또는 틸트 기능을 제공하지 않습니다.<br/>
  따라서 카메라 회전 각도, 틸트 각도를 주어져도 무시됩니다.
* **LOD(Level Of Detail) 기능**: 웹 환경에서 LOD 기능은 적용되지 않은 상태로 작동합니다. <br/>
  예를 들어 웹 환경에서 `LOD Poi`는 LOD가 적용되지 않은 `Poi`와 동일하게 작동합니다. 
* 각 **컨트롤러(Layer) 기능**: 웹 환경에서 Layer에 적용한 설정은 적용되지 않습니다.
* **Polyline Text**: 웹 환경에서 휘어진 텍스트 오버레이는 지원하지 않습니다.
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

기재한 기능 외에도 일부 기능은 지원하지 않을 수도 있습니다.<br/>
네이티브 환경을 중점으로 개발된 플러그인이므로 양해부탁드립니다.

웹 환경 내 사용방법은 첫 번째 섹션(Getting Started) 부분을 확인해주세요.

## 6. Collaboration / Reqort Issue 
Kakao Map SDK 플러그인에 기여는 항상 환영합니다. <br/>
기능 개선, 버그 해결 등의 작업하신 내용은 `Pull Reuqest(PR)` 해주시면, 검증 후 병합 해드리겠습니다.

질문, 버그 제보도 언제든지 환영합니다.<br/> 이용 중에 문제를 겪으셨다면 `Issue`를 열어주세요. 빠른 시일 내에 도움드리도록 하겠습니다
