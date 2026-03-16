import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/member_repository.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// QR 스캔으로 진입 시 자동 접수 화면.
///
/// 1. 회원 확인 (없으면 자동 등록)
/// 2. 주문 생성 (received 상태)
/// 3. 접수 완료 안내 → 홈으로 이동
class QrOrderScreen extends ConsumerStatefulWidget {
  const QrOrderScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<QrOrderScreen> createState() =>
      _QrOrderScreenState();
}

class _QrOrderScreenState extends ConsumerState<QrOrderScreen> {
  bool _isProcessing = true;
  String? _error;
  String? _shopName;

  @override
  void initState() {
    super.initState();
    Future.microtask(_processOrder);
  }

  Future<void> _processOrder() async {
    try {
      final userId =
          ref.read(currentAuthUserIdProvider);
      if (userId == null) {
        setState(() {
          _isProcessing = false;
          _error = '로그인이 필요합니다';
        });
        return;
      }
      final userRepo = ref.read(userRepositoryProvider);
      final user = await userRepo.getById(userId);
      if (user == null) {
        setState(() {
          _isProcessing = false;
          _error = '사용자 정보를 찾을 수 없습니다';
        });
        return;
      }

      final shopRepo = ref.read(shopRepositoryProvider);
      final memberRepo = ref.read(memberRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);

      // 샵 정보 확인
      final shop = await shopRepo.getById(widget.shopId);
      if (shop == null) {
        setState(() {
          _isProcessing = false;
          _error = '샵을 찾을 수 없습니다';
        });
        return;
      }
      setState(() => _shopName = shop.name);

      // 회원 확인 (없으면 자동 등록)
      var member = await memberRepo.getByShopAndUser(
        widget.shopId,
        user.id,
      );
      member ??= await memberRepo.create(
        Member(
          id: '',
          shopId: widget.shopId,
          userId: user.id,
          name: user.name,
          phone: user.phone,
          createdAt: DateTime.now(),
        ),
      );

      // 주문 생성
      final now = DateTime.now();
      await orderRepo.create(
        GutOrder(
          id: '',
          shopId: widget.shopId,
          memberId: member.id,
          status: OrderStatus.received,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 사장님에게 알림 전송 (notify_shop이 켜져 있을 때만)
      await _notifyOwner(shop.ownerId, user.name, shop.name);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // 접수 완료 안내 후 홈으로 이동
      await _showSuccessAndGoHome();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _error = '접수에 실패했습니다. 다시 시도해 주세요.';
      });
    }
  }

  /// 사장님에게 새 작업 접수 알림을 전송한다.
  ///
  /// 사장님의 `notify_shop` 설정이 꺼져 있으면 전송하지 않는다.
  Future<void> _notifyOwner(
    String ownerId,
    String customerName,
    String shopName,
  ) async {
    try {
      final owner =
          await ref.read(userRepositoryProvider).getById(ownerId);
      if (owner == null || !owner.notifyShop) return;

      await ref.read(notificationRepositoryProvider).create(
            userId: ownerId,
            type: NotificationType.receipt,
            title: '새 작업 접수',
            body: '$customerName님이 QR코드로 $shopName에 접수했습니다',
          );
    } catch (_) {
      // 알림 전송 실패는 주문 접수에 영향을 주지 않는다
    }
  }

  Future<void> _showSuccessAndGoHome() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppTheme.accent,
          size: 48,
        ),
        title: const Text('접수 완료'),
        content: Text(
          '$_shopName에 작업이 접수되었습니다',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              this.context.go('/customer/home');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accent,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 접수'),
      ),
      body: CourtBackground(
        child: Center(
        child: _isProcessing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _shopName != null
                        ? '$_shopName에 접수 중...'
                        : '접수 처리 중...',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge,
                  ),
                ],
              )
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      if (_error == '로그인이 필요합니다')
                        FilledButton(
                          onPressed: () =>
                              context.go('/login'),
                          child: const Text('로그인하기'),
                        )
                      else
                        FilledButton(
                          onPressed: () =>
                              context.go('/customer/home'),
                          child: const Text('홈으로'),
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
      ),
      ),
    );
  }
}
