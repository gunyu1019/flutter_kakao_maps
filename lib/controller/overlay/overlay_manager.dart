part of '../../kakao_map_sdk.dart';

/// 오버레이(Poi, 도형, 경로선 등)을 관리할 때 사용하는 객체입니다.
mixin OverlayManager {
  MethodChannel get overlayChannel;

  // Controller
  final Map<String, LabelController> _labelController = {};
  final Map<String, LodLabelController> _lodLabelController = {};
  final Map<String, ShapeController> _shapeController = {};
  final Map<String, RouteController> _routeController = {};
  // final DimController _dimController;
  // final TrackingController _trackingController;

  // Overlay Style
  final Map<String, PoiStyle> _poiStyle = {};
  final Map<String, List<PolygonStyle>> _polygonStyle = {};
  final Map<String, List<PolylineStyle>> _polylineStyle = {};
  final Map<String, List<RouteStyle>> _routeStyle = {};

  /// Poi 스타일을 등록합니다. [style] 매개변수에는 Poi에 사용될 스타일 객체([PoiStyle])가 입력됩니다.
  /// 등록한 Poi 스타일은 [Poi]와 [LodPoi]에서 사용할 수 있습니다.
  /// 메소드를 사용하면 등록된 스타일의 고유ID가 반환됩니다.
  Future<String> addPoiStyle(PoiStyle style);

  /// 고유 ID를 통해 Poi 스타일 객체를 불러옵니다.
  PoiStyle? getPoiStyle(String id);

  /// Polygon Shape 스타일을 등록합니다. [style] 매개변수에는 Polygon 도형에서 사용될 스타일 객체([PolygonStyle])이 입력됩니다.
  /// 등록된 Polygon Shape 스타일은 [PolygonShape]에서 사용됩니다.
  /// 메소드를 사용하면 등록된 스타일의 고유ID가 반환됩니다.
  Future<String> addPolygonShapeStyle(PolygonStyle style);

  /// Polygon Shape 스타일을 등록합니다. [style] 매개변수에는 Polygon 도형에서 사용될 스타일 객체([PolylineStyle])이 입력됩니다.
  /// 등록된 Polygon Shape 스타일은 [PolylineShape]에서 사용됩니다.
  /// [polylineCap] 매개변수는 Polyline 도형의 꼭지점을 설정합니다.
  /// 메소드를 사용하면 등록된 스타일의 고유ID가 반환됩니다.
  Future<String> addPolylineShapeStyle(
      PolylineStyle style, PolylineCap polylineCap);

  /// 고유 ID를 통해 Polygon Shape 스타일 객체를 불러옵니다.
  PolygonStyle? getPolygonShapeStyle(String id);

  /// 고유 ID를 통해 Polyline Shape 스타일 객체를 불러옵니다.
  PolylineStyle? getPolylineShapeStyle(String id);

  /// Multiple Polygon Shape의 스타일을 등록합니다. [style] 매개변수에는 다중 Polygon 도형에 사용될 스타일 객체를 배열 형태로 입력합니다.
  /// ID 값은 [id] 매개변수를 주어서 사전에 정의할 수 있지만, 입력하지 않으면 임의로 생성된 고유ID가 반환됩니다.
  Future<String> addMultiplePolygonShapeStyle(List<PolygonStyle> style,
      [String? id]);

  /// Multiple Polyline Shape의 스타일을 등록합니다. [style] 매개변수에는 다중 Polyline 도형에 사용될 스타일 객체를 배열 형태로 입력합니다.
  /// ID 값은 [id] 매개변수를 주어서 사전에 정의할 수 있지만, 입력하지 않으면 임의로 생성된 고유ID가 반환됩니다.
  Future<String> addMultiplePolylineShapeStyle(
      List<PolylineStyle> style, PolylineCap polylineCap,
      [String? id]);

  /// 고유 ID를 통해 Multiple Polygon 스타일 객체를 불러옵니다.
  List<PolygonStyle>? getMultiplePolygonShapeStyle(String id);

  /// 고유 ID를 통해 Multiple Polyline 스타일 객체를 불러옵니다.
  List<PolylineStyle>? getMultiplePolylineShapeStyle(String id);

  /// Route 스타일을 등록합니다. [style] 매개변수에는 경로선 스타일에 사용되는 스타일 객체([RouteStyle])가 입력됩니다.
  /// 등록된 Route Style은 [Route]에서 사용됩니다.
  /// 메소드를 사용하면 등록된 스타일의 고유ID가 반환됩니다.
  Future<String> addRouteStyle(RouteStyle style);

  /// 고유 ID를 통해 Route 스타일 객체를 불러옵니다.
  RouteStyle? getRotueStyle(String id);

  /// 다중 Route 스타일을 등록합니다. [style] 매개변수에는 경로선 스타일에 사용되는 스타일 객체([RouteStyle])가 배열 형태로 입력됩니다.
  /// 등록된 Route Style은 [MultipleRoute]에서 사용됩니다.
  /// ID 값은 [id] 매개변수를 주어서 사전에 정의할 수 있지만, 입력하지 않으면 임의로 생성된 고유ID가 반환됩니다.
  /// 배열에 등록된 순서로 [MultipleRouteOption.addRouteWithIndex] 메소드에서 index 값으로 경로선의 스타일을 정의할 수 있습니다.
  Future<String> addMultipleRouteStyle(List<RouteStyle> styles, [String? id]);

  /// 고유 ID를 통해 Multiple Route 스타일 객체를 불러옵니다.
  List<RouteStyle>? getMultipleRotueStyle(String id);

  void _initalizeOverlayController() {
    _labelController[LabelController.defaultId] =
        LabelController._(overlayChannel, this, LabelController.defaultId);
    _lodLabelController[LodLabelController.defaultId] = LodLabelController._(
        overlayChannel, this, LodLabelController.defaultId);
    _shapeController[ShapeController.defaultId] =
        ShapeController._(overlayChannel, this, ShapeController.defaultId);
    _routeController[RouteController.defaultId] =
        RouteController._(overlayChannel, this, RouteController.defaultId);
  }

  /// 매개변수에 따라 설정된 LabelLayer([LabelController])를 추가합니다.
  /// LabelLayer는 Poi와 PolylineText를 관리하는 단위로 새로운 Poi 또는 PolylineText를 생성하거나 삭제할 수 있습니다.
  Future<LabelController> addLabelLayer(String id,
      {CompetitionType competitionType =
          BaseLabelController.defaultCompetitionType,
      CompetitionUnit competitionUnit =
          BaseLabelController.defaultCompetitionUnit,
      OrderingType orderingType = BaseLabelController.defaultOrderingType,
      int zOrder = BaseLabelController.defaultZOrder});

  /// 매개변수에 따라 설정된 LodLabelLayer([LodLabelController])를 추가합니다.
  /// LodLabellayer는 LodPoi를 관리하는 단위로 LodPoi를 생성하거나 삭제할 수 있습니다.
  Future<LodLabelController> addLodLabelLayer(String id,
      {CompetitionType competitionType =
          BaseLabelController.defaultCompetitionType,
      CompetitionUnit competitionUnit =
          BaseLabelController.defaultCompetitionUnit,
      OrderingType orderingType = BaseLabelController.defaultOrderingType,
      double radius = LodLabelController.defaultRadius,
      int zOrder = BaseLabelController.defaultZOrder});

  /// 매개변수에 따라 설정된 ShapeLayer([ShapeController])를 추가합니다.
  /// ShapeLayer는 [PolygonShape]와 [PolylineShape]를 관리하는 단위로 PolygonShape 또는 PolylineShape를 생성하거나 삭제할 수 있습니다.
  Future<ShapeController> addShapeLayer(String id,
      {ShapeLayerPass passType = ShapeController.defaultShapeLayerPass,
      int zOrder = ShapeController.defaultZOrder});

  /// 매개변수에 따라 설정된 RouteLayer([RouteController])를 추가합니다.
  /// RouteLayer는 [Route]와 [MultipleRoute]를 관리하는 단위로 Route 또는 MultipleROute를 생성하거나 삭제할 수 있습니다.
  Future<RouteController> addRouteLayer(String id,
      {int zOrder = RouteController.defaultZOrder});

  /// [id]에 해당되는 LabelLayer([LabelController])를 가져옵니다.
  /// [id]에 해당되는 LabelLayer가 없으면, [null]를 반환합니다.
  LabelController? getLabelLayer(String id);

  /// [id]에 해당되는 LodLabelLayer([LodLabelController])를 가져옵니다.
  /// [id]에 해당되는 LodLabelLayer 없으면, [null]를 반환합니다.
  LodLabelController? getLodLabelLayer(String id);

  /// [id]에 해당되는 ShapeLayer([ShapeLayer])를 가져옵니다.
  /// [id]에 해당되는 ShapeLayer 없으면, [null]를 반환합니다.
  ShapeController? getShapeLayer(String id);

  /// [id]에 해당되는 RouteLayer([RouteLayer])를 가져옵니다.
  /// [id]에 해당되는 RouteLayer 없으면, [null]를 반환합니다.
  RouteController? getRouteLayer(String id);

  /// [id]에 따라 생성된 LabelLayer([LabelController])를 삭제합니다.
  Future<void> removeLabelLayer(LabelController controller);

  /// [id]에 따라 생성된 LodLabelLayer([LodLabelController])를 삭제합니다.
  Future<void> removeLodLabelLayer(LodLabelController controller);

  /// [id]에 따라 생성된 ShapeLayer([ShapeController])를 삭제합니다.
  Future<void> removeShapeLayer(ShapeController controller);

  /// [id]에 따라 생성된 RouteLayer([RouteController])를 삭제합니다.
  Future<void> removeRouteLayer(RouteController controller);

  /// 기본으로 생성된 LabelLayer([LabelController])를 가져옵니다.
  LabelController get labelLayer;

  /// 기본으로 생성된 LodLabelLayer([LodLabelController])를 가져옵니다.
  LodLabelController get lodLabelLayer;

  /// 기본으로 생성된 ShapeLayer([ShapeController])를 가져옵니다.
  ShapeController get shapeLayer;

  /// 기본으로 생성된 RouteLayer([RouteController])를 가져옵니다.
  RouteController get routeLayer;
}
