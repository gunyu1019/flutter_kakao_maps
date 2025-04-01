import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/config/.env');
  await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

  DebugOverlay.enabled = true;

  final hashKey = await KakaoMapSdk.instance.hashKey();
  MyApp.logBucket.add(LogEvent(
    level: LogLevel.info,
    message: "HashKey( $hashKey ) to add Kakao Developers.",
  ));

  // Uncaught Exceptions.
  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    MyApp.logBucket.add(LogEvent(
      level: LogLevel.fatal,
      message: "Unhandled Exception",
      error: exception,
      stackTrace: stackTrace,
    ));
    return false;
  };

  // Rendering Exceptions.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    MyApp.logBucket.add(LogEvent(
      level: LogLevel.fatal,
      message: details.exceptionAsString(),
      error: details.toDiagnosticsNode().toStringDeep(),
      stackTrace: details.stack,
    ));
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final LogBucket logBucket = LogBucket();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late KakaoMapController controller;
  LatLng? position;
  List<bool> isSelected = [false, false];

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
        fontSize: 14.0, color: Colors.blue, decoration: TextDecoration.none);
    var mediaQueryData = MediaQuery.of(context);
    var screenWidth = mediaQueryData.size.width;
    var screenHeight = mediaQueryData.size.height;

    return MaterialApp(
        builder: DebugOverlay.builder(logBucket: MyApp.logBucket),
        home: Scaffold(
          body: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.8,
                    child: KakaoMap(
                        onMapReady: onMapReady,
                        onMapError: onMapError,
                        onCameraMoveEnd: (position, gestureType) => {
                              setState(() {
                                this.position = position.position;
                              })
                            })),
                Text("경도: ${position?.latitude}, 위도: ${position?.longitude}",
                    style: textStyle),
                ToggleButtons(
                    isSelected: isSelected,
                    onPressed: onToggleClicked,
                    children: const <Widget>[
                      Text("강원대학교"),
                      Text("판교아지트"),
                    ])
              ],
            ),
          ),
        ));
  }

  void onToggleClicked(int index) {
    setState(() {
      for (int buttonIndex = 0;
          buttonIndex < isSelected.length;
          buttonIndex++) {
        if (buttonIndex == index) {
          isSelected[buttonIndex] = true;
        } else {
          isSelected[buttonIndex] = false;
        }
      }

      switch (index) {
        case 1:
          controller.moveCamera(
              CameraUpdate.newCenterPosition(
                  const LatLng(37.395763313860826, 127.11048591050786)),
              animation: const CameraAnimation(5000));
          break;
        case 0:
          controller.moveCamera(
              CameraUpdate.newCenterPosition(
                  const LatLng(37.867489, 127.745273)),
              animation: const CameraAnimation(5000));
          break;
      }
    });
  }

  /// 지도가 문제없이 불러와지면 호출되는 함수
  /// [controller]에는 지도를 조작하기 위한 컨트롤러 객체가 담겨있다.
  void onMapReady(KakaoMapController controller) {
    this.controller = controller;
    MyApp.logBucket.add(LogEvent(
      level: LogLevel.info,
      message: "KakaoMap.onMapReay called!",
    ));
    controller.getCameraPosition().then((result) {
      setState(() {
        position = result.position;
      });
    });

    /// 카카오 판교캠퍼스 지점에 Poi를 그린다.
    controller.labelLayer.addPoi(
        const LatLng(37.395763313860826, 127.11048591050786),
        text: "KAKAO LABEL",
        style: PoiStyle(
            icon: KImage.fromAsset("assets/image/location.png", 68, 100),
            anchor: const KPoint(0.5, 0.9),
            textStyle: const [
              PoiTextStyle(
                  size: 28,
                  color: Colors.blue,
                  aspectRatio: 1.0,
                  stroke: 2,
                  strokeColor: Colors.white)
            ]),
      onClick: () {
          print("Poi Clicked");
      }
    );
    // .then((poi) => poi.changeText("KAKAO MAP LABEL"));

    /// 카카오 판교캠퍼스 주변에 "휘어지는 글씨 테스트"를 그린다.
    controller.labelLayer.addPolylineText(
        "휘어지는 글씨 테스트",
        const [
          LatLng(37.39375894087694, 127.10964757834647),
          LatLng(37.39623174904037, 127.10968366570474),
          LatLng(37.396289088551704, 127.1129315279461)
        ],
        style: PolylineTextStyle(28, Colors.blue));

    /// 카카오 판교캠퍼스 주변에 원형과 사각형을 그린다.
    controller.shapeLayer
        .addPolylineShape(
            RectanglePoint(
                100, 100, const LatLng(37.396289088551704, 127.1129315279461)),
            PolylineStyle(Colors.green, 10.0),
            PolylineCap.round)
        .then((shape) {
      shape.changePosition(RectanglePoint(
          100, 300, const LatLng(37.396289088551704, 127.1129315279461)));
    });
    controller.shapeLayer
        .addPolygonShape(
            CirclePoint(
                200, const LatLng(37.39375894087694, 127.10964757834647)),
            PolygonStyle(Colors.green))
        .then((shape) {
      shape.changeStyle(PolygonStyle(Colors.red));
    });

    /// 경부고속도로를 따라 경로선을 그린다.
    controller.routeLayer.addRoute(const [
      LatLng(37.32428751919564, 127.10361027597592),
      LatLng(37.38433356340711, 127.10312961558715),
      LatLng(37.40049196436421, 127.09982509355939),
      LatLng(37.40605078821915, 127.09458697605862),
      LatLng(37.43918161748264, 127.06078195006104),
    ], RouteStyle(Colors.blue, 10)).then((route) {
      route.changeStyle(RouteStyle(Colors.red, 12));
    });

    controller.compass.show();
    controller.compass.changePosition(MapGravity(HorizontalAlign.left, VerticalAlign.bottom), 10, 20);
    controller.scaleBar.show();
    controller.scaleBar.changePosition(MapGravity(HorizontalAlign.right, VerticalAlign.top), 20, 30);
  }

  void onMapError(Error exception) {
    MyApp.logBucket.add(LogEvent(
      level: LogLevel.fatal,
      message: "KakaoMap.onMapError caused!",
      error: exception,
    ));
  }
}
