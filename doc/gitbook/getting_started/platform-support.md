# 플랫폼 지원 범위

Kakao Map SDK for Flutter `1.3.0`은 Android, iOS, Web을 지원합니다. Dart API는 가능한 범위에서 동일하게 제공되지만, 기반 Kakao Maps SDK의 기능 차이 때문에 일부 동작은 플랫폼마다 다릅니다.

## 1. 최소 요구사항

| 플랫폼 | 요구사항 |
| --- | --- |
| Android | API 23(Android 6.0) 이상, OpenGL ES 2.0 이상 |
| Android ABI | `armeabi-v7a`, `arm64-v8a` 지원. `x86`, `x86_64`는 지원하지 않음 |
| iOS | iOS 13 이상 |
| Web | Flutter Web 지원 브라우저, Kakao Maps JavaScript SDK를 불러올 수 있는 네트워크 환경 |
| Dart / Flutter | Dart `^3.5.3`, Flutter `>=3.3.0` |

> Android 에뮬레이터를 사용할 때는 ARM 이미지를 선택하세요. x86 계열 시스템 이미지는 네이티브 Kakao Maps SDK ABI와 호환되지 않습니다.

## 2. 기능 비교

| 기능 | Android | iOS | Web |
| --- | :---: | :---: | :---: |
| 지도·카메라·좌표 변환 | 지원 | 지원 | 지원 |
| 카메라 회전·기울기 | 지원 | 지원 | 미지원 |
| Poi | 지원 | 지원 | 지원 |
| LodPoi의 LOD 최적화 | 지원 | 지원 | 일반 Poi처럼 동작 |
| PolylineText | 지원 | 지원 | `1.3.0`부터 지원 |
| Polyline·Polygon | 지원 | 지원 | 지원 |
| Route·MultipleRoute | 지원 | 지원 | 지원 |
| Route 이미지 패턴 | 지원 | 지원 | 점선 표현으로 대체 |
| DimScreen | 지원 | 지원 | `1.3.0`부터 지원 |
| 네이티브 pause·resume | 지원 | 지원 | 대상 아님 |
| 건물 높이 배율 | 지원 | 지원 | 값 `0.0`, 변경 불가 |

## 3. Web에서 알아둘 차이

Web 구현은 Kakao Maps JavaScript SDK가 제공하는 기능 안에서 네이티브 API의 구조를 맞춥니다.

* `CameraUpdate.rotate()`와 `CameraUpdate.tilt()`에 전달한 값은 적용되지 않습니다.
* LodLabelLayer의 LOD 계산과 레이어의 일부 경쟁·정렬 설정은 네이티브와 동일하게 적용되지 않습니다.
* `canShowPosition()`은 전달한 `zoomLevel`을 사용하지 않고 현재 화면에서 좌표가 보이는지 판단합니다.
* Route의 이미지 패턴은 JavaScript SDK의 표현 제약에 따라 점선으로 대체됩니다.
* Poi와 Shape 사이의 transform 공유는 지원하지 않습니다.
* 브라우저 확장 프로그램이나 보안 정책이 `dapi.kakao.com` 요청을 차단하면 JavaScript SDK가 로드되지 않습니다.

## 4. 1.3.0에서 확인된 플랫폼 결과

DimScreen의 MapPoint highlight는 동일한 테스트 시나리오로 Android, iOS, Web에서 검증되었습니다. Web 이미지는 `127.0.0.1:8080`에서 Profile 모드로 실행한 최종 통과 artifact입니다.

<table>
  <thead>
    <tr><th>Android</th><th>iOS</th><th>Web · Profile · 8080</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><img src="../.gitbook/assets/dimscreen-map-point-android.png" alt="Android DimScreen MapPoint 결과" /></td>
      <td><img src="../.gitbook/assets/dimscreen-map-point-ios.png" alt="iOS DimScreen MapPoint 결과" /></td>
      <td><img src="../.gitbook/assets/dimscreen-map-point-web-profile-8080.jpg" alt="Web Profile 8080 DimScreen MapPoint 결과" /></td>
    </tr>
  </tbody>
</table>

> 테스트 화면의 `S01` 카드와 하단 버튼은 플랫폼 비교용 harness UI입니다. 실제 앱에서는 DimScreen과 highlight만 표시됩니다.
