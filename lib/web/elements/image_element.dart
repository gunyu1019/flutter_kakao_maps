part of '../kakao_map_sdk_web.dart';

web.HTMLElement imageElement(String source, int width, int height,
        [void Function()? onClick]) =>
    web.HTMLImageElement()
      ..width = width * 3
      ..height = height * 3
      ..onclick = onClick?.toJS
      ..src = source;
