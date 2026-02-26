import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 네이버 지도 미리보기 위젯.
///
/// 좌표가 주어지면 해당 위치에 마커를 표시한다.
/// 좌표가 없으면 안내 텍스트를 표시한다.
/// 웹/테스트 환경에서는 placeholder를 표시한다.
class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    this.latitude,
    this.longitude,
    this.height = 150,
    this.emptyText = '주소를 검색하면 위치가 표시됩니다',
  });

  final double? latitude;
  final double? longitude;
  final double height;
  final String emptyText;

  @visibleForTesting
  static bool usePlaceholder = false;

  bool get _hasLocation =>
      latitude != null &&
      longitude != null &&
      latitude != 0 &&
      longitude != 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: _hasLocation
            ? _buildMap(context)
            : _buildEmpty(context),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    if (kIsWeb || usePlaceholder) {
      return _buildPlaceholder(context);
    }
    final position = NLatLng(latitude!, longitude!);
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: position,
          zoom: 16,
        ),
        scrollGesturesEnable: false,
        zoomGesturesEnable: false,
        tiltGesturesEnable: false,
        rotationGesturesEnable: false,
        stopGesturesEnable: false,
      ),
      onMapReady: (controller) {
        controller.addOverlay(
          NMarker(
            id: 'shop-location',
            position: position,
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 32,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 8),
            Text(
              emptyText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              '지도 미리보기',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
