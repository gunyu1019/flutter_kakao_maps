part of '../kakao_map_sdk_web.dart';

class WebDimScreenController with WebDimScreenControllerHandler {
  final WebMapController controller;

  @override
  final WebOverlayController manager;

  WebDimScreenController._(this.controller, this.manager);

  WebPolygon? _element;
  WebPolygonOption? _option;

  // 기본값: 반투명 검정(Colors.black.withAlpha(128))에 대응되는 값입니다.
  String _colorCode = "#000000";
  double _fillOpacity = 128 / 255;
  DimScreenCover _cover = DimScreenCover.all;
  bool _visible = false;

  final Map<String, WebDimHighlightShape> _highlightPolygon = {};
  int _nextHighlightOrder = 0;

  JSFunction? _boundsChangedCallbackRef;
  JSFunction? _zoomChangedCallbackRef;

  static const int _mapZIndex = 1;
  static const int _mapAndLabelZIndex = 10002;
  static const int _allZIndex = 10003;

  int get _zIndex => switch (_cover) {
        DimScreenCover.map => _mapZIndex,
        DimScreenCover.mapAndLabel => _mapAndLabelZIndex,
        DimScreenCover.all => _allZIndex,
      };

  @override
  Future<void> createDimScreenLayer() async {
    _boundsChangedCallbackRef = _boundsChangedEventHandler.toJS;
    _zoomChangedCallbackRef = _zoomChangedEventHandler.toJS;
    addEventListener(controller, "bounds_changed", _boundsChangedCallbackRef!);
    addEventListener(controller, "zoom_changed", _zoomChangedCallbackRef!);
  }

  @override
  Future<void> removeDimScreenLayer() async {
    if (_boundsChangedCallbackRef != null) {
      removeEventListener(
        controller,
        "bounds_changed",
        _boundsChangedCallbackRef!,
      );
      _boundsChangedCallbackRef = null;
    }
    if (_zoomChangedCallbackRef != null) {
      removeEventListener(
        controller,
        "zoom_changed",
        _zoomChangedCallbackRef!,
      );
      _zoomChangedCallbackRef = null;
    }
    _element?.setMap(null);
    _element = null;
    _option = null;
    for (final shape in _highlightPolygon.values) {
      shape.element?.setMap(null);
    }
    _highlightPolygon.clear();
  }

  void _boundsChangedEventHandler() {
    if (_element == null) return;
    _redraw();
  }

  void _zoomChangedEventHandler() => _syncAllHighlightElements();

  JSArray<WebLatLng> _outerRing() {
    final bound = controller.getBounds();
    final sw = bound.getSouthWest();
    final ne = bound.getNorthEast();

    final latSpan = (ne.getLat() - sw.getLat()).abs();
    final lngSpan = (ne.getLng() - sw.getLng()).abs();
    final latMargin = latSpan * 4 + 1;
    final lngMargin = lngSpan * 4 + 1;

    final south = (sw.getLat() - latMargin).clamp(-85.0, 85.0);
    final north = (ne.getLat() + latMargin).clamp(-85.0, 85.0);
    final west = sw.getLng() - lngMargin;
    final east = ne.getLng() + lngMargin;

    return [
      WebLatLng(south, west),
      WebLatLng(south, east),
      WebLatLng(north, east),
      WebLatLng(north, west),
      WebLatLng(south, west),
    ].toJS;
  }

  JSArray<JSArray<WebLatLng>> _buildPath() {
    final path = [_outerRing()];
    for (final shape in _highlightPolygon.values) {
      if (!shape.visible) continue;
      for (final ring in shape.point.rings) {
        path.add(ring.map(WebLatLng.fromLatLng).toList().toJS);
      }
    }
    return path.toJS;
  }

  void _redraw() {
    final path = _buildPath();
    if (_element == null) {
      _option = WebPolygonOption(
        path: path,
        fillColor: _colorCode,
        fillOpacity: _fillOpacity,
        strokeColor: _colorCode,
        strokeWeight: 0,
        strokeOpacity: 0,
        zIndex: _zIndex,
      );
      _element = WebPolygon(_option!);
      if (_visible) {
        _element!.setMap(controller);
      }
      return;
    }

    _option!.path = path;
    _option!.zIndex = _zIndex;
    _element!.setOptions(_option!);
  }

  WebPolygonOption _getHighlightElementOption(
    PolygonStyle style,
    JSArray<JSArray<WebLatLng>> path,
  ) {
    return WebPolygonOption(
      path: path,
      fillColor: _getColorCode(style.color),
      fillOpacity: style.color.a,
      strokeColor: _getColorCode(style.strokeColor),
      strokeWeight: style.strokeWidth,
      strokeOpacity: style.strokeColor.a,
      zIndex: _zIndex + 1,
    );
  }

  PolygonStyle _styleForCurrentZoom(PolygonStyle style) {
    final mapZoomLevel = controller.getLevel();
    var currentStyle = style;
    var currentZoomLevel = style.zoomLevel;
    for (final secondaryStyle in style.otherStyles) {
      if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
          secondaryStyle.zoomLevel >= currentZoomLevel) {
        currentZoomLevel = secondaryStyle.zoomLevel;
        currentStyle = secondaryStyle;
      }
    }
    return currentStyle;
  }

  void _syncHighlightElement(WebDimHighlightShape shape) {
    if (!shape.visible || !_visible) {
      shape.element?.setMap(null);
      return;
    }

    final path = shape.point.toPolygonPath();
    final style = _styleForCurrentZoom(shape.style);
    final zIndex = _highlightZIndex(shape);
    if (shape.element == null) {
      shape.option = _getHighlightElementOption(style, path);
      shape.option!.zIndex = zIndex;
      shape.element = WebPolygon(shape.option!);
      shape.element!.setMap(controller);
      return;
    }

    shape.option!.path = path;
    shape.option!.fillColor = _getColorCode(style.color);
    shape.option!.fillOpacity = style.color.a;
    shape.option!.strokeColor = _getColorCode(style.strokeColor);
    shape.option!.strokeWeight = style.strokeWidth;
    shape.option!.strokeOpacity = style.strokeColor.a;
    shape.option!.zIndex = zIndex;
    shape.element!.setOptions(shape.option!);
    shape.element!.setMap(controller);
  }

  void _syncAllHighlightElements() {
    for (final shape in _highlightPolygon.values) {
      _syncHighlightElement(shape);
    }
  }

  int _highlightZIndex(WebDimHighlightShape shape) {
    final orderedShapes = _highlightPolygon.values.toList()
      ..sort((first, second) {
        final zOrderComparison = first.zOrder.compareTo(second.zOrder);
        return zOrderComparison != 0
            ? zOrderComparison
            : first.insertionOrder.compareTo(second.insertionOrder);
      });
    return _zIndex + 1 + orderedShapes.indexOf(shape);
  }

  @override
  Future<void> setDimColor(int color) async {
    // ignore: deprecated_member_use
    final flutterColor = Color(color);
    _colorCode = _getColorCode(flutterColor);
    _fillOpacity = flutterColor.a;
    _redraw();
  }

  @override
  Future<void> setDimVisible(bool visible) async {
    _visible = visible;
    if (_element == null) {
      _redraw();
    }
    _element?.setMap(visible ? controller : null);
    _syncAllHighlightElements();
  }

  @override
  Future<void> setDimCover(DimScreenCover cover) async {
    _cover = cover;
    _redraw();
    _syncAllHighlightElements();
  }

  @override
  Future<String> addHighlightPolygonShape(
    WebShapePoint point,
    PolygonStyle style, {
    String? id,
    int zOrder = 10001,
  }) async {
    final shapeId = id ?? manager._uuid.v4();
    final shape = WebDimHighlightShape(
      point,
      style,
      shapeId,
      zOrder,
      _nextHighlightOrder++,
    );
    _highlightPolygon[shapeId] = shape;
    _redraw();
    _syncAllHighlightElements();
    return shapeId;
  }

  @override
  Future<void> removeHighlightPolygonShape(String shapeId) async {
    _highlightPolygon[shapeId]?.element?.setMap(null);
    _highlightPolygon.remove(shapeId);
    _redraw();
  }

  @override
  Future<void> changePolygonVisible(String shapeId, bool visible) async {
    final shape = _highlightPolygon[shapeId];
    if (shape == null) return;
    shape.visible = visible;
    _redraw();
    _syncHighlightElement(shape);
  }

  @override
  Future<void> changePolygon(
    String shapeId,
    WebShapePoint point,
    PolygonStyle style,
  ) async {
    final shape = _highlightPolygon[shapeId];
    if (shape == null) return;
    shape.point = point;
    shape.style = style;
    _redraw();
    _syncHighlightElement(shape);
  }
}
