import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:kakao_map_sdk/kakao_map_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/config/.env');
  await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late KakaoMapController controller;

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var screenWidth = mediaQueryData.size.width;
    var screenHeight = mediaQueryData.size.height;

    return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),
        ));
  }

  /// 지도가 문제없이 불러와지면 호출되는 함수
  /// [controller]에는 지도를 조작하기 위한 컨트롤러 객체가 담겨있다.
  void onMapReady(KakaoMapController controller) {
  }

  void onMapError(Error exception) {
  }
}
