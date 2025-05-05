part of '../kakao_map_sdk_web.dart';

String encodeImageToBase64(Uint8List image, [String imageType = "png"]) =>
    "data:image/$imageType;base64,${base64Encode(image)}";
