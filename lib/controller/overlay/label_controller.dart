part of '../../flutter_kakao_map.dart';

class LabelController {
  final String id;
  final MethodChannel channel;
  final CompetitionType competitionType;
  final CompetitionUnit competitionUnit;
  final OrderingType orderingType;
  bool visable;
  bool clickable;
  String tag;
  int zOrder;

  LabelController(this.id, this.channel, {
    required this.competitionType,
    required this.competitionUnit,
    required this.orderingType,
    required this.zOrder, // 10001 (default)
    this.visable = true,
    this.clickable = true,
    this.tag = ""
  });

  Future<void> _createLabelLayer() async {
    await channel.invokeMethod("createLabelLayer", {
      "layerId": id,
      "competitionType": competitionType.value,
      "competitionUnit": competitionUnit.value,
      "orderingType": orderingType.value,
      "zOrder": zOrder,
      "visable": visable,
      "clickable": clickable,
      "tag": tag,
    });
  }

  Future<void> addPoi(PoiOption poi) async {
    await channel.invokeMethod("addPoi", {
      "layerId": id,
      "poi": poi.toMessageable()
    });
  }

  static const String layerLabelDefaultId = "label_default_layer";
  static const int layerLabelDefaultZOrder = 10001;
}
