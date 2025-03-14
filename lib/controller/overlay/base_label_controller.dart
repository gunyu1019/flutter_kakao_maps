part of '../../kakao_map_sdk.dart';

/// [Poi], [LodPoi], [PolylineText] 개체를 관리하는 컨트롤러를 구현하기 위한 추성 클래스입니다.
/// 지도에 [Poi], [LodPoi], [PolylineText] 개체를 관리하기 위해 필수로 필요한 요소를 관리합니다.
abstract class BaseLabelController extends OverlayController {
  /// [LabelController], [LodLabelController]의 고유 ID입니다.
  abstract final String id;

  /// [LabelController], [LodLabelController]이 다른 [Poi], [LodPoi], [PolylineText] 중첩될 때,
  /// 경쟁하는 방법을 결정합니다.
  final CompetitionType competitionType;

  /// [LabelController], [LodLabelController]이 다른 [Poi], [LodPoi], [PolylineText] 중첩될 때,
  /// 경쟁하는 단위를 설정합니다.
  final CompetitionUnit competitionUnit;

  /// [competitionType]이 [CompetitionType.same]일 때, 경쟁하는 기준을 설정합니다.
  final OrderingType orderingType;

  /// [LabelController], [LodLabelController]에 소속되어 있는 [Poi], [LodPoi], [PolylineText] 가
  /// 지도에 표시되고 있는지 나타냅니다.
  final bool visible;

  bool _clickable;

  /// [LabelController], [LodLabelController]에 소속되어 있는 [Poi], [LodPoi], [PolylineText] 가
  /// 클릭할 수 있는지 나타냅니다.
  bool get clickable => _clickable;

  int _zOrder;

  /// 렌더링의 우선순위를 정의합니다.
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

  /// [LabelController] 또는 [LodLabelController]에 소속되어 있는 [Poi], [LodPoi], [PolylineText] 오버레이가
  /// 지도에서 클릭할 수 있는 유무를 설정합니다.
  Future<void> setClickable(bool clickable) async {
    await _invokeMethod("setLayerClickable", {"clickable": clickable});
    _clickable = clickable;
  }

  /// [LabelController] 또는 [LodLabelController]의 렌더링 우선순위를 다시 정의합니다.
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
