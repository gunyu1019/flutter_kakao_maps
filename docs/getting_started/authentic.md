# 애플리케이션 인증하기

카카오 지도를 애플리케이션에서 사용하기 위해서는 카카오 개발자 인증이 필요합니다. \
개발자 인증은 [Kakao Developers](https://developers.kakao.com/)에서 발급 받은 토큰을 이용하여 인증을 할 수 있습니다.

## 1. 카카오 앱 등록&#x20;

1. [Kakao Developers](https://developers.kakao.com/) 사이트에 접속하고 카카오 계정으로 로그인합니다.
2. 상단 바 \[앱] ➡ \[앱 생성] 버튼을 클릭하여 애플리케이션을 등록합니다.
3. 좌측 메뉴에서 \[제품설정] ➡ \[카카오맵] 순서대로 이동하여 카카오맵을 활성화 합니다.
4. 좌측 메뉴에서 \[앱 설정] ➡ \[앱] ➡ \[일반] 순서대로 이동합니다.
5. \[앱 키]란에 네이티브 앱 키를 미리 복사해둡니다!

> **네이티브 앱 키**는 Android, iOS 환경에서 카카오 지도를 인증하는 용도로 사용합니다.\
> **JavaScript 키**는 Web 환경에서 카카오 지도를 인증하는 용도로 사용합니다.

> **네이티브 앱** 키는 애플리케이션의 보안 위해 외부에 노출되지 않도록 하는 것을 권장합니다.
>
> 따라서 소스 코드에 직접 입력하는 것이 아닌 `flutter_dotenv` 등의 패키지를 적용하여 인증을 위한 토큰을 별도의 파일에 저장하는 것을 권장합니다.

## 2. (Android, iOS) 네이티브 앱 키 추가

Android, iOS 플랫폼에서는 아래의 소스코드를 통해 앱 키를 이용하여 인증을 진행합니다.

```dart
void main() async {
  // main() 함수를 비동기로 실행시키기 위해서는 WidgetsFlutterBinding.ensureInitialized(); 함수를 호출해야 합니다.
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapSdk.instance.initialize('KAKAO_API_KEY');
  runApp(const MyApp());
}
```

Android, iOS 플랫폼에서 인증은 `KakaoMapSdk.instance.initialize()` 함수 호출을 통해 이뤄집니다.

### 2-1. 패키지 명 / 번들ID 등록

Android, iOS에서 애플리케이션에서 카카오 지도를 이용하기 위해 패키지 명, 번들ID 등록이 필요합니다.

1. 좌측 메뉴에서 \[앱 설정] ➡ \[앱] ➡ \[일반] 순서대로 이동합니다.
2. \[플랫폼]란에 Android와 iOS 오른쪽 \[수정] 버튼을 클릭하여 패키지 명과 번들ID를 등록합니다.

> Kakao Developers에 사전에 등록한 패키지명, 번들ID가 애플리케이션의 패키지 명, 번들ID와 다를\
> 경우 애플리케이션 인증에 실패할 수 있습니다!

### 2-2. 안드로이드 키 해시 등록

Android 플랫폼에서 카카오 지도를 이용하려면 키 해시 인증이 추가로 필요합니다. 키 해시란 인증서의 지문 값(Certificate fingerprints)를 해시(Hash)한 값으로 악성 애플리케이션의 판별 용도로 사용됩니다.

키 해시는 디버그 키 해시(Debug Key Hash)와 릴리즈 키 해시(Release Key Hash)의 두 종류가 있습니다.

* 디버그 키 해시: 안드로이드 스튜디오에서 개발 환경에 따라 자동으로 생성하는 디버그 인증서에서 해시한 값
* 릴리즈 키 해시: 앱 스토어에 애플리케이션을 배포하기 위해 생성한 릴리즈 인증서에서 해시한 값

자세한 내용은 키 해시에 관한 자세한 내용은 [Kakao Developers 공식 문서](https://developers.kakao.com/docs/latest/ko/android/getting-started#before-you-begin-add-key-hash)를 참고해주세요.



Kakao Map SDK에서는 디버그, 릴리즈 키 해시를 제공하며, `KakaoMapSdk.instance.hashKey()` 함수를 \
호출하여 키 해시 값을 문자열로 확인할 수 있습니다.

```dart
final hashKey = await KakaoMapSdk.instance.hashKey();
```

키 해시는 안드로이드 플랫폼에서만 사용되며 다른 플랫폼에서 함수를 호출하게 되면, `null`을 반환하게 됩니다.

> 모든 개발 환경의 디버그 키 해시과 릴리즈 키 해시를 등록해야 카카오 지도를 이용하실 수 있으며, 키 해시가 등록되지 않은 애플리케이션에서 카카오 지도 API를 호출할 수 없습니다. 여러 명의 개발자가 애플리케이션 개발에 참여하고 있다면 각 개발자의 개발 환경에 따라 디버그 키스토어(Keystore)가 각자 다르므로 개발 환경에 맞게 디버그 키 해시를 등록해주셔야 합니다.

## 3. (Web) JavaScript 키 등록

Web 환경에는 다음의 소스 코드를 `index.html`에 추가하여 애플리케이션 인증을 하실 수 있습니다.

아래의 `script` 코드를 `head` 태그에 넣어주세요.\
`JavaScript 키`에는 앱 등록 과정에서 발급받은 Javascript 키를 입력하시면 됩니다.

```html
<script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=JavaScript 키"></script>
```
