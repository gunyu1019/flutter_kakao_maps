part of '../../kakao_map_sdk.dart';

/// 지도에 [Poi]를 나타내는 객체입니다.
/// [Poi]는 특정 텍스트 또는 이미지를 지도에 표현하는 오버레이입니다.
class Poi with BadgeablePoi {
  @override
  final LabelController _controller;

  /// [Poi]의 고유 ID입니다.
  @override
  final String id;

  /// [Poi]가 나타나거나 사라질 때 적용되는 애니메이션입니다.
  final TransformMethod? transform;

  LatLng _position;

  /// [Poi]의 위치입니다.
  LatLng get position => _position;

  /// [Poi]를 클릭하였을 때, 호출되는 함수입니다.
  void Function()? onClick;

  /// [Poi]의 [onClick]이 정의되어 클릭할 수 있는지 반환합니다.
  bool get clickable => onClick != null;

  String? _text;

  /// [Poi]에 설정된 텍스트입니다.
  String? get text => _text;

  int _rank;

  /// [Poi]의 렌더링 우선순위입니다.
  int get rank => _rank;

  PoiStyle _style;

  /// [Poi]에 정의된 [PoiStyle] 객체입니다.
  PoiStyle get style => _style;

  bool _visible;

  /// [Poi]가 현재 지도에 그려지는지 여부를 나타냅니다.
  bool get visible => _visible;

  final Map<String, Poi> _sharePositionPoi = {};
  final Map<String, Poi> _shareTransformPoi = {};
  final Map<String, Shape> _shareTransformShape = {};

  /// [Poi]와 위치를 공유받고 있는 다른 [Poi]를 불러옵니다.
  List<Poi> get sharePosition => List.unmodifiable(_sharePositionPoi.values);

  /// [Poi]와 회전 값, 위치 값을 공유받고 있는 다른 [Poi]를 불러옵니다.
  List<Poi> get shareTransformPoi =>
      List.unmodifiable(_shareTransformPoi.values);

  /// [Poi]와 회전 값, 위치 값을 공유받고 있는 다른 [Polygon], [Polyline]를 불러옵니다.
  List<Shape> get shareTransformShape =>
      List.unmodifiable(_shareTransformShape.values);

  Poi._(
    this._controller,
    this.id, {
    required this.transform,
    required LatLng position,
    required PoiStyle style,
    required String? text,
    required int rank,
    required bool visible,
    this.onClick,
  })  : _position = position,
        _style = style,
        _text = text,
        _rank = rank,
        _visible = visible;

  Future<void> addSharePosition(Poi poi) async {
    _sharePositionPoi[poi.id] = poi;
    await _controller._addSharePositionPoi(id, poi);
  }

  Future<void> addShareTransformPoi(Poi poi) async {
    _shareTransformPoi[poi.id] = poi;
    await _controller._addShareTransformPoi(id, poi);
  }

  Future<void> addShareTransformShape(Shape shape) async {
    _shareTransformShape[shape.id] = shape;
    await _controller._addShareTransformShape(id, shape);
  }

  Future<void> removeSharePosition(Poi poi) async {
    _sharePositionPoi.remove(poi.id);
    await _controller._removeSharePositionPoi(id, poi);
  }

  Future<void> removeShareTransformPoi(Poi poi) async {
    _shareTransformPoi.remove(poi.id);
    await _controller._removeShareTransformPoi(id, poi);
  }

  Future<void> removeShareTransformShape(Shape shape) async {
    _shareTransformShape.remove(shape.id);
    await _controller._removeShareTransformShape(id, shape);
  }

  /// [Poi]가 [x]와 [y]에 따라 픽셀만큼 높여서 그립니다.
  Future<void> changeOffsetPosition(
    double x,
    double y, [
    bool forceDpScale = false,
  ]) async {
    final prePosition = _position;
    _position = LatLng(prePosition.latitude + x, prePosition.longitude + y);
    await _controller._changePoiOffsetPosition(id, x, y, forceDpScale);
  }

  /// [Poi]의 [rank]를 즉시 변경합니다.
  Future<void> changeRank(int rank) async {
    _rank = rank;
    await _controller._rankPoi(id, rank);
  }

  /// [Poi]에 적용된 [PoiStyle]을 즉시 변경합니다.
  /// [transition] 매개변수에 따라 [PoiStyle.iconTransition]과 [PoiStyle.textTransition]를 적용할 지 설정합니다.
  Future<void> changeStyles(PoiStyle style, [bool transition = false]) async {
    if (!style._isAdded) {
      await _controller.manager.addPoiStyle(style);
    }
    await _controller._changePoiStyle(id, style.id!, transition);
    _style = style;
  }

  /// [Poi]에서 노출되고 있는 텍스트를 즉시 변경합니다.
  /// [transition] 매개변수에 따라 [PoiStyle.textTransition]를 적용할 지 설정합니다.
  Future<void> changeText(String text, [bool transition = false]) async {
    _text = text;
    await _controller._changePoiText(id, text, _style.id!, transition);
  }

  /// [Poi]를 지도에서 노출되지 않도록 합니다.
  Future<void> hide() async {
    _visible = false;
    await _controller._changePoiVisible(id, false);
  }

  /// [Poi]에 새롭게 설정한 [Poi.style]와 [Poi.text]를 업데이트합니다.
  Future<void> invalidate([bool transition = false]) async {
    final styleId = style.id ?? await _controller.manager.addPoiStyle(style);
    await _controller._invalidatePoi(id, styleId, text, transition);
  }

  /// [Poi]를 [position]으로 이동시킵니다.
  /// [millis] 매개변수를 설정하면 설정된 밀리초 이내로 이동하는 애니메이션을 적용합니다.
  Future<void> move(LatLng position, [int? millis]) async {
    _position = position;
    await _controller._movePoi(id, position, millis);
  }

  /// [Poi]를 [path]에 따라 [millis]밀리초 이내 이동합니다.
  /// [cornerRadius] 매개변수는 곡선 구간(코너)를 통과할 때 부드러운 이동 효과를 주기 위한 길이를 의미합니다.
  /// [jumpThreshold] 매개변수는 함수가 실행 중에 새로운 경로가 입력되었을 때, 현재위치~새 경로 시작점간에 거리에서 점프할 지에 대한 임계 값을 의미합니다.
  Future<void> movePath(
    List<LatLng> path,
    int millis, {
    double cornerRadius = 40.0,
    double jumpThreshold = 200.0,
  }) async {
    if (path.isEmpty) {
      throw Exception("The Path parameter is empty.");
    }
    _position = path.last;
    await _controller._movePathPoi(
      id,
      path,
      millis,
      cornerRadius: cornerRadius,
      jumpThreshold: jumpThreshold,
    );
  }

  /// [Poi]를 [path]에 따라 [millis]밀리초 이내 이동합니다.
  /// [baseRadian] 매개변수는 path가 하나 뿐이거나, 진행 방향의 역방향으로 경로가 입력되어 방향을 알 수 없을 때 입력되는 각도입니다.
  /// [cornerRadius] 매개변수는 곡선 구간(코너)를 통과할 때 부드러운 이동 효과를 주기 위한 길이를 의미합니다.
  /// [jumpThreshold] 매개변수는 함수가 실행 중에 새로운 경로가 입력되었을 때, 현재위치~새 경로 시작점간에 거리에서 점프할 지에 대한 임계 값을 의미합니다.
  Future<void> movePathWithRotate(
    List<LatLng> path,
    double baseRadian,
    int millis, {
    double cornerRadius = 40.0,
    double jumpThreshold = 200.0,
  }) async {
    if (path.isEmpty) {
      throw Exception("The Path parameter is empty.");
    }
    _position = path.last;
    await _controller._movePathPoi(
      id,
      path,
      millis,
      baseRadian: baseRadian,
      cornerRadius: cornerRadius,
      jumpThreshold: jumpThreshold,
    );
  }

  /// [Poi] 개체를 삭제합니다.
  Future<void> remove() async {
    await _controller.removePoi(this);
  }

  /// [Poi]를 주어진 [angle]에 따라 회전합니다.
  /// [millis] 매개변수를 설정하면 설정된 밀리초 이내로 회전하는 애니메이션을 적용합니다.
  Future<void> rotate(double angle, [double? millis]) async {
    await _controller._rotatePoi(id, angle, millis);
  }

  Future<void> scale(double x, double y, [double? millis]) async {
    await _controller._scalePoi(id, x, y, millis);
  }

  /// [Poi]의 [style]을 새롭게 정의합니다.
  /// 정의한 [style]은 [Poi.invalidate] 메소드를 이용하여 갱신할 수 있습니다.
  void setStyle(PoiStyle style) async {
    _style = style;
  }

  /// [Poi]의 [text]을 새롭게 정의합니다.
  /// 정의한 [text]은 [Poi.invalidate] 메소드를 이용하여 갱신할 수 있습니다.
  void setText(String text) {
    _text = text;
  }

  /// [Poi]를 지도에서 보이도록 합니다.
  /// [autoMove] 매개변수가 [true] 값이면 해당 위치로 카메라를 이동합니다.
  /// (Android 한정) [autoMove]가 참이고, [duration]이 부여되면 지정된 시간 이내로 카메라를 이동시킵니다.
  Future<void> show([bool? autoMove, int? duration]) async {
    _visible = true;
    await _controller._changePoiVisible(
      id,
      true,
      autoMove: autoMove,
      duration: duration,
    );
  }
}
