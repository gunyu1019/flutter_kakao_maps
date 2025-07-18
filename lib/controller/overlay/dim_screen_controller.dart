part of '../../kakao_map_sdk.dart';

/// 지도의 일부분을 제외하고 특정 색상으로 가리는 것을 조작하는 컨트롤러입니다.
/// [MapPoint]와 [BaseDotPoint] 기반의 요소를 이용하여 지도의 일부분에 특정 색을 입히거나,
/// 특정 부분을 제외한 모든 부분을 색상을 입힐 수 있습니다.
class DimScreenController extends OverlayController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.dimScreen;

  DimScreenController._(this.channel, this.manager);
}
