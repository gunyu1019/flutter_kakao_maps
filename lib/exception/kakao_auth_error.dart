part of '../kakao_map_sdk.dart';

/// 카카오 인증에 실패하면 호출되는 오류 객체입니다.
class KakaoAuthError implements Error {
  /// 인증 실패하면 발생하는 오류 코드입니다.
  /// 서버 통신 과정에서 필수 정보가 누락되어 발생하는 일반적인 오류 상황에서는 400 코드를 반환합니다.
  /// 인증 자격 증명을 실패했다면 401 코드를 반환합니다.
  /// 인증된 애플리케이션의 권한이 부족하여 인증에 실패했다면 403 코드를 반환합니다.
  /// 정해진 사용량 이상의 카카오맵을 이용하여 일시적으로 사용이 중지되었다면 429 코드를 반환합니다.
  /// 인터넷 연결 상태 이상 등의 이유로 통신 실패했다면 499 코드를 반환합니다.
  final int code;

  /// 인증 실패의 원인이 담긴 메시지입니다.
  final String? message;

  KakaoAuthError(this.code, this.message);

  factory KakaoAuthError.fromMessageable(dynamic payload) =>
      KakaoAuthError(payload['errorCode']!, payload['message']);

  @override
  String toString() => "KakaoAuthError(code: $code, message: $message)";

  @override
  StackTrace? get stackTrace => StackTrace.empty;
}
