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
      appBar: AppBar(title: const Text('샵 QR 코드')),
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
            ],
          ),
        ),
      ),
    );
  }
}
