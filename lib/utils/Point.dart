import 'dart:math';
import 'package:amap_flutter_base/amap_flutter_base.dart';

double _getPerpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
  double dx = lineEnd.latitude - lineStart.latitude;
  double dy = lineEnd.longitude - lineStart.longitude;

  if (dx == 0 && dy == 0) {
    dx = point.latitude - lineStart.latitude;
    dy = point.longitude - lineStart.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  double t = ((point.latitude - lineStart.latitude) * dx + (point.longitude - lineStart.longitude) * dy) /
      (dx * dx + dy * dy);

  if (t < 0) {
    dx = point.latitude - lineStart.latitude;
    dy = point.longitude - lineStart.longitude;
  } else if (t > 1) {
    dx = point.latitude - lineEnd.latitude;
    dy = point.longitude - lineEnd.longitude;
  } else {
    double nearX = lineStart.latitude + t * dx;
    double nearY = lineStart.longitude + t * dy;
    dx = point.latitude - nearX;
    dy = point.longitude - nearY;
  }

  return sqrt(dx * dx + dy * dy);
}

List<LatLng> douglasPeucker(List<LatLng> points, double tolerance) {
  if (points.length < 3) return points;

  double maxDistance = 0.0;
  int index = 0;
  for (int i = 1; i < points.length - 1; i++) {
    double distance =
        _getPerpendicularDistance(points[i], points[0], points[points.length - 1]);
    if (distance > maxDistance) {
      index = i;
      maxDistance = distance;
    }
  }

  if (maxDistance > tolerance) {
    List<LatLng> result1 =
        douglasPeucker(points.sublist(0, index + 1), tolerance);
    List<LatLng> result2 =
        douglasPeucker(points.sublist(index, points.length), tolerance);

    return result1.sublist(0, result1.length - 1) + result2;
  } else {
    return [points.first, points.last];
  }
}