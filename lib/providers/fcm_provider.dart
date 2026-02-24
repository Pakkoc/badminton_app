import 'package:badminton_app/services/fcm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FcmService 프로바이더.
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});
