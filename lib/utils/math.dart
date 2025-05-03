part of '../kakao_map_sdk.dart';

const double _pi = math.pi;
const double _earthRadius = 6371.0088 * 1000.0;

double _degreeToRadian(degree) => degree * (_pi / 180);

double _radianToDegree(radian) => radian * (180 / _pi);

/// [point1]과 [point2]의 지점의 최단 거리를 구합니다.
/// [Haversine Formula / 위키피디아](https://en.wikipedia.org/wiki/Haversine_formula) 공식을 이용하여 WGS84 좌표계의 두 사이의 거리를 계산합니다.
double _haversine(LatLng point1, LatLng point2) {
  final latitude1 = _degreeToRadian(point1.latitude);
  final latitude2 = _degreeToRadian(point2.latitude);
  final longtitude1 = _degreeToRadian(point1.longitude);
  final longtitude2 = _degreeToRadian(point2.longitude);

  final deltaLatitude = (latitude1 - latitude2).abs();
  final deltaLongtitude = (longtitude1 - longtitude2).abs();

  final distance = math.pow(math.sin(deltaLatitude * .5), 2) +
      (math.cos(latitude1) *
          math.cos(latitude2) *
          math.pow(math.sin(deltaLongtitude * .5), 2));
  return 2 * _earthRadius * math.asin(math.sqrt(distance));
}

/// [point](WGS84) 기준으로 [degrees] 방향의 [distance](미터) 떨어진 거리의 새로운 WGS84 좌표를 구합니다.
LatLng _pointOffset(LatLng point, double distance, double degrees) {
  final latitude = _degreeToRadian(point.latitude);
  final longtitude = _degreeToRadian(point.longitude);
  final bearing = _degreeToRadian(degrees);
  final distance0 = distance / _earthRadius;

  final newLatitude = math.asin(math.sin(latitude) * math.cos(distance0) +
      math.cos(latitude) * math.sin(distance0) * math.cos(bearing));
  final newLongtitude = longtitude +
      math.atan2(math.sin(bearing) * math.sin(distance0) * math.cos(latitude),
          math.cos(distance0) - math.sin(latitude) * math.sin(newLatitude));

  return LatLng(_radianToDegree(newLatitude), _radianToDegree(newLongtitude));
}
