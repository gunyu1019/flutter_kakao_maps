part of '../../kakao_map_sdk.dart';

/// [Route] 또는 [MultipleRoute]의 스타일을 정의하는 객체입니다.
class RouteStyle with KMessageable {
  String? _id;
  String? get id => _id;

  RoutePattern? pattern;

  final Color color;
  final double lineWidth;

  final Color strokeColor;
  final double strokeWidth;

  int zoomLevel;

  final List<RouteStyle> _styles = [];
  final bool _isSecondaryStyle;

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

  RouteStyle? getStyle(int zoomLevel) {
    if (_isSecondaryStyle) return null;
    return _styles.where((e) => e.zoomLevel == zoomLevel).firstOrNull;
  }

  void removeStyle(int zoomLevel) {
    if (_isSecondaryStyle) return;
    _styles.removeWhere((e) => e.zoomLevel == zoomLevel);
  }

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
}
