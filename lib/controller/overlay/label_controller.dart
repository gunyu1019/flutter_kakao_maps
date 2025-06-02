part of '../../kakao_map_sdk.dart';

/// 지도에 [Poi]과 [PolylineText]를 생성하거나 삭제하는 등의 개체 관리를 할 수 있는 컨트롤러입닌다.
class LabelController extends BaseLabelController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.label;

  @override
  final String id;

  final Map<String, Poi> _poi = {};
  final Map<String, PolylineText> _polylineText = {};

  LabelController._(this.channel, this.manager, this.id,
      {competitionType = BaseLabelController.defaultCompetitionType,
      competitionUnit = BaseLabelController.defaultCompetitionUnit,
      orderingType = BaseLabelController.defaultOrderingType,
      bool visible = true,
      bool clickable = true,
      int zOrder = BaseLabelController.defaultZOrder})
      : super._(competitionType, competitionUnit, orderingType, visible,
            clickable, zOrder);

  Future<void> _createLabelLayer() async {
    await _invokeMethod("createLabelLayer", {
      "competitionType": competitionType.value,
      "competitionUnit": competitionUnit.value,
      "orderingType": orderingType.value,
      "zOrder": zOrder,
      "visable": visible,
      "clickable": _clickable,
    });
  }

  Future<void> _removeLabelLayer() async {
    await _invokeMethod("removeLabelLayer", {});
  }

  Future<void> _changePoiOffsetPosition(
      String poiId, double x, double y, bool forceDpScale) async {
    await _invokeMethod("changePoiOffsetPosition",
        {"poiId": poiId, "x": x, "y": y, "forceDpScale": forceDpScale});
  }

  Future<void> _changePoiVisible(String poiId, bool visible,
      {bool? autoMove, int? duration}) async {
    await _invokeMethod("changePoiVisible", {
      "poiId": poiId,
      "visible": visible,
      "autoMove": autoMove,
      "duration": duration
    });
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

  Future<void> _invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]) async {
    await _invokeMethod("invalidatePoi", {
      "poiId": poiId,
      "styleId": styleId,
      "text": text,
      "transition": transition
    });
  }

  Future<void> _movePoi(String poiId, LatLng position, [double? millis]) async {
    final payload = {"poiId": poiId, "millis": millis};
    payload.addAll(position.toMessageable());
    await _invokeMethod("movePoi", payload);
  }

  Future<void> _rotatePoi(String poiId, double angle, [double? millis]) async {
    await _invokeMethod(
        "rotatePoi", {"poiId": poiId, "angle": angle, "millis": millis});
  }

  Future<void> _scalePoi(String poiId, double x, double y,
      [double? millis]) async {
    await _invokeMethod(
        "scalePoi", {"poiId": poiId, "x": x, "y": y, "millis": millis});
  }

  Future<void> _rankPoi(String poiId, int rank) async {
    await _invokeMethod("rankPoi", {"poiId": poiId, "rank": rank});
  }

  Future<void> _changePolylineTextStyle(String poiId, PolylineTextStyle style,
      [String? text]) async {
    await _invokeMethod("changePolylineTextStyle",
        {"poiId": poiId, "styles": style.toMessageable(), "text": text});
  }

  Future<void> _changePolylineTextVisible(String labelId, bool visible) async {
    await _invokeMethod(
        "changePolylineTextVisible", {"labelId": labelId, "visible": visible});
  }

  /// 지도에 새로운 [Poi]를 그립니다.
  /// [Poi]를 그리기 위해서는 위치([position])와 스타일([style])이 필수로 입력되어야 합니다.
  Future<Poi> addPoi(
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
        "clickable": true,
        "text": text,
        "rank": rank,
        "styleId": style.id,
        "transform": transform?.value,
        "visible": visible,
      }
    };
    payload["poi"].addAll(position.toMessageable());
    String poiId = await _invokeMethod("addPoi", payload);
    final poi = Poi._(this, poiId,
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

  /// 입력된 [id]에 따라 지도에 그려진 [Poi]를 불러옵니다.
  Poi? getPoi(String id) {
    return _poi[id];
  }

  /// 입력된 [poi]에 따라 지도에 그려진 [Poi]를 삭제합니다.
  Future<void> removePoi(Poi poi) async {
    await _invokeMethod("removePoi", {
      "poiId": poi.id,
    });
    _poi.remove(poi.id);
  }

  /// 컨트롤러에 속한 모든 [Poi]가 지도에서 보여지도록 합니다.
  Future<void> showAllPoi() async {
    await _invokeMethod("changeVisibleAllPoi", {"visible": true});
  }

  /// 컨트롤러에 속한 모든 [Poi]가 지도에서 숨겨지도록 합니다.
  Future<void> hideAllPoi() async {
    await _invokeMethod("changeVisibleAllPoi", {"visible": false});
  }

  /// 지도에 새로운 [PolylineText]를 그립니다.
  /// [PolylineText]를 지도에 그리기 위해서는 지도에 표현하기 위한 글씨([text])와
  /// 구부러진 지도를 표시할 위치([position]),
  /// 글씨의 스타일([style])이 필수로 입력되어야 합니다.
  Future<PolylineText> addPolylineText(
    String text,
    List<LatLng> position, {
    required PolylineTextStyle style,
    String? id,
    bool visible = true,
  }) async {
    if (id != null && _polylineText.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    Map<String, dynamic> payload = {
      "label": <String, dynamic>{
        "position": position.map((e) => e.toMessageable()).toList(),
        "style": style.toMessageable(),
        "id": id,
        "text": text,
        "visible": visible
      }
    };
    String labelId = await _invokeMethod("addPolylineText", payload);
    final label = PolylineText._(this, labelId,
        style: style, text: text, points: position);
    _polylineText[labelId] = label;
    return label;
  }

  /// 입력된 [id]에 따라 지도에 그려진 [PolylineText]를 불러옵니다.
  PolylineText? getPolylineText(String id) {
    return _polylineText[id];
  }

  /// 입력된 [label]에 따라 지도에 그려진 [PolylineText]를 삭제합니다.
  Future<void> removePolylineText(PolylineText label) async {
    await _invokeMethod("removePolylineText", {
      "labelId": label.id,
    });
    _polylineText.remove(label.id);
  }

  /// 컨트롤러에 속한 모든 [PolylineText]가 지도에서 보여지도록 합니다.
  Future<void> showAllPolylineText() async {
    await _invokeMethod("changeVisibleAllPolylineText", {"visible": true});
  }

  /// 컨트롤러에 속한 모든 [PolylineText]가 지도에서 숨겨지도록 합니다.
  Future<void> hideAllPolylineText() async {
    await _invokeMethod("changeVisibleAllPolylineText", {"visible": false});
  }

  /// 컨트롤러에 의해 그려진 [Poi]의 개수를 불러옵니다.
  int get poiCount => _poi.length;

  /// 컨트롤러에 의해 그려진 [PolylineText]의 개수를 불러옵니다.
  int get polylineCount => _polylineText.length;

  static const String defaultId = "label_default_layer";
}
