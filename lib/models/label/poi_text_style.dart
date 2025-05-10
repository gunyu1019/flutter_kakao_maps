part of '../../kakao_map_sdk.dart';

/// Poi에서 사용되는 텍스트의 스타일을 정의하는 객체입니다.
/// [Poi]와 [LodPoi]에서 사용되는 텍스트의 스타일을 정의할 때 사용됩니다.
class PoiTextStyle with KMessageable {
  /// 글씨 장평
  final double aspectRatio;

  /// 글씨 자간
  final int characterSpace;

  /// 글씨 색상
  final Color color;

  /// 글씨 폰트
  final String font;

  /// 글씨 행간
  final double lineSpace;

  /// 글씨 크기
  final int size;

  /// 글씨 외곽선의 두께
  final int stroke;

  /// 글씨 외곽선의 색상
  final Color strokeColor;

  const PoiTextStyle(
      {this.aspectRatio = 1.0,
      this.characterSpace = 0,
      this.color = Colors.black,
      this.font = "",
      this.lineSpace = 1.0,
      this.size = 24,
      this.stroke = 0,
      this.strokeColor = Colors.black});

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "aspectRatio": aspectRatio,
      "characterSpace": characterSpace,
      // ignore: deprecated_member_use
      "color": color.value,
      "font": font,
      "lineSpace": lineSpace,
      "size": size,
      "stroke": stroke,
      // ignore: deprecated_member_use
      "strokeColor": strokeColor.value
    };
    return payload;
  }

  factory PoiTextStyle.fromMessageable(dynamic payload) => PoiTextStyle(
        aspectRatio: payload['aspectRatio'],
        characterSpace: payload['characterSpace'],
        color: Color(payload['color']),
        font: payload['font'],
        lineSpace: payload['lineSpace'],
        size: payload['size'],
        stroke: payload['stroke'],
        strokeColor: Color(payload['strokeColor']),
      );
}
