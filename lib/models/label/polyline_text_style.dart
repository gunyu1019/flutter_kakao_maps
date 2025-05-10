part of '../../kakao_map_sdk.dart';

/// [PolylineText]의 스타일을 표현하는 객체입니다.
class PolylineTextStyle {
  /// (Android 한정된 기능) 픽셀 밀도에 따라 텍스트 크기를 조정 유무를 정의합니다.
  bool applyDpScale;

  /// [PolylineTextStyle]이 나타날 [zoomLevel]을 설정합니다.
  /// [PolylineTextStyle.zoomLevel]값이 카메라의 [CameraPosition.zoomLevel] 값보다 작으면 해당되는 [PolylineTextStyle]이 적용됩니다.
  int zoomLevel;

  /// 글씨 크기
  final int size;

  /// 글씨 외곽선의 두께
  final int? strokeSize;

  /// 글씨 색상
  final Color color;

  /// 글씨 외곽선의 색상
  final Color? strokeColor;

  final List<PolylineTextStyle> _styles = [];
  final bool _isSecondaryStyle;

  PolylineTextStyle(this.size, this.color,
      {this.strokeSize,
      this.strokeColor,
      this.applyDpScale = true,
      this.zoomLevel = 0})
      : _isSecondaryStyle = false;

  PolylineTextStyle._(this.size, this.color,
      {this.strokeSize,
      this.strokeColor,
      this.applyDpScale = true,
      this.zoomLevel = 0})
      : _isSecondaryStyle = true;

  /// [zoomLevel]에 따라 [PolylineTextStyle]에 표시될 다른 스타일을 정의합니다.
  /// 메소드에서 사용된 [zoomLevel] 매개변수가 [CameraPosition.zoomLevel] 값보다 작으면
  /// [PolylineTextStyle.addStyle] 메소드로 정의한 새로운 스타일이 적용됩니다.
  /// 같은 [PolylineTextStyle] 객체에서 다른 스타일을 정의할 때, [zoomLevel] 매개변수의 값이 중복되서는 안됩니다.
  void addStyle(int zoomLevel,
      {int? size,
      Color? color,
      bool? applyDpScale,
      int? strokeSize,
      Color? strokeColor}) {
    if (_isSecondaryStyle) return;

    final otherStyle = PolylineTextStyle._(
        size ?? this.size, color ?? this.color,
        applyDpScale: applyDpScale ?? this.applyDpScale,
        strokeSize: strokeSize ?? this.strokeSize,
        strokeColor: strokeColor ?? this.strokeColor,
        zoomLevel: zoomLevel);
    _styles.add(otherStyle);
  }

  /// [PoiStyle.addStyle]로 정의된 다른 스타일의 개수를 불러옵니다.
  PolylineTextStyle? getStyle(int zoomLevel) {
    return _styles.where((e) => e.zoomLevel == zoomLevel).firstOrNull;
  }

  /// [PoiStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel]에 충족한다면 삭제합니다.
  void removeStyle(int zoomLevel) {
    _styles.removeWhere((e) => e.zoomLevel == zoomLevel);
  }

  /// [PolylineTextStyle.addStyle]로 정의된 다른 스타일의 개수를 불러옵니다.
  int get otherStyleCount => _styles.length;

  /// [PolylineTextStyle.addStyle]로 정의된 다른 스타일의 Zoom Level을 불러옵니다.
  List<int> get otherStyleLevel =>
      _styles.map((e) => e.zoomLevel).toList(growable: false);

  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "applyDpScale": applyDpScale,
      // ignore: deprecated_member_use
      "color": color.value,
      "size": size,
      "strokeSize": strokeSize,
      // ignore: deprecated_member_use
      "strokeColor": strokeColor?.value,
    };
    if (!_isSecondaryStyle) {
      payload['otherStyle'] = _styles.map((e) => e.toMessageable()).toList();
    }
    return payload;
  }
}
