import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk_example/components/switch_component.dart';
import 'package:kakao_map_sdk_example/components/title_component.dart';
import 'package:kakao_map_sdk_example/components/toggle_button_component.dart';
import 'package:kakao_map_sdk_example/models/location_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: 'assets/config/.env');
  // await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

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
              controller.moveCamera(CameraUpdate.newCenterPosition(location[index].position), animation: const CameraAnimation(5));
            },
          ),
        ],
      );

  Widget overlayEnableSwitch() {
    return Column(
      children: [
        SwitchComponent(title: "Poi", textStyle: controllerTextStyle, onChanged: (value) {}),
        SwitchComponent(title: "Shape", textStyle: controllerTextStyle, onChanged: (value) {}),
        SwitchComponent(title: "Route", textStyle: controllerTextStyle, onChanged: (value) {}),
      ],
    );
  }

  Widget controllerWidget() {
    var children = <Widget>[
      locationSelection(),
      overlayEnableSwitch(),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(spacing: 1.5, children: [
            const TitleComponent(),
            Row(
                spacing: 8,
                children: children
                    .map((e) => Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(4), child: e)))
                    .toList())
          ]),
        ),
      )
    ]);
  }

  Widget mapWidget(BuildContext context) {
    /* return KakaoMap(
      onMapReady: (controller) => this.controller = controller,
      option: const KakaoMapOption(
        position: LatLng(37.394776, 127.11116)
      ),
    ); */
    return Container(color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var children = <Widget>[];

    children.addAll([
      AnimatedPositioned(
          duration: const Duration(milliseconds: 150),
          top: 0,
          left: 0,
          right: 0,
          bottom: 260,
          child: mapWidget(context)),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 150),
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
            height: 260,
            width: mediaQuery.size.width,
            padding: const EdgeInsets.all(8),
            child: controllerWidget()),
      )
    ]);
    return Scaffold(
        body: Stack(
            alignment: AlignmentDirectional.centerStart, children: children));
  }

  final controllerTextStyle = const TextStyle(
      fontSize: 16, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.bold);
}
