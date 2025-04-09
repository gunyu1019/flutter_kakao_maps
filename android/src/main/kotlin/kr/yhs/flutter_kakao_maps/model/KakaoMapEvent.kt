package kr.yhs.flutter_kakao_maps.model

enum class KakaoMapEvent(val id: Int) {
  CameraMoveStart(1),
  CameraMoveEnd(2),
  CompassClick(4),
  MapClick(8),
  TerrainClick(16),
  TerrainLongClick(32),
  PoiClick(64),
  LodPoiClick(128);

  fun compare(other: Int): Boolean {
    return (this.id and other) == this.id
  }
}
