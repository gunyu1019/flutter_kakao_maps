part of '../../kakao_map_sdk.dart';

/// [KImage.type]에서 사용되는 이미지의 유형을 나타냅니다.
enum ImageType {
  /// 에셋(Assets)으로 구성된 이미지입니다.
  assets(value: 0),

  /// 정적 파일 주소로 구성된 이미지입니다.
  file(value: 1),

  /// 데이터(바이트)로 구성된 이미지입니다.
  data(value: 2);

  final int value;

  const ImageType({required this.value});
}
