part of '../../kakao_map_sdk.dart';

/// 지도의 일부분을 제외하고 특정 색상으로 가리는 것을 조작하는 컨트롤러입니다.
/// [MapPoint]와 [BaseDotPoint] 기반의 요소를 이용하여 지도의 일부분에 특정 색을 입히거나,
/// 특정 부분을 제외한 모든 부분을 색상을 입힐 수 있습니다.
class DimScreenController extends BaseShapeController {
  @override
  final String id = "dim_screen_layer"; // TEMPORARY ID (NOT USED)

  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.dimScreen;

  DimScreenController._(this.channel, this.manager) : super._();

  /// DimScreen의 색상입니다.
  Color get color => _color;
  Color _color = Colors.black.withAlpha(128);

  /// 지도에 DimScreen 덮을 범위입니다.
  DimScreenCover get cover => _cover;
  DimScreenCover _cover = DimScreenCover.all;

  /// 지도에 DimScreen의 활성화하여 지도에 그려져 있는 여부입니다.
  bool get visible => _visible;
  bool _visible = false;

  final Map<String, Polygon> _polygonShape = {};

  /// 지도를 덮을 범위를 설정합니다.
  Future<void> setCover(DimScreenCover cover) async {
    _cover = cover;
    await _invokeMethod("setCover", {"cover": cover.value});
  }

  /// DimScreen의 색상을 설정합니다.
  Future<void> setColor(Color color) async {
    _color = color;
    await _invokeMethod("setColor", {
      // ignore: deprecated_member_use
      "color": color.value,
    });
  }

  /// DimScreen을 지도에 나타낼지 설정합니다.
  Future<void> setVisible(bool visible) async {
    _visible = visible;
    await _invokeMethod("setVisible", {"visible": visible});
  }

  /// 지도를 덮고 있는 DimScreen에 [Polygon]을 추가하여 일부분을 지도에 보일 수 있도록 합니다.
  /// [Polygon]을 그리기 위해서는 도형을 그릴 위치([position])과 스타일([style])이 필수로 입력되어야 합니다.
  /// [position]은 절대 위치([MapPoint])가 입력될 수 있고, 상대위치([CirclePoint], [RectanglePoint])가 입력될 수 있습니다.
  Future<Polygon> addPolygonShape<T extends BasePoint>(
    T position,
    PolygonStyle style, {
    String? id,
  }) async {
    if (id != null && _polygonShape.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final styleId = style._id ?? await manager.addPolygonShapeStyle(style);
    final payload = <String, dynamic>{
      "polygon": <String, dynamic>{
        "id": id,
        "position": position.toMessageable(),
        "styleId": styleId,
      },
    };
    String shapeId = await _invokeMethod("addHighlightPolygonShape", payload);
    final polygon = Polygon<T>._(
      this,
      shapeId,
      position: position,
      style: style,
    );
    _polygonShape[shapeId] = polygon;
    return polygon;
  }

  /// 입력된 [id]에 DimScreen에 표출된 [Polygon]를 불러옵니다.
  Polygon? getPolygonShape(String id) => _polygonShape[id];

  @override
  Future<void> removePolygonShape(Polygon shape) async {
    await _invokeMethod("removeHighlightPolygonShape", {"polygonId": shape.id});
    _polygonShape.remove(shape.id);
  }

  @override
  Future<void> removePolylineShape(Polyline<BasePoint> shape) {
    throw UnimplementedError("Unused feature in dim screen");
  }
}
