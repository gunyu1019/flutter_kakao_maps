part of '../../kakao_map_sdk.dart';

class KPoint extends math.Point with KMessageable {
  const KPoint(super.x, super.y);

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "x": x,
      "y": y,
    };
    return payload;
  }

  factory KPoint.fromMessageable(dynamic payload) =>
      KPoint(payload["x"], payload['y']);
}
