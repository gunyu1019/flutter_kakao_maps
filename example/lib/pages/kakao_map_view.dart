import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

class KakaoMapView extends StatefulWidget {
  final Widget menuPage;

  const KakaoMapView({super.key, required this.menuPage});

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
          bottom: mediaQuery.size.height * 0.35,
          child: mapWidget(context)),
      AnimatedPositioned(
          duration: const Duration(milliseconds: 150),
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            constraints:
                BoxConstraints(maxHeight: mediaQuery.size.height * 0.35),
            width: mediaQuery.size.width,
            child: Padding(
                padding: const EdgeInsets.all(8), child: widget.menuPage),
          ))
    ]);
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.centerStart, children: children)
    );
  }
}
