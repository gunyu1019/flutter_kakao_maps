import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:kakao_map_sdk_example/pages/kakao_map_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: 'assets/config/.env');
  // await KakaoMapSdk.instance.initialize(dotenv.env['KAKAO_API_KEY']!);

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
    var router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const KakaoMapView())
    ], initialLocation: '/');
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}