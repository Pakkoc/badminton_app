import 'package:badminton_app/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShopQrScreen extends StatelessWidget {
  const ShopQrScreen({
    super.key,
    required this.shop,
  });

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 샵 QR코드')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: shop.id,
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 24),
              Text(
                shop.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                shop.address,
                style:
                    Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                '고객이 이 QR 코드를 스캔하면\n자동으로 회원 등록됩니다',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 24),

              // 이미지 저장 / 공유하기 버튼
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        // TODO: share 패키지로 이미지 저장 구현
                        onPressed: () {},
                        icon: const Icon(
                          Icons.save_alt,
                          size: 18,
                        ),
                        label: const Text('이미지 저장'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF16A34A),
                          side: const BorderSide(
                            color: Color(0xFF16A34A),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        // TODO: share 패키지로 공유하기 구현
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share,
                          size: 18,
                        ),
                        label: const Text('공유하기'),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 안내 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 가게에 QR을 비치하세요',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '앱이 없는 고객도 QR을 스캔하면 앱 다운로드 페이지로 이동합니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
