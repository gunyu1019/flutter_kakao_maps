package kr.yhs.flutter_kakao_map.model

enum class KakaoMapEvent(val id: String) {
    CameraMoveStart("camera_move_start"),
    CameraMoveEnd("camera_move_end")
}