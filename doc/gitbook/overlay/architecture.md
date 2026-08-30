# 오버레이와 레이어 이해하기

오버레이 API는 스타일, 오버레이 객체, 레이어의 세 단계로 구성됩니다. 이 구조를 이해하면 Poi, Shape, Route를 같은 방식으로 관리할 수 있습니다.

```text
KakaoMapController
  ├─ Style registry
  │   ├─ PoiStyle
  │   ├─ PolylineStyle / PolygonStyle
  │   └─ RouteStyle
  └─ Layer
      ├─ LabelController    → Poi, PolylineText
      ├─ LodLabelController → LodPoi
      ├─ ShapeController    → Polyline, Polygon
      └─ RouteController    → Route, MultipleRoute
```

## 1. 기본 레이어

`onMapReady`에서 받은 컨트롤러에는 다음 기본 레이어가 이미 준비되어 있습니다.

| Property | 관리 대상 |
| --- | --- |
| `labelLayer` | Poi, PolylineText |
| `lodLabelLayer` | LodPoi |
| `shapeLayer` | Polyline, Polygon |
| `routeLayer` | Route, MultipleRoute |
| `dimScreen` | dim 색상과 highlight Polygon |
| `tracking` | Poi 카메라 추적 |

## 2. 스타일 등록

Poi, Shape, Route를 추가할 때 아직 등록되지 않은 스타일은 패키지가 자동으로 등록합니다. 같은 스타일을 여러 요소에 명시적으로 공유하거나 등록 실패를 앞에서 처리하고 싶다면 먼저 등록할 수 있습니다.

```dart
final style = PoiStyle(
  id: 'store-style',
  icon: KImage.fromAsset('assets/store.png', 36, 36),
);

await controller.addPoiStyle(style);

await controller.labelLayer.addPoi(
  const LatLng(37.394776, 127.11116),
  id: 'store-1',
  style: style,
);
```

| 스타일 | 등록 API |
| --- | --- |
| `PoiStyle` | `addPoiStyle()` |
| `PolylineStyle` | `addPolylineShapeStyle()` |
| `PolygonStyle` | `addPolygonShapeStyle()` |
| `RouteStyle` | `addRouteStyle()` |
| 스타일 목록 | `addMultiple...Style()` |

> 등록된 스타일 인스턴스는 해당 `KakaoMapController`에 속합니다. 여러 지도 View를 동시에 사용한다면 같은 mutable 스타일 인스턴스를 공유하지 말고 `copyWith()`로 지도별 인스턴스를 만드세요.

## 3. ID와 조회

`id`를 생략하면 플랫폼이 고유 ID를 생성합니다. 이후 직접 조회해야 하거나 상태 복원에 사용할 요소는 명시적인 ID를 권장합니다.

```dart
final poi = await controller.labelLayer.addPoi(
  const LatLng(37.394776, 127.11116),
  id: 'office',
  style: style,
);

final samePoi = controller.labelLayer.getPoi('office');
```

같은 저장소에 중복 ID를 등록하면 `DuplicatedOverlayException`이 발생합니다. Route와 MultipleRoute처럼 같은 레이어 저장소를 공유하는 유형도 ID가 겹치지 않아야 합니다.

## 4. 커스텀 레이어

기본 레이어만으로 표시 순서나 기능 그룹을 나누기 어렵다면 커스텀 레이어를 추가합니다.

```dart
final labelLayer = await controller.addLabelLayer(
  'search-result-layer',
  zOrder: 10010,
  competitionType: CompetitionType.none,
);

await labelLayer.setClickable(true);
await labelLayer.setZOrder(10020);

final sameLayer = controller.getLabelLayer('search-result-layer');
await controller.removeLabelLayer(labelLayer);
```

`addLodLabelLayer()`, `addShapeLayer()`, `addRouteLayer()`도 같은 방식으로 사용할 수 있습니다.

## 5. 표시 순서

`zOrder`가 큰 레이어나 요소가 겹친 영역의 위에 그려집니다. 레이어의 z-order와 개별 Shape·Route의 z-order를 함께 고려하세요.

```dart
final layer = await controller.addShapeLayer(
  'selection-layer',
  zOrder: 10020,
);

await layer.addPolygonShape(
  position,
  style,
  id: 'selection',
  zOrder: 10021,
);
```

## 6. 변경과 삭제

대부분의 오버레이 객체는 동일한 생명주기 API를 제공합니다.

```dart
await overlay.hide();
await overlay.show();
await overlay.remove();
```

레이어는 일괄 표시·숨김 API와 ID 조회 API를 제공합니다. 삭제한 객체를 다시 조작하지 말고 필요한 경우 새로 추가하세요.

## 7. 비동기 호출과 오류

오버레이 등록과 변경은 플랫폼 호출이므로 `await`해야 합니다.

```dart
try {
  final route = await controller.routeLayer.addRoute(points, routeStyle);
  await route.hide();
} on DuplicatedOverlayException catch (error) {
  debugPrint('ID 중복: ${error.id}');
} on OverlayStyleRegistrationFailedError catch (error) {
  debugPrint('스타일 등록 실패: $error');
} on OverlayRegistrationFailedError catch (error) {
  debugPrint('오버레이 등록 실패: $error');
}
```

오류 유형과 대응 방법은 [오류와 예외 처리](../etc/errors.md)를 참고하세요.
