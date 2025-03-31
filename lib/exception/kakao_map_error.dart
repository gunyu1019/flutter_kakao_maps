part of '../kakao_map_sdk.dart';

/// 카카오맵을 불러오는 과정 또는 불러온 후에 네이티브에서 발생한 오류를 담는 객체입니다.
class KakaoMapError implements Error {
  /// 네이티브에서 발생한 오류를 담은 클래스 이름입니다.
  final String className;

  /// 인증 실패의 원인이 담긴 메시지입니다.
  final String? message;

  KakaoMapError(this.className, this.message);

  @override
  String toString() =>
      "KakaoMapError(className: $className, message: $message)";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
