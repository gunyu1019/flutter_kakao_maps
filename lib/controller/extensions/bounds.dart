part of '../../kakao_map_sdk.dart';

///
extension KakaoMapControllerBoundsExtension on KakaoMapController {
  /// 화면에 보이는 지도 영역의 경계를 가져오는 함수입니다
  Future<LatLngBounds?> getBounds(BuildContext context) async {
    /// 지도 위젯을 포함하는 RenderBox 객체입니다
    final renderBox = context.findRenderObject();

    if (renderBox is! RenderBox) {
      return null;
    }

    final size = renderBox.size;

    final [ne, sw] = await Future.wait([
      fromScreenPoint(size.width.toInt(), 0),
      fromScreenPoint(0, size.height.toInt())
    ]);

    if (ne == null || sw == null) {
      return null;
    }

    return LatLngBounds._(ne, sw);
  }
}
