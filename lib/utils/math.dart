part of '../kakao_map_sdk.dart';

const double _earthRadius = 6378137.0;
const double _radians = 180 / math.pi;

double haversine(double lat1, double lng1, double lat2, double lng2) {
  final relativeLatitiude = (lat1 - lat2).abs() * _radians;
  final relativeLongtitude = (lng1 - lng2).abs() * _radians;

  final sinRelativeLatitude = math.sin(relativeLatitiude);
  final sinRelativeLongtitude = math.sin(relativeLongtitude);
  final cosRelativeLatitude = math.cos(relativeLatitiude);
  final cosRelativeLongtitude = math.cos(relativeLongtitude);

  final h = math.pow(sinRelativeLatitude, 2) +
      cosRelativeLatitude *
          cosRelativeLongtitude *
          math.pow(sinRelativeLongtitude, 2);
  return 2 * _earthRadius * math.asin(math.sqrt(h));
}
