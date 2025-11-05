# 패키지 설치하기

Kakao Map SDK는 안드로이드, iOS, 웹 환경을 지원합니다!

패키지를 사용하기 전 플랫폼 별 요구사항을 확인해주세요!

* Android
  * API 23 (Android 6.0) 이상
  * `armeabi-v7a`, `arm64-v8a` 아키텍쳐 지원 <sub>(</sub><sub>`x86`</sub><sub>,</sub> <sub></sub><sub>`x64`</sub> <sub></sub><sub>아키텍쳐는 지원하지 않습니다.)</sub>
  * [OpenGL ES 2.0](https://developer.android.com/develop/ui/views/graphics/opengl/about-opengl?hl=ko) 이상
* iOS
  * iOS 13 이상
* Web
  * [Flutter Web과 동일한 환경](https://docs.flutter.dev/reference/supported-platforms)

## 1. 패키지 다운로드

아래의 명령어를 이용하여 패키지를 설치하실 수 있습니다.

```bash
 $ flutter pub add kakao_map_sdk
```

또는, `pubspec.yml` 에 종속성을 설정하여 패키지를 다운로드 할 수 있습니다.

```yaml
dependencies:
  kakao_map_sdk: ^1.2.0
```

`pubspec.yml`를 수정하시고, `flutter pub get` 명령어를 이용하여 종속성을 갱신해주세요.



만약 정식으로 출시되지 않은 개발 버전을 설치하시고 싶다면 `pubspec.yml`를 다음과 같이 수정해주세요.

```yaml
dependencies:
  kakao_map_sdk:
    git: https://github.com/gunyu1019/flutter_kakao_maps.git
```

## 2. 안드로이드 환경 설정

iOS와 Web 플랫폼에서 지도를 사용하기 위해서 필요한 추가 설정은 없습니다.\
다만 안드로이드 환경에서 일부 설정이 필요합니다.

*   `AndroidManifest.xml`에 다음의 코드를 추가하여 인터넷과 위치 정보를 불러올 수 있도록 합니다.

    ```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ```
*   프로가드(Proguard) 이용하여 압축, 난독화하여 배포를 하는 경우, 패키지의 난독화, 압축은 제외해야 합니다.&#x20;

    ```properties
    -keep class com.kakao.vectormap.** { *; }
    -keep interface com.kakao.vectormap.**
    ```
