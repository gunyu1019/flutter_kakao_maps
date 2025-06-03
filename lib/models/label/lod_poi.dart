part of '../../kakao_map_sdk.dart';

/// 지도에 [LodPoi]를 나타내는 객체입니다.
/// [LodPoi]는 [Poi]와 달리, 많은 갯수의 [Poi] 을 표시해야 할 때 [Poi]의 우선순위를 미리 계산하여 빠르게 표시할 수 있습니다.
/// [LodPoi]에는 이동 또는 회전 기능이 없습니다.
class LodPoi {
  final LodLabelController _controller;

  /// [LodPoi]의 고유 ID입니다.
  final String id;

  /// [LodPoi]가 나타나거나 사라질 때 적용되는 애니메이션입니다.
  final TransformMethod? transform;

  /// [LodPoi]의 위치입니다.
  final LatLng position;

  /// [LodPoi]를 클릭하였을 때, 호출되는 함수입니다.
  void Function()? onClick;

  /// [LodPoi]의 [onClick]이 정의되어 클릭할 수 있는지 반환합니다.
  bool get clickable => onClick != null;

  String? _text;

  /// [LodPoi]에 설정된 텍스트입니다.
  String? get text => _text;

  int _rank;

  /// [LodPoi]의 렌더링 우선순위입니다.
  int get rank => _rank;

  PoiStyle _style;

  /// [LodPoi]에 정의된 [PoiStyle] 객체입니다.
  PoiStyle get styles => _style;
  PoiStyle get style => _style;

  bool _visible;

  /// [LodPoi]가 현재 지도에 그려지는지 여부를 나타냅니다.
  bool get visible => _visible;

  LodPoi._(this._controller, this.id,
      {required this.transform,
      required this.position,
      required PoiStyle style,
      required String? text,
      required int rank,
      required bool visible,
      this.onClick})
      : _style = style,
        _text = text,
        _rank = rank,
        _visible = visible;

  /// [LodPoi]의 [rank]를 즉시 변경합니다.
  Future<void> changeRank(int rank) async {
    _rank = rank;
    await _controller._rankPoi(id, rank);
  }

  /// [LodPoi]에 적용된 [PoiStyle]을 즉시 변경합니다.
  /// [transition] 매개변수에 따라 [PoiStyle.iconTransition]과 [PoiStyle.textTransition]를 적용할 지 설정합니다.
  Future<void> changeStyle(PoiStyle style, [bool transition = false]) async {
    if (!style._isAdded) {
      await _controller.manager.addPoiStyle(style);
    }
    await _controller._changePoiStyle(id, style.id!);
    _style = style;
  }

  /// [LodPoi]에서 노출되고 있는 텍스트를 즉시 변경합니다.
  /// [transition] 매개변수에 따라 [PoiStyle.textTransition]를 적용할 지 설정합니다.
  Future<void> changeText(String text, [bool transition = false]) async {
    _text = text;
    await _controller._changePoiText(id, text, _style.id!, transition);
  }

  /// [LodPoi] 개체를 삭제합니다.
  Future<void> remove() async {
    await _controller.removeLodPoi(this);
  }

  /// [LodPoi]를 지도에서 노출되지 않도록 합니다.
  Future<void> hide() async {
    await _controller._changePoiVisible(id, false);
    _visible = false;
  }

  /// [LodPoi]를 지도에서 보이도록 합니다.
  /// (iOS 한정) [autoMove] 매개변수가 [true] 값이면 해당 위치로 카메라를 이동합니다.
  Future<void> show([bool? autoMove, int? duration]) async {
    await _controller._changePoiVisible(id, true, autoMove: autoMove);
    _visible = true;
  }
}
