# 패키지 설치하기

플랫폼 요구사항을 확인한 다음 Flutter 프로젝트에 `kakao_map_sdk`를 추가합니다.

## 1. 패키지 추가

```bash
flutter pub add kakao_map_sdk
```

명령을 실행하면 pub.dev에 배포된 안정 버전이 `pubspec.yaml`에 추가되고 의존성을 내려받습니다.

개발 브랜치를 직접 사용하려면 Git dependency를 지정할 수 있습니다.

```yaml
dependencies:
  kakao_map_sdk:
    git:
      url: https://github.com/gunyu1019/flutter_kakao_maps.git
      ref: develop
```

> 개발 브랜치는 배포 버전과 API 또는 동작이 다를 수 있습니다. 운영 앱은 pub.dev의 안정 버전을 고정하여 사용하는 것을 권장합니다.

## 2. Android 설정

### 2-1. 권한

`android/app/src/main/AndroidManifest.xml`의 `<manifest>` 아래에 인터넷 권한을 추가합니다. 현재 위치를 사용하는 앱이라면 위치 권한도 함께 선언합니다.

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

지도 타일을 표시하는 데 필수인 것은 인터넷 권한입니다. 위치 권한 선언만으로 런타임 권한이 허용되지는 않으므로, 현재 위치 기능을 구현한다면 앱에서 별도로 권한을 요청해야 합니다.

### 2-2. 난독화·최적화

Release 빌드에서 R8 또는 Proguard를 사용한다면 `android/app/proguard-rules.pro`에 다음 규칙을 추가합니다.

```properties
-keep class com.kakao.vectormap.** { *; }
-keep interface com.kakao.vectormap.**
```

### 2-3. 빌드 환경

패키지는 Android `minSdk 23`, `compileSdk 34`를 기준으로 하며 Kakao Maps Android SDK `2.13.5`를 사용합니다. 앱의 `minSdk`가 23보다 낮다면 23 이상으로 올려야 합니다.

## 3. iOS 설정

iOS deployment target을 13 이상으로 설정합니다.

```ruby
platform :ios, '13.0'
```

패키지는 CocoaPods와 Swift Package Manager 구성을 모두 제공합니다. Flutter 프로젝트가 선택한 iOS dependency manager에 따라 네이티브 Kakao Maps SDK가 연결됩니다.

설정 변경 후 의존성 문제가 발생하면 프로젝트 루트에서 다음 순서로 다시 받아보세요.

```bash
flutter clean
flutter pub get
```

## 4. Web 설정

Web에서는 패키지 설치 외에 Kakao Maps JavaScript SDK 스크립트가 필요합니다. 자세한 키 설정과 도메인 등록은 [애플리케이션 인증하기](authentication.md#3-web-javascript-키-등록)를 참고하세요.

## 5. 설치 확인

다음 import가 분석 오류 없이 인식되는지 확인합니다.

```dart
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
```

그다음 [애플리케이션 인증하기](authentication.md)와 [지도 그리기](configuration_map.md)를 순서대로 진행하세요.
