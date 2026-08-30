# 상태주기와 Android 복구

네이티브 지도 View는 앱의 foreground·background 전환과 Flutter 화면 이동에 영향을 받습니다. 일반적인 앱 상태주기는 패키지가 전달하지만, Navigator 구조나 Android Surface 복구가 필요한 경우 별도 설정을 사용할 수 있습니다.

## 1. 지도 상태주기 수신

`KakaoMapLifecycle`은 세 개의 선택적 콜백 필드를 제공합니다.

```dart
class MapLifecycleHandler with KakaoMapLifecycle {}

final lifecycle = MapLifecycleHandler()
  ..onMapPaused = () {
    debugPrint('지도 일시정지');
  }
  ..onMapResumed = () {
    debugPrint('지도 재개');
  }
  ..onMapDestroy = () {
    debugPrint('지도 종료');
  };
```

```dart
KakaoMap(
  onMapReady: (controller) {},
  onMapLifecycle: lifecycle,
);
```

## 2. 명시적인 pause·resume·finish

Navigator 전환처럼 플랫폼 상태주기만으로 지도 상태를 정확히 알기 어려운 화면에서는 컨트롤러를 직접 호출할 수 있습니다.

```dart
await controller.pause();
await controller.resume();
```

지도를 더 이상 사용하지 않는 종료 흐름에서는 다음을 호출할 수 있습니다.

```dart
await controller.finish();
```

이 API는 네이티브 상태주기를 위한 기능입니다. 일반적인 위젯 rebuild마다 호출하지 마세요.

## 3. Android 기본 복구

기본 설정에서는 Activity가 resume될 때 Kakao `GLSurfaceView`의 GL 스레드를 비파괴적으로 복구합니다.

```dart
KakaoMap(
  onMapReady: (controller) {},
  recoverAndroidGLSurfaceViewOnResume: true, // 기본값
);
```

이 경로는 native MapView를 새로 만들지 않으므로 기존 오버레이를 유지하는 것을 목표로 합니다.

## 4. Android 비상 재생성

특정 기기에서 비파괴 복구로도 검은 화면이나 정지 현상이 계속될 때만 MapView 재생성을 사용합니다.

```dart
KakaoMap(
  onMapReady: (controller) {
    // 재생성되면 다시 호출될 수 있으므로 오버레이를 재구성합니다.
  },
  recoverAndroidGLSurfaceViewOnResume: false,
  recreateAndroidMapViewOnResume: true,
  androidMapViewRecreationDelay: const Duration(milliseconds: 300),
);
```

> `recreateAndroidMapViewOnResume`은 파괴적 비상 복구입니다. 활성화하면 복귀 시 `onMapReady`가 다시 호출되고 native 지도에 등록했던 오버레이를 다시 만들어야 합니다.

재구성 로직은 여러 번 호출되어도 같은 결과를 만들도록 분리하는 것이 좋습니다.

```dart
Future<void> configureMap(KakaoMapController controller) async {
  final style = PoiStyle(
    icon: KImage.fromAsset('assets/marker.png', 40, 60),
  );

  await controller.labelLayer.addPoi(
    const LatLng(37.394776, 127.11116),
    id: 'main-marker',
    style: style,
  );
}
```

컨트롤러 내부 저장소는 native MapView 재생성 시 초기화되므로 이전 `Poi`나 레이어 객체를 계속 사용하지 말고 새 `onMapReady`의 컨트롤러 상태를 기준으로 다시 구성하세요.

## 5. 선택 기준

| 상황 | 권장 설정 |
| --- | --- |
| 일반 앱 | 기본값 유지 |
| background 복귀 시 일시 정지 | `recoverAndroidGLSurfaceViewOnResume: true` |
| 특정 기기에서 반복적으로 MapView가 복구되지 않음 | 비상 재생성 검토 |
| 비상 재생성 사용 | 오버레이 초기화 로직을 `onMapReady`에서 재실행 |
