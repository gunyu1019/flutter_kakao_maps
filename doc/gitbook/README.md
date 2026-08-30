# Kakao Map SDK for Flutter

Kakao Map SDK for Flutter는 Android, iOS, Web 애플리케이션에서 카카오 지도를 사용할 수 있도록 구성한 Flutter 플러그인입니다. 하나의 Dart API로 지도 카메라, 이벤트, Poi, 도형, 경로, DimScreen을 제어할 수 있습니다.

현재 문서는 패키지 `1.3.0`과 저장소의 `develop` 브랜치 구현을 기준으로 작성되어 있습니다.

> 이 패키지는 Kakao가 공식 배포하는 Flutter SDK가 아닌 커뮤니티 플러그인입니다. 플랫폼별 기반 SDK 정책과 사용량·앱 등록 조건은 Kakao Developers의 안내도 함께 확인하세요.

## 제공 기능

| 분류 | 주요 기능 |
| --- | --- |
| 지도 | 일반 지도·스카이뷰, 지도 오버레이, 제스처, 화면 좌표 변환 |
| 카메라 | 중심·줌·회전·기울기 이동, 애니메이션, 좌표 맞춤, 화면 경계 조회 |
| Label | Poi, LodPoi, Badge, PolylineText, 카메라 추적 |
| Shape | Polyline, Polygon, 원·사각형 상대 도형, hole, 줌 레벨별 스타일 |
| Route | Route, MultipleRoute, 구간별 스타일, 곡선, 패턴 |
| 강조 | DimScreen 색상·범위 설정, Polygon 기반 highlight |
| 운영 | 지도 상태주기, 캐시 정리, Android 백그라운드 복구 옵션 |

## 플랫폼 구현 방식

Android와 iOS에서는 각 플랫폼의 Kakao Maps SDK를 Flutter Platform View로 표시합니다. Web에서는 Kakao Maps JavaScript SDK를 Flutter Web 플러그인으로 감싸 동일한 Dart 모델과 컨트롤러를 사용합니다.

```text
KakaoMap 위젯
  └─ KakaoMapController
      ├─ 지도·카메라·GUI 제어
      ├─ LabelLayer   → Poi, LodPoi, PolylineText
      ├─ ShapeLayer   → Polyline, Polygon
      ├─ RouteLayer   → Route, MultipleRoute
      ├─ DimScreen    → 지도 dim + highlight
      └─ Tracking     → Poi 카메라 추적
```

플랫폼별 최소 요구사항과 Web의 동작 차이는 [플랫폼 지원 범위](getting_started/platform-support.md)에서 먼저 확인하세요.

## 빠른 시작

```bash
flutter pub add kakao_map_sdk
```

```dart
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapSdk.instance.initialize('NATIVE_APP_KEY');
  runApp(const MaterialApp(home: MapPage()));
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KakaoMap(
        option: const KakaoMapOption(
          position: LatLng(37.394776, 127.11116),
          zoomLevel: 16,
        ),
        onMapReady: (controller) {
          debugPrint('카카오 지도를 사용할 수 있습니다.');
        },
        onMapError: (error) {
          debugPrint('지도 오류: $error');
        },
      ),
    );
  }
}
```

> Web은 `KakaoMapSdk.instance.initialize()` 대신 `web/index.html`에서 JavaScript 키로 SDK를 불러옵니다. 플랫폼별 인증 절차는 [애플리케이션 인증하기](getting_started/authentication.md)를 참고하세요.

## 문서를 읽는 순서

1. [패키지 설치하기](getting_started/installation.md)에서 프로젝트 요구사항을 맞춥니다.
2. [애플리케이션 인증하기](getting_started/authentication.md)에서 플랫폼을 등록하고 앱 키를 설정합니다.
3. [지도 그리기](getting_started/configuration_map.md)에서 첫 `KakaoMap`을 구성합니다.
4. [카메라 조작하기](map_element/camera.md)와 [지도 이벤트 수신하기](map_element/events.md)로 상호작용을 연결합니다.
5. 필요한 [오버레이와 레이어](overlay/architecture.md)를 선택하여 지도 요소를 추가합니다.

## 관련 링크

* [pub.dev 패키지](https://pub.dev/packages/kakao_map_sdk)
* [API reference](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/)
* [GitHub 저장소](https://github.com/gunyu1019/flutter_kakao_maps)
* [Issue tracker](https://github.com/gunyu1019/flutter_kakao_maps/issues)
