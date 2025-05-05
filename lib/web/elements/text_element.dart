part of '../kakao_map_sdk_web.dart';

web.HTMLElement textElement(String text, PoiTextStyle style,
        [void Function()? onClick]) =>
    web.HTMLParagraphElement()
      ..textContent = text
      ..onclick = onClick?.toJS
      ..style.margin = "0"
      ..style.fontStretch = "${style.aspectRatio * 100}%"
      ..style.letterSpacing = "${style.characterSpace}px"
      ..style.color =
          "rgb(${style.color.r}, ${style.color.g} ,${style.color.b})"
      ..style.fontFamily = style.font
      ..style.lineHeight = "${style.lineSpace}"
      ..style.fontSize = "${style.size}px"
      ..style.textShadow =
          "-${style.stroke}px 0px rgb(${style.strokeColor.r}, ${style.strokeColor.g} ,${style.strokeColor.b}) 0px -${style.stroke}px rgb(${style.strokeColor.r}, ${style.strokeColor.g} ,${style.strokeColor.b}) ${style.stroke}px 0px rgb(${style.strokeColor.r}, ${style.strokeColor.g} ,${style.strokeColor.b}) 0px ${style.stroke}px rgb(${style.strokeColor.r}, ${style.strokeColor.g} ,${style.strokeColor.b}) ";
