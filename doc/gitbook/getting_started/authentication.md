# 애플리케이션 인증하기

카카오 지도를 사용하려면 [Kakao Developers](https://developers.kakao.com/)에서 앱을 만들고 플랫폼 정보를 등록해야 합니다. Android와 iOS는 네이티브 앱 키를 사용하고, Web은 JavaScript 키를 사용합니다.

## 1. 카카오 앱 등록

1. Kakao Developers에 로그인하고 애플리케이션을 생성합니다.
2. 제품 설정에서 카카오맵 사용을 활성화합니다.
3. 앱 설정의 플랫폼 메뉴에서 Android 패키지명, iOS 번들 ID, Web 사이트 도메인을 등록합니다.
4. 앱 키 화면에서 네이티브 앱 키와 JavaScript 키를 확인합니다.

| 키 | 사용 플랫폼 |
| --- | --- |
| 네이티브 앱 키 | Android, iOS |
| JavaScript 키 | Web |

> 앱 키를 저장소에 커밋하지 마세요. 네이티브 앱 키는 `--dart-define`, `flutter_dotenv` 또는 배포 환경의 secret으로 전달하고, Web JavaScript 키는 허용 도메인을 정확히 제한하여 사용하세요.

## 2. Android·iOS 네이티브 앱 키

`runApp()`을 호출하기 전에 SDK를 초기화합니다.

```dart
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const appKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  await KakaoMapSdk.instance.initialize(appKey);

  runApp(const MyApp());
}
```

실행할 때 값을 전달할 수 있습니다.

```bash
flutter run --dart-define=KAKAO_NATIVE_APP_KEY=YOUR_NATIVE_APP_KEY
```

`isInitialize()`로 초기화 여부를 확인할 수 있습니다.

```dart
final initialized = await KakaoMapSdk.instance.isInitialize();
```

### 2-1. 패키지명·번들 ID

Kakao Developers에 등록한 값과 실제 앱의 식별자가 정확히 같아야 합니다.

* Android: 일반적으로 `android/app/build.gradle` 또는 `build.gradle.kts`의 `applicationId`
* iOS: Xcode Runner target의 `PRODUCT_BUNDLE_IDENTIFIER`

Debug, staging, production에서 식별자를 다르게 사용한다면 각 플랫폼 값을 모두 등록합니다.

### 2-2. Android 키 해시

Android는 패키지명과 함께 키 해시를 검증합니다. 현재 빌드에 사용되는 키 해시는 다음 API로 확인할 수 있습니다.

```dart
final keyHash = await KakaoMapSdk.instance.hashKey();
debugPrint('Kakao key hash: $keyHash');
```

`hashKey()`는 Android에서만 문자열을 반환하고 iOS와 Web에서는 `null`을 반환합니다. 개발자별 debug keystore와 스토어 배포용 signing key가 다르다면 각각의 키 해시를 등록해야 합니다.

## 3. Web JavaScript 키 등록

Kakao Developers에 개발·운영 도메인을 등록한 후 `web/index.html`의 `<head>` 안에 JavaScript SDK를 추가합니다.

```html
<head>
  <!-- 다른 설정 -->
  <script
    type="text/javascript"
    src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_JAVASCRIPT_KEY">
  </script>
</head>
```

Flutter bootstrap보다 먼저 SDK가 로드되어야 합니다. 로컬 개발 주소를 사용한다면 실제 접속 주소와 포트가 Kakao Developers의 허용 도메인 정책에 맞는지도 확인하세요.

> 공통 `main()`에서 `initialize()`를 호출해도 Web 인증 자체는 JavaScript SDK 스크립트와 JavaScript 키로 처리됩니다.

## 4. 인증 오류 처리

`KakaoMap.onMapError`에서 인증 오류와 지도 런타임 오류를 함께 처리할 수 있습니다.

```dart
KakaoMap(
  option: const KakaoMapOption(),
  onMapReady: (controller) {
    debugPrint('지도 준비 완료');
  },
  onMapError: (error) {
    if (error is KakaoAuthError) {
      debugPrint('인증 실패: ${error.code} / ${error.message}');
      return;
    }
    debugPrint('지도 오류: $error');
  },
);
```

| Code | 의미 | 우선 확인할 항목 |
| ---: | --- | --- |
| 400 | 요청 또는 필수 정보 오류 | 키 값, 플랫폼 설정 |
| 401 | 유효한 인증 정보 없음 | 네이티브·JavaScript 키 종류 |
| 403 | 권한 없음 | 카카오맵 활성화, 패키지명·번들 ID·도메인 |
| 429 | 사용량 또는 요청 한도 초과 | 쿼터와 호출량 |
| 499 | 네트워크 통신 실패 | 인터넷 연결, 방화벽, 브라우저 차단 |

Web에서 `kakao` 객체가 없다는 오류가 보이면 키 자체뿐 아니라 브라우저 확장 프로그램, Content Security Policy, 광고 차단 규칙이 `dapi.kakao.com` 요청을 막고 있지 않은지 확인하세요.
