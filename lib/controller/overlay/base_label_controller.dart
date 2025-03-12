part of '../../kakao_map_sdk.dart';

abstract class BaseLabelController extends OverlayController {
  abstract final String id;

  final CompetitionType competitionType;
  final CompetitionUnit competitionUnit;
  final OrderingType orderingType;

  final bool visible;

  bool _clickable;
  bool get clickable => _clickable;

  int _zOrder;
  int get zOrder => _zOrder;

  BaseLabelController._(this.competitionType, this.competitionUnit,
      this.orderingType, this.visible, bool clickable, int zOrder)
      : _clickable = clickable,
        _zOrder = zOrder;

  @override
  Future<T> _invokeMethod<T>(String method, Map<String, dynamic> payload) {
    payload['layerId'] = id;
    return super._invokeMethod(method, payload);
  }

  Future<void> setClickable(bool clickable) async {
    await _invokeMethod("setLayerClickable", {"clickable": clickable});
    _clickable = clickable;
  }

  Future<void> setZOrder(int zOrder) async {
    await _invokeMethod("setLayerZOrder", {"zOrder": zOrder});
    _zOrder = zOrder;
  }

  static const int defaultZOrder = 10001;
  static const CompetitionType defaultCompetitionType = CompetitionType.none;
  static const CompetitionUnit defaultCompetitionUnit =
      CompetitionUnit.iconAndText;
  static const OrderingType defaultOrderingType = OrderingType.rank;
}
