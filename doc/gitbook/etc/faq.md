# 자주 묻는 질문

## 지도가 비어 있거나 검은 화면으로 표시됩니다

먼저 `onMapReady`가 호출되었는지 확인하세요. 호출되지 않았다면 인증·네트워크·플랫폼 View 생성 문제일 가능성이 큽니다.

* Android: 인터넷 권한, ARM ABI, 키 해시, 패키지명 확인
* iOS: iOS 13 이상, 번들 ID, 네이티브 앱 키 확인
* Web: JavaScript SDK script, JavaScript 키, 등록 도메인, 요청 차단 확인

Android에서 background 복귀 후에만 멈춘다면 [상태주기와 Android 복구](../map_element/lifecycle.md)를 참고하세요.

## Android 에뮬레이터에서 native library 오류가 발생합니다

Kakao Maps Android SDK는 이 패키지에서 `armeabi-v7a`, `arm64-v8a`를 지원합니다. `x86` 또는 `x86_64` 시스템 이미지 대신 ARM 이미지를 사용하세요.

## Web에서 kakao is undefined가 발생합니다

`web/index.html`의 JavaScript SDK가 Flutter bootstrap보다 먼저 로드되어야 합니다. Network 탭에서 `dapi.kakao.com` 요청이 차단되었는지 확인하고 광고 차단 확장, CSP와 등록 도메인도 점검하세요.

## Web을 로컬에서 검증하려면 어떻게 실행하나요?

프로젝트 정책에 맞는 포트를 고정하고 Profile 모드로 실행할 수 있습니다.

```bash
flutter run -d web-server \
  --profile \
  --web-hostname 127.0.0.1 \
  --web-port 8080
```

Kakao Developers에 로컬 주소를 허용해야 할 수 있습니다. 문서의 Web DimScreen 이미지는 이 조건의 최종 테스트 artifact를 사용합니다.

## `onMapReady`가 두 번 호출될 수 있나요?

일반적으로 지도 준비 시 한 번 호출됩니다. Android에서 `recreateAndroidMapViewOnResume: true`를 사용하면 background 복귀 시 native MapView 재생성 후 다시 호출됩니다. 이 경우 오버레이를 새 컨트롤러 상태에 맞춰 재구성해야 합니다.

## Android에서 `forceHybridComposition`을 켜야 하나요?

기본값은 `false`이며 우선 기본 구성을 사용하세요. 특정 Platform View 합성 문제가 명확히 재현될 때만 검토합니다. 이 옵션은 성능과 상태 관리 특성에 영향을 줄 수 있습니다.

## 현재 위치를 자동으로 표시하나요?

패키지는 지도와 오버레이 API를 제공하지만 위치 권한 요청과 위치 스트림은 별도 위치 패키지로 구현해야 합니다. 좌표를 얻은 뒤 `moveCamera()`와 Poi로 표시하세요.

## 화면 좌표 변환이 `null`입니다

`toScreenPoint()`와 `fromScreenPoint()`는 지도 View가 준비되고 레이아웃 크기를 가진 뒤 호출해야 합니다. `onMapReady` 직후에도 레이아웃 프레임이 필요하다면 `addPostFrameCallback`에서 호출하세요.

## `getBounds()`가 `null`입니다

전달한 `BuildContext`의 RenderBox가 지도 자체이며 크기를 가지고 있어야 합니다. `GlobalKey`를 `KakaoMap`에 지정하고 `key.currentContext`를 전달하는 방법을 권장합니다.

## 등록한 오버레이가 보이지 않습니다

다음을 확인하세요.

* 좌표가 현재 카메라 범위 안에 있는지
* `visible`이 `true`인지
* 레이어가 숨김 상태인지
* 스타일의 `zoomLevel` 조건을 만족하는지
* 더 높은 z-order의 요소나 DimScreen이 가리고 있지 않은지
* PolylineText 경로가 문구를 표시할 만큼 충분히 긴지

## 같은 ID를 다시 사용하고 싶습니다

기존 요소를 `remove()`하거나 레이어의 remove API로 삭제한 뒤 추가하세요. 등록된 객체를 삭제하지 않고 같은 ID를 사용하면 `DuplicatedOverlayException`이 발생합니다.

## Web에서 회전·기울기 또는 LodPoi가 native와 다릅니다

Web 기반 SDK의 제한입니다. 회전·기울기는 적용되지 않고 LodPoi는 LOD 최적화 없이 일반 Poi와 유사하게 동작합니다. 자세한 표는 [플랫폼 지원 범위](../getting_started/platform-support.md)를 참고하세요.

## Web Route pattern이 이미지와 다릅니다

Web에서는 이미지 반복 패턴을 점선으로 대체합니다. 방향 화살표가 반드시 필요하다면 별도의 Poi 또는 Web 전용 UI를 조합하는 방법을 검토하세요.

## 여러 지도를 한 화면에 표시할 수 있나요?

가능합니다. 각 지도는 별도 컨트롤러를 사용하고, 특히 iOS에서는 `KakaoMapOption.viewName`을 고유하게 지정하세요. 스타일 인스턴스도 지도별로 생성하는 편이 안전합니다.
