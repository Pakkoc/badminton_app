import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderCreateScreen extends ConsumerStatefulWidget {
  const OrderCreateScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<OrderCreateScreen> createState() =>
      _OrderCreateScreenState();
}

class _OrderCreateScreenState
    extends ConsumerState<OrderCreateScreen> {
  final _searchController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderCreateNotifierProvider);

    ref.listen(orderCreateNotifierProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('작업이 접수되었습니다')),
        );
        context.pop();
      }
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '작업 접수',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: CourtBackground(
        child: state.isSubmitting
          ? const LoadingIndicator()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // QR Section: padding [16,28], gap 8
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: QR 스캔 기능 구현
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'QR 스캔으로 회원 확인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Divider: "또는" padding [0,28], gap 12
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppTheme.border,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '또는',
                          style: TextStyle(
                            color: AppTheme.textDisabled,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Divider(
                            color: AppTheme.border,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search Wrap: padding [0,28]
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // Search Input: cornerRadius 14, fill #ffffff12, height 48
                        SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '회원 이름 또는 연락처 검색',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textTertiary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 16,
                                color: AppTheme.textTertiary,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0x12FFFFFF),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x20FFFFFF),
                                ),
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x20FFFFFF),
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x20FFFFFF),
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (query) {
                              ref
                                  .read(
                                    orderCreateNotifierProvider
                                        .notifier,
                                  )
                                  .searchMembers(
                                    widget.shopId,
                                    query,
                                  );
                            },
                          ),
                        ),
                        if (state.searchResults.isNotEmpty)
                          _SearchResultsList(
                            results: state.searchResults,
                            onSelect: (member) {
                              ref
                                  .read(
                                    orderCreateNotifierProvider
                                        .notifier,
                                  )
                                  .selectMember(member);
                              _searchController.clear();
                            },
                          ),
                      ],
                    ),
                  ),
                  // Member Wrap: padding [16,28]
                  if (state.selectedMember != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      child: _SelectedMemberCard(
                        name: state.selectedMember!.name,
                        phone: state.selectedMember!.phone,
                      ),
                    ),
                  // Work Info Form: padding [8,28], gap 12
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // 메모 라벨
                        const Text(
                          '메모',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Memo Input: cornerRadius 14, fill #ffffff12, height 80
                        SizedBox(
                          height: 80,
                          child: TextField(
                            controller: _memoController,
                            decoration: InputDecoration(
                              hintText: '메모 (선택사항)',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textTertiary,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0x12FFFFFF),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x20FFFFFF),
                                ),
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x20FFFFFF),
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x20FFFFFF),
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                            textAlignVertical:
                                TextAlignVertical.top,
                            onChanged: (memo) {
                              ref
                                  .read(
                                    orderCreateNotifierProvider
                                        .notifier,
                                  )
                                  .updateMemo(memo);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Submit Wrap: padding [16,28]
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.selectedMember != null
                            ? () {
                                ref
                                    .read(
                                      orderCreateNotifierProvider
                                          .notifier,
                                    )
                                    .submit(widget.shopId);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          minimumSize:
                              const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '작업 접수하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.results,
    required this.onSelect,
  });

  final List<Member> results;
  final void Function(Member) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Card(
        margin: const EdgeInsets.only(top: 4),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final member = results[index];
            return ListTile(
              title: Text(member.name),
              subtitle: Text(member.phone),
              onTap: () => onSelect(member),
            );
          },
        ),
      ),
    );
  }
}

class _SelectedMemberCard extends StatelessWidget {
  const _SelectedMemberCard({
    required this.name,
    required this.phone,
  });

  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
