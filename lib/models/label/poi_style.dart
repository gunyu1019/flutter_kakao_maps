part of '../../kakao_map_sdk.dart';

class PoiStyle with KMessageable {
  String? _id;

  /// Poi Style에 사용되는 고유한 ID 입니다.
  String? get id => _id;

  /// (Android 한정된 기능) 픽셀 밀도에 따라 이미지 크기 및 텍스트 크기를 조정 유무를 정의합니다.
  bool applyDpScale;

  /// [Poi]의 위치를 기준으로 [icon]을 배치할 위치를 설정합니다.
  KPoint anchor;

  double padding;

  /// [Poi]의 [icon]이 나타나고, 사라질 때 적용하는 애니메이션을 정의합니다.
  PoiTransition iconTransition;

  /// [Poi]의 텍스트의 배치를 설정합니다.
  MapGravity textGravity;

  /// [Poi]에 표시될 아이콘입니다.
  /// 이미지([KImage]) 객체를 통해 [Poi]에 노출할 아이콘을 설정합니다.
  KImage? icon;

  /// [Poi]의 텍스트 스타일을 정의합니다.
  /// 텍스트 스타일은 배열로 정의해야 합니다.
  /// 줄바꿈에 따라 배열의 순서대로 [PoiTextStlye]이 적용됩니다.
  List<PoiTextStyle> textStyle;

  /// [Poi]의 텍스트가 나타나고, 사라질 때 적용하는 애니메이션을 정의합니다.
  PoiTransition textTransition;

  /// [PoiStyle]이 나타날 [zoomLevel]을 설정합니다.
  /// [PoiStyle.zoomLevel]값이 카메라의 [CameraPosition.zoomLevel] 값보다 작으면 해당되는 [PoiStyle]이 적용됩니다.
  int zoomLevel;

  final List<PoiStyle> _styles = [];
  final bool _isSecondaryStyle;
  bool _isAdded = false;

  PoiStyle(
      {String? id,
      this.applyDpScale = true,
      this.anchor = const KPoint(0.5, 1.0),
      this.padding = 0.0,
      this.icon,
      this.iconTransition = const PoiTransition(),
      this.textGravity =
          const MapGravity(HorizontalAlign.center, VerticalAlign.bottom),
      this.textStyle = const [],
      this.textTransition = const PoiTransition(),
      this.zoomLevel = 0})
      : _isSecondaryStyle = false,
        _id = id;

  PoiStyle._(
      {String? id,
      this.applyDpScale = true,
      this.anchor = const KPoint(0.5, 1.0),
      this.padding = 0.0,
      this.icon,
      this.iconTransition = const PoiTransition(),
      this.textGravity =
          const MapGravity(HorizontalAlign.center, VerticalAlign.bottom),
      this.textStyle = const [],
      this.textTransition = const PoiTransition(),
      this.zoomLevel = 0})
      : _isSecondaryStyle = true,
        _id = id;

  void _setStyleId(String id) {
    _id = id;
    if (!_isSecondaryStyle) {
      for (PoiStyle e in _styles) {
        e._id = id;
      }
    }
  }

  /// [zoomLevel]에 따라 [Poi]에 표시될 다른 스타일을 정의합니다.
  /// 메소드에서 사용된 [zoomLevel] 매개변수가 [CameraPosition.zoomLevel] 값보다 작으면
  /// [PoiStyle.addStyle] 메소드로 정의한 새로운 스타일이 적용됩니다.
  /// 같은 [PoiStyle] 객체에서 다른 스타일을 정의할 때, [zoomLevel] 매개변수의 값이 중복되서는 안됩니다.
  void addStyle({
    required int zoomLevel,
    bool? applyDpScale,
    KPoint? anchor,
    double? padding,
    KImage? icon,
    PoiTransition? iconTransition,
    MapGravity? textGravity,
    List<PoiTextStyle>? textStyle,
    PoiTransition? textTransition,
  }) {
    if (_isSecondaryStyle) return;
    final otherStyle = PoiStyle._(
        id: id,
        applyDpScale: applyDpScale ?? this.applyDpScale,
        anchor: anchor ?? this.anchor,
        padding: padding ?? this.padding,
        icon: icon ?? this.icon,
        iconTransition: iconTransition ?? this.iconTransition,
        textGravity: textGravity ?? this.textGravity,
        textStyle: textStyle ?? this.textStyle,
        textTransition: textTransition ?? this.textTransition,
        zoomLevel: zoomLevel);
    _styles.add(otherStyle);
  }

  /// [PoiStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel] 통해 불러옵니다.
  PoiStyle? getStyle(int zoomLevel) {
    if (_isSecondaryStyle) return null;
    return _styles.where((e) => e.zoomLevel == zoomLevel).firstOrNull;
  }

  /// [PoiStyle.addStyle]로 정의된 다른 스타일을 [zoomLevel]에 충족한다면 삭제합니다.
  void removeStyle(int zoomLevel) {
    if (_isSecondaryStyle) return;
    _styles.removeWhere((e) => e.zoomLevel == zoomLevel);
  }

  /// [PoiStyle.addStyle]로 정의된 다른 스타일의 개수를 불러옵니다.
  int get otherStyleCount => _styles.length;

  /// [PoiStyle.addStyle]로 정의된 다른 스타일의 Zoom Level을 불러옵니다.
  List<int> get otherStyleLevel =>
      _styles.map((e) => e.zoomLevel).toList(growable: false);

  /// [PoiStyle.addStyle]로 정의된 다른 스타일을 모두 불러옵니다.
  List<PoiStyle> get otherStyles => _styles.toList(growable: false);

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "applyDpScale": applyDpScale,
      "anchor": anchor.toMessageable(),
      "padding": padding,
      "icon": icon?.toMessageable(),
      "iconTransition": iconTransition.toMessageable(),
      "textGravity": textGravity.value,
      "textTransition": textTransition.toMessageable(),
      "textStyle": textStyle.map((e) => e.toMessageable()).toList(),
      "zoomLevel": zoomLevel
    };
    if (!_isSecondaryStyle) {
      payload['otherStyle'] = _styles.map((e) => e.toMessageable()).toList();
    }
    return payload;
  }

  factory PoiStyle.fromMessageable(dynamic payload, [String? id]) {
    final style = PoiStyle(
        id: id,
        applyDpScale: payload["applyDpScale"],
        anchor: KPoint.fromMessageable(payload["anchor"]),
        padding: payload["padding"],
        icon: payload["icon"] != null
            ? KImage.fromMessageable(payload["icon"])
            : null,
        iconTransition:
            PoiTransition.fromMessageable(payload["iconTransition"]),
        textGravity: MapGravity.fromValue(payload["textGravity"]),
        textStyle: payload["textStyle"]
            .map<PoiTextStyle>(PoiTextStyle.fromMessageable)
            .toList(),
        textTransition:
            PoiTransition.fromMessageable(payload["textTransition"]),
        zoomLevel: payload["zoomLevel"]);
    if (payload.containsKey("otherStyle") && payload["otherStyle"].length > 0) {
      payload["otherStyle"]
          .map<PoiStyle>((e) => PoiStyle._(
              id: id,
              applyDpScale: e["applyDpScale"],
              anchor: KPoint.fromMessageable(e["anchor"]),
              padding: e["padding"],
              icon:
                  e["icon"] != null ? KImage.fromMessageable(e["icon"]) : null,
              iconTransition:
                  PoiTransition.fromMessageable(e["iconTransition"]),
              textGravity: MapGravity.fromValue(e["textGravity"]),
              textStyle: e["textStyle"]
                  .map<PoiTextStyle>(PoiTextStyle.fromMessageable)
                  .toList(),
              textTransition:
                  PoiTransition.fromMessageable(e["textTransition"]),
              zoomLevel: e["zoomLevel"]))
          .forEach(style._styles.add);
    }
    return style;
  }
}
