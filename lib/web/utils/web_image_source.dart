part of '../../../kakao_map_sdk.dart';

Future<Uint8List> convertImageToData(KImage image) async =>
    switch (image.type) {
      ImageType.assets =>
        (await rootBundle.load(image._path!)).buffer.asUint8List(),
      ImageType.file => await File(image._path!).readAsBytes(),
      ImageType.data => image._data!,
    };

String encodeImageToBase64(Uint8List image, [String imageType = "png"]) =>
    "data:image/$imageType;base64,${base64Encode(image)}";
