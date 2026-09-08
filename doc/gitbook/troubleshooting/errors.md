# 오류와 예외 처리

오류는 지도 생성 콜백으로 전달되는 유형과 Dart에서 오버레이를 등록할 때 throw되는 유형으로 나뉩니다.

## 1. 지도 오류

```dart
KakaoMap(
  onMapReady: (controller) {},
  onMapError: (error) {
    switch (error) {
      case KakaoAuthError auth:
        debugPrint('인증 오류: ${auth.code} / ${auth.message}');
        break;
      case KakaoMapError map:
        debugPrint('지도 오류: ${map.className} / ${map.message}');
        break;
      default:
        debugPrint('알 수 없는 오류: $error');
        break;
    }
  },
);
```

### KakaoAuthError

| Code | 의미 | 확인 항목 |
| ---: | --- | --- |
| 400 | 요청 정보 오류 | 앱 키와 플랫폼 설정 |
| 401 | 인증 정보 없음 또는 잘못된 키 | 키 종류와 값 |
| 403 | 권한 없음 | 카카오맵 활성화, 패키지명·번들 ID·도메인·키 해시 |
| 429 | 할당량 초과 | 쿼터와 요청량 |
| 499 | 네트워크 통신 실패 | 인터넷·방화벽·브라우저 차단 |

### KakaoMapError

`className`은 native에서 발생한 오류 유형, `message`는 선택적 상세 메시지입니다. 인증이 성공한 뒤 지도 View 또는 플랫폼 SDK 처리에서 실패한 경우에 사용됩니다.

## 2. 오버레이 ID 중복

```dart
try {
  await controller.labelLayer.addPoi(
    position,
    id: 'office',
    style: style,
  );
} on DuplicatedOverlayException catch (error) {
  debugPrint('이미 등록된 ID: ${error.id}');
}
```

중복 기준은 관련 컨트롤러의 저장소입니다. 예를 들어 같은 LabelLayer의 Poi끼리, 같은 RouteLayer의 Route와 MultipleRoute끼리는 ID가 겹치면 안 됩니다.

## 3. 스타일 등록 실패

`OverlayStyleRegistrationFailedError`는 Poi·Shape·Route 스타일이 플랫폼 SDK에 등록되지 않았을 때 발생합니다.

```dart
try {
  await controller.addPoiStyle(style);
} on OverlayStyleRegistrationFailedError catch (error) {
  debugPrint('스타일 ID: ${error.id}');
  debugPrint('오버레이 유형: ${error.type}');
}
```

주요 원인:

* 이미 등록된 스타일 인스턴스를 `add...Style()`로 다시 등록
* 중복 ID
* 유효하지 않은 이미지 또는 스타일 값
* 아직 준비되지 않았거나 재생성된 native 지도에 이전 스타일 객체 사용

## 4. 오버레이 등록 실패

`OverlayRegistrationFailedError`는 스타일 등록 후 실제 Poi, Shape, Route 등을 만들지 못했을 때 발생합니다.

```dart
try {
  await controller.routeLayer.addRoute(points, style);
} on OverlayRegistrationFailedError catch (error) {
  debugPrint('요소 ID: ${error.id}');
  debugPrint('오버레이 유형: ${error.type}');
}
```

좌표 목록이 비었는지, 스타일이 현재 지도 컨트롤러에 속하는지, ID가 중복되지 않는지 확인하세요.

## 5. 공통 처리 함수

```dart
Future<T?> guardOverlay<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DuplicatedOverlayException catch (error, stackTrace) {
    debugPrint('중복: $error\n$stackTrace');
  } on OverlayStyleRegistrationFailedError catch (error, stackTrace) {
    debugPrint('스타일 실패: $error\n$stackTrace');
  } on OverlayRegistrationFailedError catch (error, stackTrace) {
    debugPrint('등록 실패: $error\n$stackTrace');
  }
  return null;
}
```

## 6. Web SDK 로드 오류

Web에서 JavaScript SDK가 로드되지 않으면 Dart의 `onMapError`보다 먼저 브라우저 JavaScript 오류가 발생할 수 있습니다.

1. `web/index.html`에 `dapi.kakao.com/v2/maps/sdk.js`가 Flutter bootstrap보다 먼저 있는지 확인합니다.
2. JavaScript 키와 등록 도메인을 확인합니다.
3. 개발자 도구 Network 탭에서 SDK 요청이 200인지 확인합니다.
4. 광고 차단·보안 확장, CSP, 사내 방화벽이 요청을 차단하지 않는지 확인합니다.
5. 브라우저 콘솔에서 `typeof kakao`가 `object`인지 확인합니다.

## 7. 오류 로그에 남길 정보

Issue를 재현할 때 다음 정보를 함께 남기면 원인 분석이 빨라집니다.

* `kakao_map_sdk` 버전
* Flutter·Dart 버전
* 플랫폼과 OS 버전, Android ABI
* debug/profile/release 모드
* 오류 객체의 `toString()`과 stack trace
* `onMapReady` 호출 여부
* 최소 재현 코드와 발생 순서
