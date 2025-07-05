## 1.1.4 
* Update version of base SDK (to v2.12.14 in Android / to v2.12.5 in iOS)
* [Fix] (Web Environment) Ignored Z-Index attribute Kakao Map View in canvas mode ([#23](https://github.com/gunyu1019/flutter_kakao_maps/issues/23))
* [Fix] (Web Environment) Resolve type 'List<dynamic>' is not a subtype of type 'List<LatLng>' in `CameraUpdate.fromMessageable` factory function.
* [Fix] (Web Environment) Cannot move camera without animation option.

## 1.1.3
* [Fix] (Android) Automatic bring map to front when open app from lock screen ([#14](https://github.com/gunyu1019/flutter_kakao_maps/issues/14))
  * Implement a function that can be called in lifecycle.
  * Apply other engine that can render between Dart and Android View.
* [Fix] Invaild pre-added style check condition in overlay addition function ([#24](https://github.com/gunyu1019/flutter_kakao_maps/issues/24))

## 1.1.2
* [Fix] Invalid method called in `KImage.fromWidget.` ([#22](https://github.com/gunyu1019/flutter_kakao_maps/issues/22))

## 1.1.1
* Add calling `mapView.finish()` function in Map View on Android.
* [Fix] Fix `NoSuchMethodError` in Map View on Android ([#21](https://github.com/gunyu1019/flutter_kakao_maps/issues/21))
* [Fix] Fix Poi registration failed exception with text-only style on Web.

## 1.1.0
* **Support Kakao Map SDK on Web Platform**
* Add `KImage.fromWidget` to render the widget as an image element used on Poi Icon, Route Pattern Image, etc...<br/>
  ```dart
  final icon = await KImage.fromWidget(const Text("텍스트"), Size(100, 40));
  final poiStyle = PoiStyle(icon: icon);
  ...
  ```
* Add `offset()` and `distance()` function in LatLng object to measure the distance of two point.<br/>
  ```dart
  final point1 = const LatLng(latitude1, longitude1);
  final point2 = const LatLng(latitude2, longitude2);
  point1.distance(point2); // Return the distacne of two points.
  ...
  ```
* Add `addRetangleHole`, `addCircleHole` function in instance extended `DotPoint` object.
  ```dart
  final point = CirclePoint(radius: 300);
  point.addCircleHole(radius: 200); // Add circle hole with a radius of 200 meters.
  ...
  ```
* Add `otherStyles`, `otherStyleLevel`, and `otherStyleCount` field in `PoiStyle`, `PolygonStyle`, `PolylineStyle` and `RouteStyle`.
* Add `multiple` field in `Route`, `MultipleRoute` to seperate two type of route.
* Add `remove` function in Polyline Shape, Polygon Shape.
* [Fix] Rename `style` field from `styles` in `LodPoi` to unify the structure of `Poi`.
* [Fix] Missing `text` parameter in `Poi.setText`.
* [Fix] A runtime error occurs when adding a `MultipleRoute` overlay.
* [Fix] Adjust screen point returned by the `onCameraMoveEnd` event from relative pixels to absolute pixels on iOS Platform. ([#16](https://github.com/gunyu1019/flutter_kakao_maps/issues/16))
* [Fix] Invalid raw value of Gestrue Type returned by the `onCameraMoveEnd` event on iOS Platform ([#20](https://github.com/gunyu1019/flutter_kakao_maps/issues/20))

## 1.0.2
* Support Pro-Motion display mode in iOS Platform.
* Apply resizing capabilities in `addViewSucceeded` event handler to onnection and resize duplicate event on iOS platform.
* [Fix] Invaild extended type in KPoint.
* [Fix] Missing engine activation due to network error on iOS platform. ([#15](https://github.com/gunyu1019/flutter_kakao_maps/issues/15))
* [Fix] Adjust screen point to absolute pixels on iOS platform.

## 1.0.1
* The padding, zoomLevel parameters in CameraUpdate.fitMapPoints are no longer required.
* [Fix] Invalid type of CameraUpdate.fitMapPoints
* [Fix] Remake CameraUpdate.fitMapPoints parts in CameraTypeConvertType.swift to avoid Swift Compiling Error ([#12](https://github.com/gunyu1019/flutter_kakao_maps/issues/12))

## 1.0.0
This is first stable version of Kakao Map SDK (Flutter Plugin)
A Kakao Map SDK was planned in October 25th, and development began on November 26th.
I completed the implementation of the Kakao Map SDK on Android platform in early January and in February, I worked on the implementation for iOS platform.
Finally, after testing in all platforms, I officially released the Kakao Map SDK.

* Implement the native based Kakao Map view.
* Support all features of overlay in Android, iOS platform.
  * Poi, Lod Poi (Level of detail Poi), Polyline Text
  * Polyline Shape, Polygon shape
  * Route, Multiple Route
* Support all features of camera controls in Android, iOS platform.

## 0.2.0-dev.5
* Support all feature related Shape in iOS and Android Platform.
  * Support point based position.
  * Modifiy Polyline Shape
  * Modifiy Polygon Shape
  * Setup visible of shape layer
* Support all feature related Route in iOS and Android Platform.
  * Add Route
  * Modify Route
  * Implement Route Converter
  * Setup visible of route layer
* Implement modify label layer and lod label layer in Android Platform
* [Fix] Missing filled polyline shape style ID, polygon shape style ID, and route style ID.
* Integrate modify logic of polyline shape and polygon shape
* Integrate modify logic of route line

## 0.2.0-dev.4
* Add zOrder attribute at PolygonShape and PolylineShape.
* Support some feature Polyline Shape and Polygon Shape in iOS Platform.
  * Add Polyline Shape / Polygon Shape
  * Implement Shape Converter(DotPoints, PolylineStyle, PolygonStyle)

## 0.2.0-dev.3
* Support all feature related Poi in iOS Platform.
  * Add and remove LodPoi or LodLabelLayer
  * Add and remove PolylineText
  * Modify Poi.
  * Implement Label Converter (WaveTextStyle, WaveTextOption)
* [Fix] Missing feature autoMove parameter in Poi.show() method
* [Fix] Missing feature transition parameter in Poi.changestyle(), Poi.changeText() method

## 0.2.0-dev.2
* Support some feature related Poi in iOS Platform.
  * Add and remove Poi or LabelLayer.
  * Implement Label Converter(PoiTextStyle, PoiIconStyle, PoiOptions ... etc).
* Add `setGestureEnable` method in iOS Platform.
* Implement `onCameraMoveStart` and `onCameraMoveEnd` event handler.
* Implement Reference Converter(UIColor, UIImage) to cast swift instance from dart instance.
* Configure `buildingHeightScale` property to not be required awaitable.
* Apply MapGravity at Poi.textGravity property.
* Rename default view name on iOS Platform for integration Android default view name
* [Fix] Invaild raw value in MapGravity enumeration
* [Fix] Invaild keyword in transition from enterence to entrance
* [Fix] Adjust default aspectRatio property in PoiTextStyle
* [Fix] Adjust default clickable parameter in LabelController.addPoi and LodLabelController.addLodPoi.

## 0.2.0-dev.1
* Implement Kakao Map View to iOS Platform
  * Kakao Map Lifecycle in native environment
  * Support responsive frame
  * Split delegate instance to `KakaoMapViewDelegate.swift`
* Implement Kakao Map Plugin in iOS Platform (based cocoapod)
  * Implement converter (PrimitiveTypeConverter, CameraTypeConverter) with extension and internal function.
  * Implement `MapviewType` object to setup kakao map with extension.
* Implement some feature in Kakao Map Controller
  * `moveCamera` method to control camera looking at a kakao map.
  * `getCameraPosition` method to get camera position looking at a kakao map.
* Implement `SDKInitializer` class in iOS Platform

## 0.1.0-dev.5
* Initial Deployment (Implement Kakao Map to Android Platform)
