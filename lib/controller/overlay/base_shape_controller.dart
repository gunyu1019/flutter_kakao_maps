part of '../../kakao_map_sdk.dart';

/// [Poi], [LodPoi], [PolylineText] 개체를 관리하는 컨트롤러를 구현하기 위한 추성 클래스입니다.
/// 지도에 [Poi], [LodPoi], [PolylineText] 개체를 관리하기 위해 필수로 필요한 요소를 관리합니다.
abstract class BaseShapeController extends OverlayController {
  /// [ShapeController]에서 사용되는 고유 ID 입니다.
  /// [DimScreenController]에서 사용되지 않습니다.
  abstract final String id;

  BaseShapeController._();

  Future<void> _changePolylineVisible(String shapeId, bool visible) async {
    await _invokeMethod("changePolylineVisible", {
      "polylineId": shapeId,
      "visible": visible,
    });
  }

  Future<void> _changePolygonVisible(String shapeId, bool visible) async {
    await _invokeMethod("changePolygonVisible", {
      "polygonId": shapeId,
      "visible": visible,
    });
  }

  Future<void> _changePolyline<T extends BasePoint>(
    String shapeId,
    T position,
    String styleId,
  ) async {
    await _invokeMethod("changePolyline", {
      "polylineId": shapeId,
      "styleId": styleId,
      "position": position.toMessageable(),
    });
  }

  Future<void> _changePolygon<T extends BasePoint>(
    String shapeId,
    T position,
    String styleId,
  ) async {
    await _invokeMethod("changePolygon", {
      "polygonId": shapeId,
      "styleId": styleId,
      "position": position.toMessageable(),
    });
  }

  /// 입력된 [shape]에 따라 지도에 그려진 [Polygon]를 삭제합니다.
  Future<void> removePolygonShape(Polygon shape);

  /// 입력된 [shape]에 따라 지도에 그려진 [Polyline]를 삭제합니다.
  Future<void> removePolylineShape(Polyline shape);
}
