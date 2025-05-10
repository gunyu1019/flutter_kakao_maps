part of '../../kakao_map_sdk.dart';

/// [RouteStyle]에서 사용되며 스타일에 패턴(규칙)을 정의하는 객체입니다.
class RoutePattern with KMessageable {
  /// 패턴에 사용할 이미지입니다.
  final KImage patternImage;

  /// 패턴 이미지 외에 패턴의 속성을 표시할 심볼 이미지입니다.
  final KImage? symbolImage;

  /// 패턴 이미지를 표시하는 간격입니다.
  final double distance;

  /// 패턴의 시작 지점에 이미지를 고정하여 그릴지 정의합니다.
  bool pinStart;

  /// 패턴의 끝 지점에 이미지를 고정하여 그릴지 정의합니다.
  bool pinEnd;

  RoutePattern(
    this.patternImage,
    this.distance, {
    this.symbolImage,
    this.pinStart = false,
    this.pinEnd = false,
  });

  @override
  Map<String, dynamic> toMessageable() {
    return {
      "patternImage": patternImage.toMessageable(),
      "symbolImage": symbolImage?.toMessageable(),
      "distance": distance,
      "pinStart": pinStart,
      "pinEnd": pinEnd
    };
  }

  factory RoutePattern.fromMessageable(dynamic payload) => RoutePattern(
      KImage.fromMessageable(payload["patternImage"]), payload["distance"],
      symbolImage: payload["symbolImage"] != null
          ? KImage.fromMessageable(payload["symbolImage"])
          : null,
      pinStart: payload["pinStart"],
      pinEnd: payload["pinEnd"]);
}
