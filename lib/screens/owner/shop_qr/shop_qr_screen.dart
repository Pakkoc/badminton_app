import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// shopId로 Shop을 조회하는 프로바이더.
final _shopByIdProvider =
    FutureProvider.autoDispose.family<Shop?, String>(
  (ref, shopId) =>
      ref.read(shopRepositoryProvider).getById(shopId),
);

class ShopQrScreen extends ConsumerStatefulWidget {
  const ShopQrScreen({
    super.key,
    required this.shopId,
  });

  final String shopId;

  @override
  ConsumerState<ShopQrScreen> createState() =>
      _ShopQrScreenState();
}

class _ShopQrScreenState extends ConsumerState<ShopQrScreen> {
  bool _isSaving = false;
  bool _isSharing = false;

  /// QR코드를 PNG Uint8List로 렌더링한다.
  /// [size]는 렌더링할 픽셀 크기 (인쇄용은 1024px, 공유용은 512px).
  Future<Uint8List> _renderQrPng(double size) async {
    final qrData = 'https://gutalarm.app/shop/${widget.shopId}';
    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF1A1A2E),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF1A1A2E),
      ),
    );
    final image = await painter.toImageData(
      size,
      format: ui.ImageByteFormat.png,
    );
    // QrPainter는 투명 배경으로 렌더링하므로
    // 흰색 배경 위에 QR을 합성한다.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final s = size;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()..color = Colors.white,
    );
    final qrImage = await decodeImageFromList(
      image!.buffer.asUint8List(),
    );
    canvas.drawImage(qrImage, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(s.toInt(), s.toInt());
    final byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  /// 고해상도 QR 이미지를 갤러리에 저장한다.
  Future<void> _saveImage() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: false);
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('갤러리 접근 권한이 필요합니다.'),
              ),
            );
          }
          return;
        }
      }

      final bytes = await _renderQrPng(1024);
      await Gal.putImageBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR코드가 저장되었습니다')),
        );
      }
    } on GalException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${e.type.message}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// QR 이미지를 시스템 공유 시트로 공유한다.
  Future<void> _shareImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final bytes = await _renderQrPng(512);
      final shop =
          await ref.read(_shopByIdProvider(widget.shopId).future);
      final shopName = shop?.name ?? '';
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'qr_${widget.shopId}.png',
      );
      await Share.shareXFiles(
        [xFile],
        text:
            '거트알림 앱으로 QR을 스캔하면 $shopName의 회원 등록이 됩니다.',
        fileNameOverrides: ['qr_${widget.shopId}.png'],
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync =
        ref.watch(_shopByIdProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 샵 QR코드',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: shopAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(
          child: Text('매장 정보를 불러올 수 없습니다: $e'),
        ),
        data: (shop) {
          if (shop == null) {
            return const Center(
              child: Text('매장 정보를 찾을 수 없습니다.'),
            );
          }
          return CourtBackground(
            child: SingleChildScrollView(
              // Content Area: padding [16,28], gap 20
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              child: Column(
                children: [
                  _QrCard(shop: shop),
                  const SizedBox(height: 20),
                  // Button Row: gap 16
                  _ButtonRow(
                    isSaving: _isSaving,
                    isSharing: _isSharing,
                    onSave: _saveImage,
                    onShare: _shareImage,
                  ),
                  const SizedBox(height: 20),
                  const _InfoCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      // QR Card: cornerRadius 20, fill #ffffff18, padding 24, gap 16
      // shadow: blur 8, color #0000000D, offset (0,2)
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            shop.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onCardSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'QR코드, 고객이 스캔하여 회원 등록',
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.cardBorder,
                  width: 2,
                ),
              ),
              child: QrImageView(
                data: 'https://gutalarm.app/shop/${shop.id}',
                version: QrVersions.auto,
                size: 200,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 260,
            child: Text(
              '고객이 이 QR을 스캔하면 자동으로 회원 등록됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.onCardSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.isSaving,
    required this.isSharing,
    required this.onSave,
    required this.onShare,
  });

  final bool isSaving;
  final bool isSharing;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: '인쇄용 QR코드 다운로드',
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download, size: 18),
                label: const Text('이미지 저장'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  side: const BorderSide(
                    color: AppTheme.accent,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Semantics(
            label: 'QR코드 공유',
            child: SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: isSharing ? null : onShare,
                icon: isSharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.share, size: 18),
                label: const Text('공유하기'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Info Card: cornerRadius 20, fill #ffffff10, border #3B82F6 1px
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.info,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 가게에 QR을 비치하세요',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.onCardPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '앱이 없는 고객도 QR을 스캔하면 앱 다운로드 페이지로 이동합니다',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.onCardSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
