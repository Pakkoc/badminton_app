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
      appBar: AppBar(title: const Text('작업 접수')),
      body: state.isSubmitting
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: '회원 검색',
                      hintText: '이름 또는 전화번호',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      ref
                          .read(orderCreateNotifierProvider
                              .notifier)
                          .searchMembers(
                            widget.shopId,
                            query,
                          );
                    },
                  ),
                  if (state.searchResults.isNotEmpty)
                    _SearchResultsList(
                      results: state.searchResults,
                      onSelect: (member) {
                        ref
                            .read(
                                orderCreateNotifierProvider
                                    .notifier)
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
                  TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(
                      labelText: '메모',
                      hintText: '작업 내용을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (memo) {
                      ref
                          .read(orderCreateNotifierProvider
                              .notifier)
                          .updateMemo(memo);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.selectedMember != null
                        ? () {
                            ref
                                .read(
                                    orderCreateNotifierProvider
                                        .notifier)
                                .submit(widget.shopId);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size.fromHeight(48),
                    ),
                    child: const Text('접수하기'),
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
    return Card(
      color: Theme.of(context)
          .colorScheme
          .primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 8),
            Text(
              '$name ($phone)',
              style:
                  Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
