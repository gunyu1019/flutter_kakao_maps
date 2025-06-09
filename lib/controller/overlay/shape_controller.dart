part of '../../kakao_map_sdk.dart';

/// 지도에 [Polyline] 또는 [Polygon]를 생성하거나 삭제하는 등의 개체 관리를 할 수 있는 컨트롤러입니다.
class ShapeController extends OverlayController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.shape;

  /// [ShapeController]의 고유 ID입니다.
  final String id;

  /// [ShapeController]가 지도에 표시되는 다른 오버레이와 겹치면 그려지는 우선순위를 정의합니다.
  final ShapeLayerPass passType;

  /// 렌더링의 우선순위를 정의합니다.
  final int zOrder;

  final Map<String, Polyline> _polylineShape = {};
  final Map<String, Polygon> _polygonShape = {};

  ShapeController._(this.channel, this.manager, this.id,
      {this.passType = defaultShapeLayerPass, this.zOrder = defaultZOrder});

  Future<void> _createShapeLayer() async {
    await _invokeMethod(
        "createShapeLayer", {"passType": passType.value, "zOrder": zOrder});
  }

  Future<void> _removeShapeLayer() async {
    await _invokeMethod("removeShapeLayer", {});
  }

  Future<void> _changePolylineVisible(String shapeId, bool visible) async {
    await _invokeMethod(
        "changePolylineVisible", {"polylineId": shapeId, "visible": visible});
  }

  Future<void> _changePolygonVisible(String shapeId, bool visible) async {
    await _invokeMethod(
        "changePolygonVisible", {"polygonId": shapeId, "visible": visible});
  }

  Future<void> _changePolyline<T extends BasePoint>(
      String shapeId, T position, String styleId) async {
    await _invokeMethod("changePolyline", {
      "polylineId": shapeId,
      "styleId": styleId,
      "position": position.toMessageable()
    });
  }

  Future<void> _changePolygon<T extends BasePoint>(
      String shapeId, T position, String styleId) async {
    await _invokeMethod("changePolygon", {
      "polygonId": shapeId,
      "styleId": styleId,
      "position": position.toMessageable()
    });
  }

  @override
  Future<T> _invokeMethod<T>(String method, Map<String, dynamic> payload) {
    payload['layerId'] = id;
    return super._invokeMethod(method, payload);
  }

  /// 지도에 새로운 도형([Polyline])을 그립니다.
  /// [Polygon]을 그리기 위해서는 도형을 그릴 위치([position])과 스타일([style]), [polylineCap]이 필수로 입력되어야 합니다.
  /// [position]은 절대 위치([MapPoint])가 입력될 수 있고, 상대위치([CirclePoint], [RectanglePoint])가 입력될 수 있습니다.
  Future<Polyline> addPolylineShape<T extends BasePoint>(
      T position, PolylineStyle style, PolylineCap polylineCap,
      {String? id, int zOrder = 10001}) async {
    if (id != null && _polygonShape.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }

    if (!style._isAdded) {
      await manager.addPolylineShapeStyle(style, polylineCap);
    }
    final payload = <String, dynamic>{
      "polyline": <String, dynamic>{
        "id": id,
        "position": position.toMessageable(),
        "styleId": style.id,
        "zOrder": zOrder
      }
    };
    String shapeId = await _invokeMethod("addPolylineShape", payload);
    final polyline = Polyline<T>._(this, shapeId,
        position: position, style: style, polylineCap: polylineCap);
    _polylineShape[shapeId] = polyline;
    return polyline;
  }

  /// 지도에 새로운 도형([Polygon])을 그립니다.
  /// [Polygon]을 그리기 위해서는 도형을 그릴 위치([position])과 스타일([style])이 필수로 입력되어야 합니다.
  /// [position]은 절대 위치([MapPoint])가 입력될 수 있고, 상대위치([CirclePoint], [RectanglePoint])가 입력될 수 있습니다.
  Future<Polygon> addPolygonShape<T extends BasePoint>(
      T position, PolygonStyle style,
      {String? id, int zOrder = 10001}) async {
    if (id != null && _polygonShape.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final styleId = style._id ?? await manager.addPolygonShapeStyle(style);
    final payload = <String, dynamic>{
      "polygon": <String, dynamic>{
        "id": id,
        "position": position.toMessageable(),
        "styleId": styleId,
        "zOrder": zOrder
      }
    };
    String shapeId = await _invokeMethod("addPolygonShape", payload);
    final polygon =
        Polygon<T>._(this, shapeId, position: position, style: style);
    _polygonShape[shapeId] = polygon;
    return polygon;
  }

  /// 입력된 [id]에 따라 지도에 그려진 [Polyline]를 불러옵니다.
  Polyline? getPolylineShape(String id) => _polylineShape[id];

  /// 입력된 [id]에 따라 지도에 그려진 [Polygon]를 불러옵니다.
  Polygon? getPolygonShape(String id) => _polygonShape[id];

  /// 입력된 [shape]에 따라 지도에 그려진 [Polyline]를 삭제합니다.
  Future<void> removePolylineShape(Polyline shape) async {
    await _invokeMethod("removePolylineShape", {"polylineId": shape.id});
    _polylineShape.remove(shape.id);
  }

  /// 입력된 [shape]에 따라 지도에 그려진 [Polygon]를 삭제합니다.
  Future<void> removePolygonShape(Polygon shape) async {
    await _invokeMethod("removePolygonShape", {"polygonId": shape.id});
    _polygonShape.remove(shape.id);
  }

  /// 컨트롤러에 속한 모든 [Polyline]가 지도에서 보여지도록 합니다.
  Future<void> showAllPolyline() async {
    await _invokeMethod("changeVisibleAllPolyline", {"visible": true});
  }

  /// 컨트롤러에 속한 모든 [Polyline]가 지도에서 보여지도록 합니다.
  Future<void> hideAllPolyline() async {
    await _invokeMethod("changeVisibleAllPolyline", {"visible": false});
  }

  /// 컨트롤러에 속한 모든 [Polygon]가 지도에서 보여지도록 합니다.
  Future<void> showAllPolygon() async {
    await _invokeMethod("changeVisibleAllPolygon", {"visible": true});
  }

  /// 컨트롤러에 속한 모든 [Polygon]가 지도에서 보여지도록 합니다.
  Future<void> hideAllPolygon() async {
    await _invokeMethod("changeVisibleAllPolygon", {"visible": false});
  }

  static const String defaultId = "vector_layer_0";
  static const int defaultZOrder = 10000;
  static const ShapeLayerPass defaultShapeLayerPass =
      ShapeLayerPass.defaultPass;
}
