part of '../kakao_map_sdk_web.dart';

web.HTMLElement imageElement(String source, int width, int height,
        [void Function()? onClick]) =>
    web.HTMLImageElement()
      ..width = width
      ..height = height
      ..onclick = onClick?.toJS
      ..src = source;
