part of '../kakao_map_sdk_web.dart';

Future<Uint8List> convertImageToData(dynamic image) async =>
    switch (ImageType.values.where((e) => e.value == image["type"]).first) {
      ImageType.assets =>
        (await rootBundle.load(image["path"])).buffer.asUint8List(),
      ImageType.file => await File(image["path"]).readAsBytes(),
      ImageType.data => image["data"],
    };

String encodeImageToBase64(Uint8List image, [String imageType = "png"]) =>
    "data:image/$imageType;base64,${base64Encode(image)}";
