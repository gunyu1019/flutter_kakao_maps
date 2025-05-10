part of '../../kakao_map_sdk.dart';

/// [Poi] 또는 [LodPoi]가 나타나고, 사라질 때 적용하는 애니메이션을 정의합니다.
class PoiTransition with KMessageable {
  /// [Poi] 또는 [LodPoi]가 나타날 때 적용되는 애니메이션입니다.
  final Transition entrance;

  /// [Poi] 또는 [LodPoi]가 사라질 때 적용되는 애니메이션입니다.
  final Transition exit;

  const PoiTransition(
      {this.entrance = Transition.alpha, this.exit = Transition.alpha});

  bool isEntranceTransition() => entrance != Transition.none;
  bool isExitTransition() => exit != Transition.none;

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "entrance": entrance.value,
      "exit": exit.value
    };
    return payload;
  }

  factory PoiTransition.fromMessageable(dynamic payload) => PoiTransition(
        entrance:
            Transition.values.firstWhere((e) => e.value == payload['entrance']),
        exit: Transition.values.firstWhere((e) => e.value == payload['exit']),
      );
}
