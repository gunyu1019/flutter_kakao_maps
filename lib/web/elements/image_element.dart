part of '../../kakao_map_sdk.dart';

Future<web.HTMLElement> imageElement(KImage image, [void Function()? onClick]) async {
  final data = switch(image.type) {
    ImageType.assets => (await rootBundle.load(image._path!)).buffer.asUint8List(),
    ImageType.file => await File(image._path!).readAsBytes(),
    ImageType.data => image._data!,
  };
  final source = "data:image/png;base64,${base64Encode(data)}";

  return web.HTMLImageElement()
    ..width = image.width * 3
    ..height = image.height * 3
    ..onclick = onClick?.toJS
    ..src = source;
}