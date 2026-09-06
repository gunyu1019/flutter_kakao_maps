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
  late bool dimScreenVisible;
  late bool polylineTextVisible;
  late bool eventEnable;

  final polylineTextPoints = [
    const LatLng(37.39622327123534, 127.10969230372446),
    const LatLng(37.395410161239674, 127.11202881608124),
    const LatLng(37.39380557163993, 127.1128395227644)
  ];

  final location = <LocationInfo>[
    LocationInfo(
      "카카오 판교캠퍼스",
      const LatLng(37.39479412020964, 127.11116968185037),
    ),
    LocationInfo("서울시청", const LatLng(37.56664910407437, 126.97822134589721)),
    LocationInfo("강원대학교", const LatLng(37.86921611369963, 127.74240558283384)),
  ];

  Widget locationSelection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 4,
    children: [
      Text("카메라 이동: ", textAlign: TextAlign.start, style: controllerTextStyle),
      ToggleButtonComponent(
        options: location.map((e) => e.name).toList(),
        onChanged: (index) {
          // 선택된 버튼에 따라 애니메이션(적용시간: 5초)를 적용한 상태로 카메라를 이동합니다.
          controller.moveCamera(
            CameraUpdate.newCenterPosition(location[index].position),
            animation: const CameraAnimation(5000),
          );
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
          },
        ),
        SwitchComponent(
          title: "Shape",
          textStyle: controllerTextStyle,
          onChanged: (value) {
            value
                ? controller.shapeLayer.showAllPolyline()
                : controller.shapeLayer.hideAllPolyline();
            value
                ? controller.shapeLayer.showAllPolygon()
                : controller.shapeLayer.hideAllPolygon();
            setState(() => shapeVisible = value);
          },
        ),
        SwitchComponent(
          title: "Route",
          textStyle: controllerTextStyle,
          onChanged: (value) {
            value
                ? controller.routeLayer.showAllRoute()
                : controller.routeLayer.hideAllRoute();
            setState(() => routeVisible = value);
          },
        ),
        SwitchComponent(
          title: "DimScreen",
          textStyle: controllerTextStyle,
          onChanged: (value) {
            controller.dimScreen.setVisible(value);
            setState(() => dimScreenVisible = value);
          },
        ),
        /* SwitchComponent(
          title: "PolylineText",
          textStyle: controllerTextStyle,
          onChanged: (value) {
            value
                ? controller.labelLayer.showAllPolylineText()
                : controller.labelLayer.hideAllPolylineText();
            setState(() => polylineTextVisible = value);
          },
        ), */
        SwitchComponent(
          title: "Event",
          textStyle: controllerTextStyle,
          onChanged: (value) {
            setState(() => eventEnable = value);
          },
        ),
      ],
    );
  }

  Widget controllerWidget() {
    var children = <Widget>[locationSelection(), overlayEnableSwitch()];
    return Wrap(
      spacing: 1.5,
      children: [
        const TitleComponent(),
        Row(
          spacing: 8,
          children: children
              .map(
                (e) => Expanded(
                  flex: 1,
                  child: Padding(padding: const EdgeInsets.all(4), child: e),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // 지도 뷰
  Widget mapWidget(BuildContext context) => KakaoMap(
    onMapReady: onMapReady,
    onMapClick: onMapClick,
    option: const KakaoMapOption(position: LatLng(37.394776, 127.11116)),
  );

  @override
  void initState() {
    poiVisible = false;
    shapeVisible = false;
    routeVisible = false;
    dimScreenVisible = false;
    polylineTextVisible = false;
    eventEnable = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DrawerComponent(
      body: mapWidget(context),
      drawer: controllerWidget(),
      maxHeight: 320,
      minHeight: 60,
    ),
  );

  final controllerTextStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.bold,
  );

  // 예제에 구현할 오버레이를 지도에 등록합니다.
  Future<void> initializeOverlay() async {
    var poiStyle = PoiStyle(
      textStyle: [const PoiTextStyle(
        color: Colors.red,
        stroke: 16,
        strokeColor: Colors.white,
        size: 48,
      )],
      icon: KImage.fromAsset("assets/image/location.png", 40, 60),
    );
    for (var loc in location) {
      await controller.labelLayer.addPoi(
          loc.position,
          style: poiStyle,
          text: loc.name
      );
    }

    // /assets/const/shape.json 에 사전에 등록한 도형를 불러옵니다.
    final String shapeRawData = await rootBundle.loadString(
      "assets/const/shape.json",
    );
    List<dynamic> shapePoints = json.decode(shapeRawData);

    var polylineStyle1 = PolylineStyle(Colors.deepOrange, 12);
    var polylineStyle2 = PolygonStyle(Colors.green);
    var polylineStyle3 = PolygonStyle(
      Colors.yellow.withValues(alpha: 0.3),
      strokeColor: Colors.blue,
      strokeWidth: 3,
    );
    await controller.addPolygonShapeStyle(polylineStyle2);
    await controller.addPolygonShapeStyle(polylineStyle3);

    for (var rawPoint in shapePoints) {
      var point = List<dynamic>.from(
        rawPoint,
      ).map((e) => List<double>.from(e)).toList();
      await controller.shapeLayer.addPolylineShape(
        MapPoint(point.map((e) => LatLng(e[0], e[1])).toList()),
        polylineStyle1,
        PolylineCap.round,
      );
    }
    await controller.shapeLayer.addPolygonShape(
      CirclePoint(400, const LatLng(37.39922517606363,127.10805907837934)),
      polylineStyle2,
    );
    await controller.shapeLayer.addPolygonShape(
      RectanglePoint(340, 400, const LatLng(37.39990534855002, 127.11298419463544)),
      polylineStyle3,
    );

    // /assets/const/route.json 에 사전에 등록한 경로를 불러옵니다.
    final String routeRawData = await rootBundle.loadString(
      "assets/const/route.json",
    );
    List<dynamic> routes = json.decode(routeRawData);

    var routeStyle = RouteStyle(
      Colors.blue,
      12,
      strokeWidth: 4,
      strokeColor: Colors.white,
    );
    await controller.routeLayer.addRoute(
      routes.map((e) => LatLng(e[0], e[1])).toList(),
      routeStyle,
    );

    /* final polylineTextStyle = PolylineTextStyle(
        64, Colors.blue,
        strokeColor: Colors.white,
        strokeSize: 3
    );

    await controller.labelLayer.addPolylineText(
      "Polyline Text (휘어진 글씨)",
      polylineTextPoints,
      style: polylineTextStyle,
    ); */

    // 카카오 판교캠퍼스 주변을 사각형으로 강조하는 DimScreen을 구성합니다.
    await controller.dimScreen.setColor(Colors.black.withValues(alpha: 0.6));
    // Highlight 영역에는 지도도 보이면서 스타일도 함께 표시됩니다.
    final highlightStyle1 = PolygonStyle(
      Colors.lightBlueAccent.withValues(alpha: 0.25),
      strokeColor: Colors.yellowAccent,
      strokeWidth: 6,
    );
    final highlightStyle2 = PolygonStyle(Colors.orange);
    final highlightStyle3 = PolygonStyle(
      Colors.green.withValues(alpha: 0.3),
      strokeColor: Colors.red,
      strokeWidth: 3,
    );
    await controller.addPolygonShapeStyle(highlightStyle1);
    await controller.addPolygonShapeStyle(highlightStyle2);
    await controller.addPolygonShapeStyle(highlightStyle3);

    await controller.dimScreen.addPolygonShape(
      MapPoint([
        const LatLng(37.393, 127.109),
        const LatLng(37.393, 127.113),
        const LatLng(37.397, 127.113),
        const LatLng(37.397, 127.109),
        const LatLng(37.393, 127.109),
      ]),
      highlightStyle1,
    );
    await controller.dimScreen.addPolygonShape(
      CirclePoint(400, const LatLng(37.39922517606363,127.10805907837934)),
      highlightStyle2,
    );
    await controller.dimScreen.addPolygonShape(
      RectanglePoint(340, 400, const LatLng(37.39990534855002, 127.11298419463544)),
      highlightStyle3,
    );

    poiVisible
        ? await controller.labelLayer.showAllPoi()
        : await controller.labelLayer.hideAllPoi();
    shapeVisible
        ? await controller.shapeLayer.showAllPolyline()
        : await controller.shapeLayer.hideAllPolyline();
    shapeVisible
        ? await controller.shapeLayer.showAllPolygon()
        : await controller.shapeLayer.hideAllPolygon();
    routeVisible
        ? await controller.routeLayer.showAllRoute()
        : await controller.routeLayer.hideAllRoute();
    /* polylineTextVisible
        ? controller.labelLayer.showAllPolylineText()
        : controller.labelLayer.hideAllPolylineText(); */
    await controller.dimScreen.setVisible(dimScreenVisible);
  }

  /* Event Handler */
  void onMapReady(KakaoMapController controller) {
    this.controller = controller;
    initializeOverlay();
  }

  void onMapClick(KPoint point, LatLng latLng) {
    if (!eventEnable) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${latLng.latitude}, ${latLng.longitude}"),
      )
    );
    Clipboard.setData(
        ClipboardData(text: "${latLng.latitude}, ${latLng.longitude}")
    );
  }
}
