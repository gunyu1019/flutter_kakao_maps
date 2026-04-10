# 지도 덮어씌우기 (DimScreen)

DimScreen은 지도 위를 특정 색상으로 덮는 오버레이 요소입니다.\
특정 영역을 강조하거나 지도의 일부를 시각적으로 구분할 때 활용할 수 있습니다.\
[DimScreenController](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/DimScreenController-class.html)를 통해 DimScreen을 조작합니다.

[스크린샷]

[KakaoMapController.dimScreen](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/KakaoMapController/dimScreen.html) 프로퍼티를 통해 DimScreenController에 접근할 수 있습니다.

> DimScreen은 직접 생성하거나 삭제할 수 없습니다. `controller.dimScreen`을 통해 접근하여 사용합니다.

## 1. DimScreen 표시하기

DimScreen은 기본적으로 숨겨져 있습니다. [DimScreenController.setVisible()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/DimScreenController/setVisible.html) 함수를 이용하여 표시하거나 숨길 수 있습니다.

```dart
// DimScreen 표시
await controller.dimScreen.setVisible(true);

// DimScreen 숨기기
await controller.dimScreen.setVisible(false);
```

## 2. 색상 설정하기

[DimScreenController.setColor()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/DimScreenController/setColor.html) 함수를 이용하여 DimScreen의 색상을 설정할 수 있습니다.\
기본 색상은 반투명 검정(`Colors.black.withAlpha(128)`)입니다.

```dart
// 반투명 검정 (기본값에 가까운 예시)
await controller.dimScreen.setColor(Colors.black.withOpacity(0.5));

// 반투명 파랑
await controller.dimScreen.setColor(Colors.blue.withOpacity(0.3));
```

## 3. 덮을 범위 설정하기

[DimScreenController.setCover()](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/DimScreenController/setCover.html) 함수를 이용하여 DimScreen이 덮을 범위를 설정합니다.\
[DimScreenCover](https://pub.dev/documentation/kakao_map_sdk/latest/kakao_map_sdk/DimScreenCover.html) 열거형으로 범위를 지정합니다.

```dart
// 지도 전체를 덮습니다. (기본값)
await controller.dimScreen.setCover(DimScreenCover.all);

// 지도 영역만 덮습니다.
await controller.dimScreen.setCover(DimScreenCover.map);
```

## 4. 강조 영역 추가하기

[스크린샷]

DimScreen에 Polygon을 추가하면 해당 영역만 지도가 보이도록 구멍(Highlight)을 뚫을 수 있습니다.\
특정 지역을 집중적으로 안내할 때 활용할 수 있습니다.

```dart
Future<void> addHighlightExample(KakaoMapController controller) async {
  // DimScreen 색상 및 표시 설정
  await controller.dimScreen.setColor(Colors.black.withOpacity(0.6));
  await controller.dimScreen.setVisible(true);

  // 강조 영역 스타일 (투명하게 설정하여 지도가 보이도록 합니다.)
  final highlightStyle = PolygonStyle(Colors.transparent);
  await controller.addPolygonShapeStyle(highlightStyle);

  // 사각형 강조 영역 추가
  final highlight = await controller.dimScreen.addPolygonShape(
    MapPoint([
      const LatLng(37.393, 127.109),
      const LatLng(37.393, 127.113),
      const LatLng(37.397, 127.113),
      const LatLng(37.397, 127.109),
    ]),
    highlightStyle,
  );
}
```

원형이나 사각형 형태의 강조 영역도 추가할 수 있습니다.

```dart
// 원형 강조 영역
final circleHighlight = await controller.dimScreen.addPolygonShape(
  CirclePoint(
    200.0, // 반경 (픽셀)
    const LatLng(37.394776, 127.11116),
  ),
  highlightStyle,
);

// 사각형 강조 영역
final rectHighlight = await controller.dimScreen.addPolygonShape(
  RectanglePoint(
    400.0, // 너비 (픽셀)
    300.0, // 높이 (픽셀)
    const LatLng(37.394776, 127.11116),
  ),
  highlightStyle,
);
```

## 5. 강조 영역 삭제하기

```dart
// 특정 강조 영역 삭제
await controller.dimScreen.removePolygonShape(highlight);

// ID로 강조 영역 가져오기
final polygon = controller.dimScreen.getPolygonShape(highlight.id);
```

## 6. 전체 예제

```dart
Future<void> dimScreenExample(KakaoMapController controller) async {
  // 1. DimScreen 색상 설정
  await controller.dimScreen.setColor(Colors.black.withOpacity(0.6));

  // 2. 강조 영역 스타일 등록
  final style = PolygonStyle(Colors.transparent);
  await controller.addPolygonShapeStyle(style);

  // 3. 카카오 판교캠퍼스 주변을 원형으로 강조
  await controller.dimScreen.addPolygonShape(
    CirclePoint(150.0, const LatLng(37.394776, 127.11116)),
    style,
  );

  // 4. DimScreen 표시
  await controller.dimScreen.setVisible(true);
}
```
