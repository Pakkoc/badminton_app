import 'package:badminton_app/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LocationService 프로바이더.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
