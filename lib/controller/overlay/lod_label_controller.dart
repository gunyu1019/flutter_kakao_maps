part of '../../kakao_map_sdk.dart';

/// 지도에 [LodPoi]를 생성하거나 삭제하는 등의 개체 관리를 할 수 있는 컨트롤러입니다.
class LodLabelController extends BaseLabelController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.lodLabel;

  @override
  final String id;

  /// LOD(Level of Detail) 작업을 위해 반경을 설정합니다.
  /// [LodLabelController.radius]에 따라 지도에서 [LodPoi]를 미리 연산하여 표시합니다.
  final double radius;

  final Map<String, LodPoi> _poi = {};

  LodLabelController._(
    this.channel,
    this.manager,
    this.id, {
    competitionType = BaseLabelController.defaultCompetitionType,
    competitionUnit = BaseLabelController.defaultCompetitionUnit,
    orderingType = BaseLabelController.defaultOrderingType,
    this.radius = LodLabelController.defaultRadius,
    bool visible = true,
    bool clickable = true,
    int zOrder = BaseLabelController.defaultZOrder,
  }) : super._(competitionType, competitionUnit, orderingType, visible,
            clickable, zOrder);

  Future<void> _createLodLabelLayer() async {
    await _invokeMethod("createLodLabelLayer", {
      "competitionType": competitionType.value,
      "competitionUnit": competitionUnit.value,
      "orderingType": orderingType.value,
      "radius": radius,
      "zOrder": zOrder,
      "visable": visible,
      "clickable": _clickable,
    });
  }

  Future<void> _removeLodLabelLayer() async {
    await _invokeMethod("removeLodLabelLayer", {});
  }

  Future<void> _changePoiVisible(String poiId, bool visible,
      {bool? autoMove}) async {
    await _invokeMethod("changePoiVisible",
        {"poiId": poiId, "visible": visible, "autoMove": autoMove});
  }

  Future<void> _changePoiStyle(String poiId, String styleId,
      [bool transition = false]) async {
    await _invokeMethod("changePoiStyle",
        {"poiId": poiId, "styleId": styleId, "transition": transition});
  }

  Future<void> _changePoiText(String poiId, String text, String styleId,
      [bool transition = false]) async {
    await _invokeMethod("changePoiText", {
      "poiId": poiId,
      "text": text,
      "styleId": styleId,
      "transition": transition
    });
  }

  Future<void> _rankPoi(String poiId, int rank) async {
    await _invokeMethod("rankPoi", {"poiId": poiId, "rank": rank});
  }

  /// 지도에 새로운 [LodPoi]를 그립니다.
  /// [LodPoi]를 그리기 위해서는 위치([position])와 스타일([style])이 필수로 입력되어야 합니다.
  Future<LodPoi> addLodPoi(
    LatLng position, {
    required PoiStyle style,
    String? id,
    String? text,
    TransformMethod? transform,
    int? rank,
    void Function()? onClick,
    bool visible = true,
  }) async {
    if (id != null && _poi.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    if (!style._isAdded) {
      await manager.addPoiStyle(style);
    }
    Map<String, dynamic> payload = {
      "poi": <String, dynamic>{
        "id": id,
        "text": text,
        "clickable": true,
        "rank": rank,
        "styleId": style.id,
        "transform": transform?.value,
        "visible": visible,
      }
    };
    payload["poi"].addAll(position.toMessageable());
    String poiId = await _invokeMethod("addLodPoi", payload);
    final poi = LodPoi._(this, poiId,
        transform: transform,
        position: position,
        style: style,
        text: text,
        rank: rank ?? 0,
        visible: visible,
        onClick: onClick);
    _poi[poiId] = poi;
    return poi;
  }

  /// 입력된 [id]에 따라 지도에 그려진 [LodPoi]를 불러옵니다.
  LodPoi? getLodPoi(String id) {
    return _poi[id];
  }

  /// 입력된 [poi]에 따라 지도에 그려진 [LodPoi]를 삭제합니다.
  Future<void> removeLodPoi(LodPoi poi) async {
    await _invokeMethod("removeLodPoi", {
      "poiId": poi.id,
    });
    _poi.remove(poi.id);
  }

  /// 컨트롤러에 속한 모든 [LodPoi]가 지도에서 보여지도록 합니다.
  Future<void> showAllLodPoi() async {
    await _invokeMethod("changeVisibleAllLodPoi", {"visible": true});
  }

  /// 컨트롤러에 속한 모든 [LodPoi]가 지도에서 숨겨지도록 합니다.
  Future<void> hideAllLodPoi() async {
    await _invokeMethod("changeVisibleAllLodPoi", {"visible": false});
  }

  /// 컨트롤러에 의해 그려진 [LodPoi]의 개수를 불러옵니다.
  int get poiCount => _poi.length;

  static const String defaultId = "lodLabel_default_layer";
  static const double defaultRadius = 20.0;
}
