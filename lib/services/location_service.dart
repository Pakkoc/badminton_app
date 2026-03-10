import 'package:permission_handler/permission_handler.dart';

/// 위치 권한 관리 서비스.
class LocationService {
  /// 현재 위치 권한이 부여되었는지 확인한다.
  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// 위치 권한을 요청한다.
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// 권한이 영구 거부되었는지 확인한다.
  Future<bool> isPermanentlyDenied() async {
    final status = await Permission.location.status;
    return status.isPermanentlyDenied;
  }

  /// 시스템 앱 설정을 연다.
  Future<bool> openSettings() async {
    return openAppSettings();
  }
}
