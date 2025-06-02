part of '../../kakao_map_sdk.dart';

/// [Route] 또는 [MultipleRoute]의 스타일을 정의하는 객체입니다.
class RouteStyle with KMessageable {
  String? _id;

  /// Route Style에 사용되는 고유한 ID 입니다.
  String? get id => _id;

  /// Route Style에 [RoutePattern] 객체의 패턴을 정의합니다.
  RoutePattern? pattern;

  /// [Route] 선형의 색상입니다.
  final Color color;

  /// [Route] 선형의 굵기입니다.
  final double lineWidth;

  /// [Route] 외곽선의 색상입니다.
  final Color strokeColor;

  /// [Route] 외곽선의 굵기입니다.
  final double strokeWidth;

  /// [RouteStyle]이 나타날 [zoomLevel]을 설정합니다.
  /// [RouteStyle.zoomLevel]값이 카메라의 [CameraPosition.zoomLevel] 값보다 작으면 해당되는 [RouteStyle]이 적용됩니다.
  int zoomLevel;

  final List<RouteStyle> _styles = [];
  final bool _isSecondaryStyle;
  bool _isAdded = false;

  RouteStyle(this.color, this.lineWidth,
      {String? id,
      this.strokeColor = Colors.black,
      this.strokeWidth = 0,
      this.pattern,
      this.zoomLevel = 0})
      : _id = id,
        _isSecondaryStyle = false;

  RouteStyle.withPattern(this.pattern, {String? id, this.zoomLevel = 0})
      : _id = id,
        _isSecondaryStyle = false,
        color = Colors.black,
        lineWidth = 0,
        strokeColor = Colors.black,
        strokeWidth = 0;

  RouteStyle._(this.color, this.lineWidth,
      {String? id,
      this.strokeColor = Colors.black,
      this.strokeWidth = 0,
      this.pattern,
      this.zoomLevel = 0})
      : _id = id,
        _isSecondaryStyle = true;

  void _setStyleId(String id) {
    _id = id;
    if (!_isSecondaryStyle) {
      for (RouteStyle e in _styles) {
        e._id = id;
      }
    }
  }

  /// [zoomLevel]에 따라 [Route]에 표시될 다른 스타일을 정의합니다.
  /// 메소드에서 사용된 [zoomLevel] 매개변수가 [CameraPosition.zoomLevel] 값보다 작으면
  /// [RouteStyle.addStyle] 메소드로 정의한 새로운 스타일이 적용됩니다.
  /// 같은 [RouteStyle] 객체에서 다른 스타일을 정의할 때, [zoomLevel] 매개변수의 값이 중복되서는 안됩니다.
  void addStyle(
    int zoomLevel,
    Color? color,
    double? lineWidth, {
    Color? strokeColor,
    double? strokeWidth,
    RoutePattern? pattern,
  }) {
    if (_isSecondaryStyle) return;
    final otherStyle = RouteStyle._(
        color ?? this.color, lineWidth ?? this.lineWidth,
        strokeColor: strokeColor ?? this.strokeColor,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        pattern: pattern ?? this.pattern,
        zoomLevel: zoomLevel);
    _styles.add(otherStyle);
  }

  /// [RouteStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel] 통해 불러옵니다.
  RouteStyle? getStyle(int zoomLevel) {
    if (_isSecondaryStyle) return null;
    return _styles.where((e) => e.zoomLevel == zoomLevel).firstOrNull;
  }

  /// [RouteStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel]에 충족한다면 삭제합니다.
  void removeStyle(int zoomLevel) {
    if (_isSecondaryStyle) return;
    _styles.removeWhere((e) => e.zoomLevel == zoomLevel);
  }

  /// [RouteStyle.addStyle]로 정의된 다른 스타일의 개수를 불러옵니다.
  int get otherStyleCount => _styles.length;

  /// [RouteStyle.addStyle]로 정의된 다른 스타일의 Zoom Level을 불러옵니다.
  List<int> get otherStyleLevel =>
      _styles.map((e) => e.zoomLevel).toList(growable: false);

  /// [RouteStyle.addStyle]로 정의된 다른 스타일을 모두 불러옵니다.
  List<RouteStyle> get otherStyles => _styles.toList(growable: false);

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "id": _id,
      // ignore: deprecated_member_use
      "color": color.value,
      "lineWidth": lineWidth,
      "strokeWidth": strokeWidth,
      // ignore: deprecated_member_use
      "strokeColor": strokeColor.value,
      "pattern": pattern?.toMessageable(),
      "zoomLevel": zoomLevel
    };
    if (!_isSecondaryStyle) {
      payload['otherStyle'] = _styles.map((e) => e.toMessageable()).toList();
    }
    return payload;
  }

  factory RouteStyle.fromMessageable(dynamic payload, [String? id]) {
    final style = RouteStyle(Color(payload["color"]), payload["lineWidth"],
        id: id,
        strokeColor: Color(payload["strokeColor"]),
        strokeWidth: payload["strokeWidth"],
        pattern: payload["pattern"] != null
            ? RoutePattern.fromMessageable(payload["pattern"])
            : null,
        zoomLevel: payload["zoomLevel"]);
    if (payload.containsKey("otherStyle") && payload["otherStyle"].length > 0) {
      payload["otherStyle"]
          .map<RouteStyle>((e) => RouteStyle._(
              Color(e["color"]), e["lineWidth"],
              id: id,
              strokeColor: Color(e["strokeColor"]),
              strokeWidth: e["strokeWidth"],
              pattern: e["pattern"] != null
                  ? RoutePattern.fromMessageable(e["pattern"])
                  : null,
              zoomLevel: e["zoomLevel"]))
          .forEach(style._styles.add);
    }
    return style;
  }
}
