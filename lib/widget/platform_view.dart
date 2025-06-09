part of '../kakao_map_sdk.dart';

Widget _createPlatformView(
    {required String viewType,
    required Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    Function(int)? onPlatformViewCreated,
    Map<String, dynamic> creationParams = const {},
    MessageCodec creationParamsCodec = const StandardMessageCodec(),
    bool forceHybridComposition = false}) {
  if (kIsWeb) {
    return HtmlElementView(
        viewType: viewType,
        creationParams: creationParams,
        onPlatformViewCreated: onPlatformViewCreated);
  }

  if (Platform.isAndroid) {
    return PlatformViewLink(
        surfaceFactory: (context, controller) => AndroidViewSurface(
            controller: controller as AndroidViewController,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            gestureRecognizers: gestureRecognizers),
        onCreatePlatformView: (params) {
          final platformView = forceHybridComposition
              ? PlatformViewsService.initExpensiveAndroidView
              : PlatformViewsService.initAndroidView;

          return platformView.call(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: creationParamsCodec,
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(
                (viewId) => onPlatformViewCreated?.call(viewId))
            ..create();
        },
        viewType: viewType);
  } else if (Platform.isIOS) {
    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: onPlatformViewCreated,
    );
  } else {
    throw PlatformException(code: "unsupportedPlatform");
  }
}
