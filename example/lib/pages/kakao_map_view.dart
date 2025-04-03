
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
    if (mediaQuery.size.height > mediaQuery.size.width) {
      // Apply Mobile Position
      children.add(
        SizedBox(
          width: mediaQuery.size.width,
          height: mediaQuery.size.height * 0.7,
          child: mapWidget(context), 
        )
      );
      children.add(
        Positioned(
          bottom: 0,
          child: SizedBox(
            width: mediaQuery.size.width - 20,
            height: mediaQuery.size.height * 0.3,
            child: const KakaoMapControllerWidget(),
          ),
        )
      );
    } else { 
      // Apply Tablet/PC Position
      children.add(
        SizedBox(
          width: mediaQuery.size.width,
          height: mediaQuery.size.height,
          child: mapWidget(context), 
        )
      );
      children.add(
        const Positioned(
          top: 10,
          right: 10,
          child: SizedBox(
            width: 300,
            height: 300,
            child: KakaoMapControllerWidget(),
          ),
        )
      );
    }
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: children
    );
  }
}
