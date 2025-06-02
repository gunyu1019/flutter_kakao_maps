part of '../../kakao_map_sdk.dart';

/// [Polyline]의 스타일을 정의하는 객체입니다.
class PolylineStyle with KMessageable {
  String? _id;

  /// Polyline Style에 사용되는 고유한 ID 입니다.
  String? get id => _id;

  /// [Polyline]의 내부를 구성하는 색상입니다.
  final Color color;

  /// [Polyline]의 내부를 구성하는 굵기입니다.
  final double lineWidth;

  /// [Polyline]의 외곽선 굵기입니다.
  final double strokeWidth;

  /// [Polyline]의 외곽선 색상입니다.
  final Color strokeColor;

  /// [PolylineStyle]이 나타날 [zoomLevel]을 설정합니다.
  /// [PolylineStyle.zoomLevel]값이 카메라의 [CameraPosition.zoomLevel] 값보다 작으면 해당되는 [PolylineStyle]이 적용됩니다.
  int zoomLevel;

  final List<PolylineStyle> _styles = [];
  final bool _isSecondaryStyle;
  bool _isAdded = false;

  void _setStyleId(String id) {
    _id = id;
    if (!_isSecondaryStyle) {
      for (PolylineStyle e in _styles) {
        e._id = id;
      }
    }
  }

  PolylineStyle(
    this.color,
    this.lineWidth, {
    String? id,
    this.strokeWidth = .0,
    this.strokeColor = Colors.black,
    this.zoomLevel = 0,
  })  : _id = id,
        _isSecondaryStyle = false;

  PolylineStyle._(
    this.color,
    this.lineWidth, {
    String? id,
    this.strokeWidth = .0,
    this.strokeColor = Colors.black,
    this.zoomLevel = 0,
  })  : _id = id,
        _isSecondaryStyle = true;

  /// [zoomLevel]에 따라 [Polyline]에 표시될 다른 스타일을 정의합니다.
  /// 메소드에서 사용된 [zoomLevel] 매개변수가 [CameraPosition.zoomLevel] 값보다 작으면
  /// [PolylineStyle.addStyle] 메소드로 정의한 새로운 스타일이 적용됩니다.
  /// 같은 [PolylineStyle] 객체에서 다른 스타일을 정의할 때, [zoomLevel] 매개변수의 값이 중복되서는 안됩니다.
  void addStyle(int zoomLevel,
      {Color? color,
      double? lineWidth,
      double? strokeWidth,
      Color? strokeColor}) {
    if (_isSecondaryStyle) return;
    final otherStyle = PolylineStyle._(
        color ?? this.color, lineWidth ?? this.lineWidth,
        strokeColor: strokeColor ?? this.strokeColor,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        zoomLevel: zoomLevel);
    _styles.add(otherStyle);
  }

  /// [PolylineStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel] 통해 불러옵니다.
  PolylineStyle? getStyle(int zoomLevel) {
    if (_isSecondaryStyle) return null;
    return _styles.where((e) => e.zoomLevel == zoomLevel).firstOrNull;
  }

  /// [PolylineStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel]에 충족한다면 삭제합니다.
  void removeStyle(int zoomLevel) {
    if (_isSecondaryStyle) return;
    _styles.removeWhere((e) => e.zoomLevel == zoomLevel);
  }

  /// [PolylineStyle.addStyle]로 정의된 다른 스타일의 개수를 불러옵니다.
  int get otherStyleCount => _styles.length;

  /// [PolylineStyle.addStyle]로 정의된 다른 스타일의 Zoom Level을 불러옵니다.
  List<int> get otherStyleLevel =>
      _styles.map((e) => e.zoomLevel).toList(growable: false);

  /// [PolylineStyle.addStyle]로 정의된 다른 스타일을 모두 불러옵니다.
  List<PolylineStyle> get otherStyles => _styles.toList(growable: false);

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
      "zoomLevel": zoomLevel
    };
    if (!_isSecondaryStyle) {
      payload['otherStyle'] = _styles.map((e) => e.toMessageable()).toList();
    }
    return payload;
  }

  factory PolylineStyle.fromMessageable(dynamic payload, [String? id]) {
    final style = PolylineStyle(Color(payload["color"]), payload["lineWidth"],
        id: id,
        strokeColor: Color(payload["strokeColor"]),
        strokeWidth: payload["strokeWidth"],
        zoomLevel: payload["zoomLevel"]);
    if (payload.containsKey("otherStyle") && payload["otherStyle"].length > 0) {
      payload["otherStyle"]
          .map<PolylineStyle>((e) => PolylineStyle._(
              Color(e["color"]), e["lineWidth"],
              id: id,
              strokeColor: Color(e["strokeColor"]),
              strokeWidth: e["strokeWidth"],
              zoomLevel: e["zoomLevel"]))
          .forEach(style._styles.add);
    }
    return style;
  }
}
