part of '../kakao_map_sdk_web.dart';

/// 네이티브 환경에서 줌 레벨과 웹 환경에서 줌 레벨을 계산합니다.
/// 아래의 공식은 축적도를 기반으로 계산된 줌 레벨이며 플랫폼별 제공하는 SDK 한계상 오차가 발생할 수 있습니다.
/// Android, iOS Platform: Lv.6 ~ Lv.21 (Lv.19)
/// Web Platform: Lv.1 ~ Lv.14
int _calculateZoomLevel(int level) => switch (level) {
      <= 6 => 14,
      <= 15 && >= 7 => 20 - level,
      <= 17 && >= 16 => 19 - level,
      >= 18 => 1,
      int() => 3
    };
