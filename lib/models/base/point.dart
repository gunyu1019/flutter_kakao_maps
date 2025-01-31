part of '../../flutter_kakao_maps.dart';

class KPoint extends math.Point<double> with KMessageable {
  const KPoint(super.x, super.y);

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "x": x,
      "y": y,
    };
    return payload;
  }
}
