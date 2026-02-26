import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';
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
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: state.isSubmitting
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // QR 스캔 버튼
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: QR 스캔 기능 구현
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
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
                  const SizedBox(height: 16),
                  // "또는" 구분선
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '또는',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Divider(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 회원 검색 입력
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '회원 이름 또는 연락처 검색',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                          borderSide: BorderSide.none,
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
                  if (state.selectedMember != null) ...[
                    const SizedBox(height: 16),
                    _SelectedMemberCard(
                      name: state.selectedMember!.name,
                      phone: state.selectedMember!.phone,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // 메모 라벨
                  const Text(
                    '메모',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 메모 입력
                  SizedBox(
                    height: 80,
                    child: TextField(
                      controller: _memoController,
                      decoration: InputDecoration(
                        hintText: '메모 (선택사항)',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.all(16),
                      ),
                      maxLines: null,
                      expands: true,
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
                  const SizedBox(height: 24),
                  ElevatedButton(
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
                          const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
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
                ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
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
