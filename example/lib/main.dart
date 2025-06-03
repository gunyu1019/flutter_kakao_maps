import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk_example/components/drawer_component.dart';
import 'package:kakao_map_sdk_example/components/switch_component.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/components/toggle_button_component.dart';
import 'package:kakao_map_sdk_example/models/location_info.dart';

void main() async {
  // main() 함수를 비동기로 실행시키기 위해서는 WidgetsFlutterBinding.ensureInitialized(); 함수를 호출해야 합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // KakaoMapSdk.instance.initialize 함수로 애플리케이션을 인증합니다.
  await dotenv.load(fileName: 'assets/config/.env');
  await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: KakaoMapView());
  }
}

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<KakaoMapView> {
  late KakaoMapController controller;
  late bool poiVisible;
  late bool shapeVisible;
  late bool routeVisible;

  final location = <LocationInfo>[
    LocationInfo(
        "카카오 판교캠퍼스", const LatLng(37.39479412020964, 127.11116968185037)),
    LocationInfo("서울시청", const LatLng(37.56664910407437, 126.97822134589721)),
    LocationInfo("강원대학교", const LatLng(37.86921611369963, 127.74240558283384)),
  ];

  Widget locationSelection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text(
            "카메라 이동: ",
            textAlign: TextAlign.start,
            style: controllerTextStyle,
          ),
          ToggleButtonComponent(
            options: location.map((e) => e.name).toList(),
            onChanged: (index) {
              // 선택된 버튼에 따라 애니메이션(적용시간: 5초)를 적용한 상태로 카메라를 이동합니다.
              controller.moveCamera(
                  CameraUpdate.newCenterPosition(location[index].position),
                  animation: const CameraAnimation(5000));
            },
          ),
        ],
      );

  Widget overlayEnableSwitch() {
    return Column(
      children: [
        SwitchComponent(
            title: "Poi",
            textStyle: controllerTextStyle,
            onChanged: (value) {
              value
                  ? controller.labelLayer.showAllPoi()
                  : controller.labelLayer.hideAllPoi();
              setState(() => poiVisible = value);
            }),
        SwitchComponent(
            title: "Shape",
            textStyle: controllerTextStyle,
            onChanged: (value) {
              value
                  ? controller.shapeLayer.showAllPolyline()
                  : controller.shapeLayer.hideAllPolyline();
              setState(() => shapeVisible = value);
            }),
        SwitchComponent(
            title: "Route",
            textStyle: controllerTextStyle,
            onChanged: (value) {
              value
                  ? controller.routeLayer.showAllRoute()
                  : controller.routeLayer.hideAllRoute();
              setState(() => routeVisible = value);
            }),
      ],
    );
  }

  Widget controllerWidget() {
    var children = <Widget>[
      locationSelection(),
      overlayEnableSwitch(),
    ];
    return Wrap(spacing: 1.5, children: [
      const TitleComponent(),
      Row(
          spacing: 8,
          children: children
              .map((e) => Expanded(
                  flex: 1,
                  child: Padding(padding: const EdgeInsets.all(4), child: e)))
              .toList())
    ]);
  }

  // 지도 뷰
  Widget mapWidget(BuildContext context) => KakaoMap(
        onMapReady: onMapReady,
        option: const KakaoMapOption(position: LatLng(37.394776, 127.11116)),
      );

  @override
  void initState() {
    poiVisible = false;
    shapeVisible = false;
    routeVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: DrawerComponent(
          body: mapWidget(context),
          drawer: controllerWidget(),
          maxHeight: 260,
          minHeight: 60));

  final controllerTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold);

  // 예제에 구현할 오버레이를 지도에 등록합니다.
  Future<void> initializeOverlay() async {
    var poiStyle =
        PoiStyle(icon: KImage.fromAsset("assets/image/location.png", 40, 60));
    for (var loc in location) {
      await controller.labelLayer.addPoi(loc.position, style: poiStyle);
    }

    // /assets/const/shape.json 에 사전에 등록한 도형를 불러옵니다.
    final String shapeRawData =
        await rootBundle.loadString("assets/const/shape.json");
    List<dynamic> shapePoints = json.decode(shapeRawData);

    var polylineStyle = PolylineStyle(Colors.deepOrange, 12);
    for (var rawPoint in shapePoints) {
      var point = List<dynamic>.from(rawPoint)
          .map((e) => List<double>.from(e))
          .toList();
      await controller.shapeLayer.addPolylineShape(
          MapPoint(point.map((e) => LatLng(e[0], e[1])).toList()),
          polylineStyle,
          PolylineCap.round);
    }

    // /assets/const/route.json 에 사전에 등록한 경로를 불러옵니다.
    final String routeRawData =
        await rootBundle.loadString("assets/const/route.json");
    List<dynamic> routes = json.decode(routeRawData);

    var routeStyle =
        RouteStyle(Colors.blue, 12, strokeWidth: 4, strokeColor: Colors.white);
    await controller.routeLayer
        .addRoute(routes.map((e) => LatLng(e[0], e[1])).toList(), routeStyle);

    poiVisible
        ? await controller.labelLayer.showAllPoi()
        : await controller.labelLayer.hideAllPoi();
    shapeVisible
        ? await controller.shapeLayer.showAllPolyline()
        : await controller.shapeLayer.hideAllPolyline();
    routeVisible
        ? await controller.routeLayer.showAllRoute()
        : await controller.routeLayer.hideAllRoute();
  }

  /* Event Handler */
  void onMapReady(KakaoMapController controller) {
    this.controller = controller;
    initializeOverlay();
  }
}
