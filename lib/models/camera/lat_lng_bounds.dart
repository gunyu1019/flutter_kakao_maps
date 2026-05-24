part of '../../kakao_map_sdk.dart';

/// 화면에 보이는 지도 영역의 경계를 정의할 때 사용하는 객체입니다
class LatLngBounds with KMessageable {
  /// north-east - 지도의 보이는 영역 중 오른쪽 위 모서리 지점입니다
  final LatLng ne;

  /// south-west - 지도의 보이는 영역 중 왼쪽 아래 모서리 지점입니다
  final LatLng sw;

  /// north-west - 왼쪽 위 모서리 지점입니다
  LatLng get nw => LatLng(ne.latitude, sw.longitude);

  /// south-east - 오른쪽 아래 모서리 지점입니다
  LatLng get se => LatLng(sw.latitude, ne.longitude);

  LatLngBounds._(this.ne, this.sw);

  factory LatLngBounds.fromMessageable(dynamic payload) => LatLngBounds._(
        LatLng.fromMessageable(payload['ne']),
        LatLng.fromMessageable(payload['sw']),
      );

  /// REST API의 'rect' 파라미터로 사용할 수 있는 문자열을 생성합니다
  String toRect() {
    return '${sw.longitude},${sw.latitude},${ne.longitude},${ne.latitude}';
  }

  LatLngBounds copyWith({LatLng? ne, LatLng? sw}) =>
      LatLngBounds._(ne ?? this.ne, sw ?? this.sw);

  @override
  Map<String, dynamic> toMessageable() => {
        "ne": ne.toMessageable(),
        "sw": sw.toMessageable(),
      };

  @override
  int get hashCode => ne.hashCode ^ sw.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LatLngBounds && other.ne == ne && other.sw == sw;
  }
}
