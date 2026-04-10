# 휘어지는 글씨 (Polyline Text)

PolylineText는 지정한 경로(좌표 목록)를 따라 텍스트를 곡선 형태로 표시하는 지도 요소입니다.\
도로 이름, 지형지물의 이름 등을 경로에 맞춰 자연스럽게 표시할 때 유용하게 사용할 수 있습니다.

[스크린샷]

> PolylineText는 한 줄의 텍스트만 지원합니다.

## 1. PolylineText 스타일 설정하기

[PolylineTextStyle](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PolylineTextStyle-class.html) 객체를 이용하여 텍스트의 크기, 색상, 외곽선 등을 설정합니다.

```dart
final style = PolylineTextStyle(
  20,           // 텍스트 크기 (픽셀)
  Colors.black, // 텍스트 색상
  strokeSize: 3,
  strokeColor: Colors.white,
);
```

<table><thead><tr><th width="150">Property</th><th>Description</th></tr></thead><tbody><tr><td>size</td><td>텍스트의 크기입니다. 픽셀 단위로 입력합니다.</td></tr><tr><td>color</td><td>텍스트의 색상입니다.</td></tr><tr><td>strokeSize</td><td>텍스트 외곽선의 두께입니다. 픽셀 단위로 입력합니다.</td></tr><tr><td>strokeColor</td><td>텍스트 외곽선의 색상입니다.</td></tr><tr><td>zoomLevel</td><td>이 스타일이 적용되기 시작하는 최소 줌 레벨입니다.</td></tr><tr><td>applyDpScale</td><td>기기 해상도(DP)를 텍스트 크기에 반영할지 여부입니다.</td></tr></tbody></table>

### 1-1. 줌 레벨별 스타일 설정

줌 레벨에 따라 서로 다른 텍스트 스타일을 적용할 수 있습니다.\
[PolylineTextStyle.addStyle()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PolylineTextStyle/addStyle.html) 함수를 사용합니다.

```dart
final style = PolylineTextStyle(12, Colors.grey, zoomLevel: 0);
style.addStyle(14, size: 18, color: Colors.black); // 줌 레벨 14 이상에서 적용
style.addStyle(17, size: 22, color: Colors.black); // 줌 레벨 17 이상에서 적용
```

> 줌 레벨 값은 낮은 값부터 순서대로 입력해야 정상적으로 동작합니다.\
> 좌표 경로가 화면에서 텍스트를 표시하기에 너무 짧으면 텍스트가 자동으로 숨겨집니다.

## 2. PolylineText 추가하기

[LabelController.addPolylineText()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LabelController/addPolylineText.html) 함수를 이용하여 지도에 PolylineText를 추가할 수 있습니다.\
[KakaoMapController.labelLayer](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/labelLayer.html)를 통해 기본 LabelLayer에 접근합니다.

```dart
Future<void> addPolylineTextExample(KakaoMapController controller) async {
  final style = PolylineTextStyle(
    18,
    Colors.black,
    strokeSize: 2,
    strokeColor: Colors.white,
  );

  final polylineText = await controller.labelLayer.addPolylineText(
    '카카오 본사 → 서울시청',
    [
      const LatLng(37.394776, 127.11116),
      const LatLng(37.450, 127.050),
      const LatLng(37.500, 127.000),
      const LatLng(37.540, 126.990),
      const LatLng(37.56664, 126.97822),
    ],
    style: style,
  );
}
```

[addPolylineText()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LabelController/addPolylineText.html) 함수에 입력 가능한 인수는 다음과 같습니다.

<table><thead><tr><th width="150">Parameter</th><th>Description</th></tr></thead><tbody><tr><td>text</td><td>경로를 따라 표시할 텍스트입니다.</td></tr><tr><td>position</td><td>텍스트가 따라갈 경로의 위경도 좌표 목록입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/LatLng-class.html">LatLng</a> 배열로 입력합니다.</td></tr><tr><td>style</td><td>텍스트에 적용할 스타일입니다. <a href="https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PolylineTextStyle-class.html">PolylineTextStyle</a> 객체로 입력합니다.</td></tr><tr><td>id</td><td>PolylineText의 고유 ID입니다. 입력하지 않으면 임의의 고유 ID가 자동으로 생성됩니다.</td></tr><tr><td>visible</td><td>PolylineText의 초기 표시 여부입니다. 기본값은 <code>true</code>입니다.</td></tr></tbody></table>

## 3. PolylineText 조작하기

[PolylineText](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/PolylineText-class.html) 객체를 통해 추가된 PolylineText를 조작할 수 있습니다.

```dart
// 텍스트 변경
await polylineText.changeText('새로운 텍스트');

// 스타일 변경
final newStyle = PolylineTextStyle(24, Colors.blue);
await polylineText.changeStyles(newStyle);

// 텍스트와 스타일 동시 변경
await polylineText.changeTextAndStyles('새로운 텍스트', newStyle);

// 표시/숨기기 및 삭제
await polylineText.show();
await polylineText.hide();
await polylineText.remove();

// 레이어 내 모든 PolylineText 일괄 제어
await controller.labelLayer.showAllPolylineText();
await controller.labelLayer.hideAllPolylineText();
```
