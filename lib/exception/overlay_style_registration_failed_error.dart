part of '../kakao_map_sdk.dart';

/// 오버레이 스타일 등록에 실패하면 호출되는 에러입니다.
/// 올바르지 않은 인수를 주거나, 중복된 ID를 가진 오버레이를 등록하는 등의 이유로
/// 지도에 오버레이 스타일([PoiStyle] 등)이 등록되지 않았을 때 호출되는 에러입니다.
class OverlayStyleRegistrationFailedError implements Error {
  /// 등록에 실패된 오버레이의 ID입니다.
  String? id;

  /// 등록이 실패된 컨트롤러의 유형입니다.
  /// 예를 들어 [PoiStyle] 등록에 실패한다면, [OverlayType.label] 값을 가집니다.
  OverlayType type;

  OverlayStyleRegistrationFailedError(this.id, this.type);

  @override
  String toString() => "OverlayRegistrationFailedError(id: $id)";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
