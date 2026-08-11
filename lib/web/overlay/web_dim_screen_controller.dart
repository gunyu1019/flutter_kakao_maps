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
  double _fillRed = 0;
  double _fillGreen = 0;
  double _fillBlue = 0;
  DimScreenCover _cover = DimScreenCover.all;
  bool _visible = false;

  final Map<String, WebDimHighlightShape> _highlightPolygon = {};
  int _nextHighlightOrder = 0;

  JSFunction? _boundsChangedCallbackRef;
  JSFunction? _zoomChangedCallbackRef;
  web.Element? _labelFilterRoot;
  web.Element? _labelColorMatrix;
  String? _labelFilterId;

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
    _createLabelColorFilter();
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
      for (final strokeElement in shape.strokeElements) {
        strokeElement.setMap(null);
      }
    }
    _highlightPolygon.clear();
    _visible = false;
    _syncAllLabelElements();
    _labelFilterRoot?.remove();
    _labelFilterRoot = null;
    _labelColorMatrix = null;
    _labelFilterId = null;
  }

  void _createLabelColorFilter() {
    if (_labelFilterRoot != null) return;
    const svgNamespace = 'http://www.w3.org/2000/svg';
    final filterId =
        'kakao-map-dim-label-${manager._uuid.v4().replaceAll('-', '')}';
    final root = web.document.createElementNS(svgNamespace, 'svg')
      ..setAttribute('width', '0')
      ..setAttribute('height', '0')
      ..setAttribute('aria-hidden', 'true')
      ..setAttribute('style', 'position:absolute;overflow:hidden');
    final definitions = web.document.createElementNS(svgNamespace, 'defs');
    final filter = web.document.createElementNS(svgNamespace, 'filter')
      ..setAttribute('id', filterId)
      ..setAttribute('color-interpolation-filters', 'sRGB');
    final matrix = web.document.createElementNS(svgNamespace, 'feColorMatrix')
      ..setAttribute('type', 'matrix');

    filter.appendChild(matrix);
    definitions.appendChild(filter);
    root.appendChild(definitions);
    web.document.body?.appendChild(root);

    _labelFilterRoot = root;
    _labelColorMatrix = matrix;
    _labelFilterId = filterId;
    _updateLabelColorFilter();
  }

  void _updateLabelColorFilter() {
    final retained = 1 - _fillOpacity;
    final red = _fillRed * _fillOpacity;
    final green = _fillGreen * _fillOpacity;
    final blue = _fillBlue * _fillOpacity;
    _labelColorMatrix?.setAttribute(
      'values',
      '$retained 0 0 0 $red '
          '0 $retained 0 0 $green '
          '0 0 $retained 0 $blue '
          '0 0 0 1 0',
    );
  }

  void _boundsChangedEventHandler() {
    if (_element == null) return;
    _redraw();
    _syncAllHighlightElements();
    _syncAllLabelElements();
  }

  void _zoomChangedEventHandler() {
    _redraw();
    _syncAllHighlightElements();
    _syncAllLabelElements();
  }

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
      strokeWeight: 0,
      strokeOpacity: 0,
      zIndex: _zIndex + 1,
    );
  }

  WebPolylineOption _getHighlightStrokeElementOption(
    PolygonStyle style,
    JSArray<WebLatLng> path,
    int zIndex,
  ) {
    return WebPolylineOption(
      endArrow: false,
      path: path,
      strokeColor: _getColorCode(style.strokeColor),
      strokeWeight: style.strokeWidth,
      strokeOpacity: style.strokeColor.a,
      zIndex: zIndex,
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
      for (final strokeElement in shape.strokeElements) {
        strokeElement.setMap(null);
      }
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
    } else {
      shape.option!.path = path;
      shape.option!.fillColor = _getColorCode(style.color);
      shape.option!.fillOpacity = style.color.a;
      shape.option!.strokeColor = _getColorCode(style.strokeColor);
      shape.option!.strokeWeight = 0;
      shape.option!.strokeOpacity = 0;
      shape.option!.zIndex = zIndex;
      shape.element!.setOptions(shape.option!);
      shape.element!.setMap(controller);
    }

    _syncHighlightStrokeElements(shape, style, zIndex);
  }

  void _syncHighlightStrokeElements(
    WebDimHighlightShape shape,
    PolygonStyle style,
    int zIndex,
  ) {
    final paths = style.strokeWidth > 0 && style.strokeColor.a > 0
        ? shape.point.strokeRings
            .map((ring) => ring.map(WebLatLng.fromLatLng).toList().toJS)
            .toList()
        : <JSArray<WebLatLng>>[];

    while (shape.strokeElements.length > paths.length) {
      shape.strokeElements.removeLast().setMap(null);
      shape.strokeOptions.removeLast();
    }

    for (var index = 0; index < paths.length; index++) {
      final path = paths[index];
      if (index == shape.strokeElements.length) {
        final option = _getHighlightStrokeElementOption(
          style,
          path,
          zIndex,
        );
        final element = WebPolyline(option)..setMap(controller);
        shape.strokeOptions.add(option);
        shape.strokeElements.add(element);
        continue;
      }

      final option = shape.strokeOptions[index]
        ..path = path
        ..strokeColor = _getColorCode(style.strokeColor)
        ..strokeWeight = style.strokeWidth
        ..strokeOpacity = style.strokeColor.a
        ..zIndex = zIndex;
      shape.strokeElements[index]
        ..setOptions(option)
        ..setMap(controller);
    }
  }

  void _syncAllHighlightElements() {
    for (final shape in _highlightPolygon.values) {
      _syncHighlightElement(shape);
    }
  }

  void _syncLabelElement(WebPoi poi) {
    final coversLabels =
        _cover == DimScreenCover.mapAndLabel || _cover == DimScreenCover.all;
    final highlighted = _highlightPolygon.values.any(
      (shape) =>
          shape.visible && shape.point.contains(poi.getPosition().toLatLng()),
    );
    final filtered = _visible && coversLabels && !highlighted;
    poi.setDimScreenFilter(filtered ? 'url(#$_labelFilterId)' : null);
  }

  void _syncAllLabelElements() {
    final layers = [
      ...manager._labelLayer.values,
      ...manager._lodLabelLayer.values
    ];
    for (final layer in layers) {
      for (final poi in layer._webPoi.values) {
        _syncLabelElement(poi);
      }
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
    _fillRed = flutterColor.r;
    _fillGreen = flutterColor.g;
    _fillBlue = flutterColor.b;
    _updateLabelColorFilter();
    _redraw();
    _syncAllLabelElements();
  }

  @override
  Future<void> setDimVisible(bool visible) async {
    _visible = visible;
    if (_element == null) {
      _redraw();
    }
    _element?.setMap(visible ? controller : null);
    _syncAllHighlightElements();
    _syncAllLabelElements();
  }

  @override
  Future<void> setDimCover(DimScreenCover cover) async {
    _cover = cover;
    _redraw();
    _syncAllHighlightElements();
    _syncAllLabelElements();
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
    _syncAllLabelElements();
    return shapeId;
  }

  @override
  Future<void> removeHighlightPolygonShape(String shapeId) async {
    final shape = _highlightPolygon[shapeId];
    shape?.element?.setMap(null);
    for (final strokeElement in shape?.strokeElements ?? <WebPolyline>[]) {
      strokeElement.setMap(null);
    }
    _highlightPolygon.remove(shapeId);
    _redraw();
    _syncAllLabelElements();
  }

  @override
  Future<void> changePolygonVisible(String shapeId, bool visible) async {
    final shape = _highlightPolygon[shapeId];
    if (shape == null) return;
    shape.visible = visible;
    _redraw();
    _syncHighlightElement(shape);
    _syncAllLabelElements();
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
    _syncAllLabelElements();
  }
}
