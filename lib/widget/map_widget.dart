part of '../kakao_map_sdk.dart';

/// 카카오 맵을 제공하기 위한 위젯이 담긴 객체입니다.
class KakaoMap extends StatefulWidget {
  /// 카카오맵을 처음 불러올 때 설정한 값입니다.
  final KakaoMapOption? option;

  /// 지도를 정상적으로 불러왔을 때, 호출되는 함수입니다.
  /// 지도 조작에 필요한 [KakaoMapController]가 매개변수에 입력됩니다.
  final void Function(KakaoMapController controller) onMapReady;

  /// 지도의 상태관리를 위한 매개변수입니다.
  final KakaoMapLifecycle? onMapLifecycle;

  /// 지도에서 예상치 못한 에러가 발생했을 때, 호출되는 함수입니다.
  /// 대표적으로 네이티브 키 인증 실패했을 때, [KakaoAuthError]가 [exception]에 입력되어 호출됩니다.
  final void Function(Error error)? onMapError;

  /// 사용자 또는 소스코드에 의해 카메라가 이동을 시작했을 때, 호출되는 함수입니다.
  /// 사용자가 아닌 소스코드(프로그램)에 의해 이동되었다면, [GestureType.unknown]가 [gestureType]으로 입력됩니다.
  final void Function(GestureType gestureType)? onCameraMoveStart;

  /// 사용자 또는 소스코드에 의해 카메라가 이동을 마쳤을 때, 호출되는 함수입니다.
  /// [position] 매개변수에는 이동을 마친 최종 카메라의 위치가 입력됩니다.
  /// 사용자가 아닌 소스코드(프로그램)에 의해 이동되었다면, [GestureType.unknown]가 [gestureType]으로 입력됩니다.
  final void Function(CameraPosition position, GestureType gestureType)?
      onCameraMoveEnd;

  /// 사용자에 의해 나침판이 클릭되었을 때, 호출되는 함수입니다.
  final void Function()? onCompassClick;

  /// 사용자에 의해 [Poi]가 클릭되었을 때, 호출되는 함수입니다.
  /// [labelController] 매개변수에는 [Poi]가 소속되어 있는 컨트롤러가 담긴 객체를 입력합니다.
  /// 사용자가 선택한 [Poi]는 [poi] 매게변수에 입력됩니다.
  final void Function(LabelController labelController, Poi poi)? onPoiClick;

  /// 사용자에 의해 [LodPoi]가 클릭되었을 때, 호출되는 함수입니다.
  /// [lodLabelController] 매개변수에는 [LodPoi]가 소속되어 있는 컨트롤러가 담긴 객체를 입력합니다.
  /// 사용자가 선택한 [LodPoi]는 [poi] 매게변수에 입력됩니다.
  final void Function(LodLabelController lodLabelController, LodPoi poi)?
      onLodPoiClick;

  /// 사용자가 지도판을 클릭했을 때, 호출되는 함수입니다.
  /// [point] 매개변수는 지도를 기준으로 사용자가 클릭한 좌표가 입력됩니다.
  /// [position] 매개변수는 사용자가 클릭한 위/경도 값이 입력됩니다.
  final void Function(KPoint point, LatLng position)? onMapClick;

  /// 사용자가 [Poi], [LodPoi]를 제외한 지도의 영역을 클릭했을 때, 호출되는 함수입니다.
  /// [point] 매개변수는 지도를 기준으로 사용자가 클릭한 좌표가 입력됩니다.
  /// [position] 매개변수는 사용자가 클릭한 위/경도 값이 입력됩니다.
  final void Function(KPoint point, LatLng position)? onTerrainClick;

  /// 사용자가 [Poi], [LodPoi]를 제외한 지도의 영역을 길게 클릭했을 때, 호출되는 함수입니다.
  /// [point] 매개변수는 지도를 기준으로 사용자가 클릭한 좌표가 입력됩니다.
  /// [position] 매개변수는 사용자가 클릭한 위/경도 값이 입력됩니다.
  final void Function(KPoint point, LatLng position)? onTerrainLongClick;

  /// 사용자의 제스쳐가 지도에 우선 전달될 수 있도록 설정하는 값입니다.
  final bool forceGesture;

  /// [KakaoMap]에 보이는 뷰가 Hybrid Composition를 강제로 적용할지 설정합니다.
  /// 현재 [forceHybridComposition]는 성능 측면에서 충실하지만, 상태관리 측면에서 문제를 겪고 있으므로 적용하는 것을 추천하지 않습니다.
  /// 자세한 내용은 [Platform View](https://docs.flutter.dev/platform-integration/android/platform-views#texture-layer-or-texture-layer-hybrid-composition)을 참고해주세요.
  final bool forceHybridComposition;

  const KakaoMap(
      {super.key,
      required this.onMapReady,
      this.option,
      this.forceGesture = true,
      this.onMapLifecycle,
      this.onCameraMoveStart,
      this.onCameraMoveEnd,
      this.onCompassClick,
      this.onPoiClick,
      this.onLodPoiClick,
      this.onMapClick,
      this.onTerrainClick,
      this.onTerrainLongClick,
      this.onMapError,
      this.forceHybridComposition = false});

  @override
  State<StatefulWidget> createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> with KakaoMapControllerHandler {
  // ignore: constant_identifier_names
  static const VIEW_TYPE = "plugin/kakao_map";
  late final MethodChannel channel;
  late final KakaoMapController controller;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> rawParams = widget.option?.toMessageable() ??
        (const KakaoMapOption()).toMessageable();

    // GestureRecognizer
    final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {};
    if (widget.forceGesture) {
      gestureRecognizers
          .add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()));
    }

    return _createPlatformView(
        viewType: VIEW_TYPE,
        gestureRecognizers: gestureRecognizers,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: rawParams,
        forceHybridComposition: widget.forceHybridComposition);
  }

  void onPlatformViewCreated(int viewId) {
    channel = ChannelType.view.channelWithId(viewId);
    channel.setMethodCallHandler(handle);

    final overlayChannel = ChannelType.overlay.channelWithId(viewId);
    controller =
        KakaoMapControllerImplement(channel, overlayChannel: overlayChannel);
  }

  void _setEventHandler() {
    int bitMask = EventType.onPoiClick.id | EventType.onLodPoiClick.id;
    if (widget.onCameraMoveStart != null) {
      bitMask |= EventType.onCameraMoveStart.id;
    }
    if (widget.onCameraMoveEnd != null) bitMask |= EventType.onCameraMoveEnd.id;
    if (widget.onCompassClick != null) bitMask |= EventType.onCompassClick.id;
    if (widget.onMapClick != null) bitMask |= EventType.onMapClick.id;
    if (widget.onTerrainClick != null) bitMask |= EventType.onTerrainClick.id;
    if (widget.onTerrainLongClick != null) {
      bitMask |= EventType.onTerrainLongClick.id;
    }
    channel.invokeMethod("setEventHandler", bitMask);
  }

  /* Handler */
  @override
  void onMapDestroy() {
    widget.onMapLifecycle?.onMapDestroy?.call();
  }

  @override
  void onMapResumed() {
    widget.onMapLifecycle?.onMapResumed?.call();
  }

  @override
  void onMapPaused() {
    widget.onMapLifecycle?.onMapPaused?.call();
  }

  @override
  void onMapError(Error error) {
    widget.onMapError?.call(error);
  }

  @override
  void onMapReady() {
    _setEventHandler();
    controller.fetchBuildingHeightScale();
    widget.onMapReady.call(controller);
  }

  @override
  void onCameraMoveStart(GestureType gestureType) {
    widget.onCameraMoveStart?.call(gestureType);
  }

  @override
  void onCameraMoveEnd(CameraPosition position, GestureType gestureType) {
    widget.onCameraMoveEnd?.call(position, gestureType);
  }

  @override
  void onCompassClick() {
    widget.onCompassClick?.call();
  }

  @override
  void onPoiClick(String layerId, String poiId) {
    final layer = controller.getLabelLayer(layerId);
    final poi = layer!.getPoi(poiId);
    poi?.onClick?.call();
    widget.onPoiClick?.call(layer, poi!);
  }

  @override
  void onLodPoiClick(String layerId, String poiId) {
    final layer = controller.getLodLabelLayer(layerId);
    final poi = layer!.getLodPoi(poiId);
    poi?.onClick?.call();
    widget.onLodPoiClick?.call(layer, poi!);
  }

  @override
  void onMapClick(KPoint point, LatLng position) {
    widget.onMapClick?.call(point, position);
  }

  @override
  void onTerrainClick(KPoint point, LatLng position) {
    widget.onTerrainClick?.call(point, position);
  }

  @override
  void onTerrainLongClick(KPoint point, LatLng position) {
    widget.onTerrainLongClick?.call(point, position);
  }
}
