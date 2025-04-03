import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk_example/components/controller_mobile.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<KakaoMapView> {
  late KakaoMapController controller;

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
          bottom: 200,
          child: mapWidget(context)),
      const AnimatedPositioned(
          duration: Duration(milliseconds: 150),
          left: 0,
          right: 0,
          bottom: 0,
          child: MobileControllerWidget()),
    ]);
    return Stack(
        alignment: AlignmentDirectional.centerStart, children: children);
  }
}
