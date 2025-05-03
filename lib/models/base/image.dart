part of '../../kakao_map_sdk.dart';

/// 지도에서 사용할 수 있는 이미지를 생성하는 객체입니다.
/// 생성된 이미지 객체는 [Poi] 또는 [RouteStyle.withPattern] 등의 이미지가 필요한 기능에서 사용할 수 있습니다.
class KImage {
  final String? _path;
  final Uint8List? _data;
  final ImageType type;

  /// 이미지 객체의 가로 길이를 설정합니다.
  final int width;

  /// 이미지 객체의 세로 길이를 설정합니다.
  final int height;

  const KImage._(
    this.type, {
    required this.width,
    required this.height,
    String? path,
    Uint8List? data,
  })  : _path = path,
        _data = data;

  /// Assets으로 이미지 객체를 생성합니다.
  factory KImage.fromAsset(String asset, int width, int height) =>
      KImage._(ImageType.assets, path: asset, width: width, height: height);

  /// 이미지 바이너리 값으로 이미지 객체를 생성합니다.
  factory KImage.fromData(Uint8List data, int width, int height) =>
      KImage._(ImageType.data, data: data, width: width, height: height);

  /// 이미지 파일로 이미지 객체를 생성합니다.
  factory KImage.fromFile(File file, int width, int height) =>
      KImage._(ImageType.file, path: file.path, width: width, height: height);

  /// Widget을 이미지로 만들어 사용합니다.
  /// 위젯을 이미지로 만드는 것이기 때문에, 버튼 등의 상호작용 기능은 작용하지 않습니다.
  static Future<KImage> fromWidget(
      Widget child, Size size, BuildContext? context) async {
    final repaintBoundary = RenderRepaintBoundary();
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view =
        context != null ? View.maybeOf(context) ?? fallBackView : fallBackView;

    final renderPositionedBox = RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary);
    final renderView = RenderView(view: view, child: renderPositionedBox);

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    final buildOwner = BuildOwner(
      focusManager: FocusManager(),
    );
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: SizedBox(
            width: size.width,
            height: size.height,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: child,
            ))).attachToRenderTree(buildOwner);

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    try {
      final image = await repaintBoundary.toImage();
      final data = await image
          .toByteData(format: ui.ImageByteFormat.png)
          .then((b) => b!.buffer.asUint8List());

      return KImage.fromData(data, size.width as int, size.height as int);
    } finally {
      final emptyElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
      );
      rootElement.update(emptyElement);
      buildOwner.finalizeTree();
      renderView
        ..detach()
        ..dispose();
      rootElement
        ..detachRenderObject()
        ..deactivate();
      buildOwner.finalizeTree();
    }
  }

  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "type": type.value,
      "width": width,
      "height": height
    };

    switch (type) {
      case ImageType.data:
        payload['data'] = _data;
        break;
      case ImageType.assets:
      case ImageType.file:
        payload['path'] = _path;
        break;
    }
    return payload;
  }
}
