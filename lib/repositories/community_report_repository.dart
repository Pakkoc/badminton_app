import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final communityReportRepositoryProvider =
    Provider<CommunityReportRepository>((ref) {
  return CommunityReportRepository(ref.read(supabaseProvider));
});

/// 커뮤니티 신고 리포지토리.
///
/// Supabase `community_reports` 테이블에 대한 신고 생성/조회/상태 변경
/// 작업을 수행한다.
class CommunityReportRepository {
  final SupabaseClient client;

  CommunityReportRepository(this.client);

  /// 게시글을 신고한다.
  Future<CommunityReport> reportPost({
    required String reporterId,
    required String postId,
    required String reason,
  }) async {
    try {
      final data = await client.from('community_reports').insert({
        'reporter_id': reporterId,
        'post_id': postId,
        'reason': reason,
      }).select().single();
      return CommunityReport.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 댓글을 신고한다.
  Future<CommunityReport> reportComment({
    required String reporterId,
    required String commentId,
    required String reason,
  }) async {
    try {
      final data = await client.from('community_reports').insert({
        'reporter_id': reporterId,
        'comment_id': commentId,
        'reason': reason,
      }).select().single();
      return CommunityReport.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 처리 대기 중인 신고 목록을 최신순으로 조회한다.
  Future<List<CommunityReport>> getPendingReports() async {
    try {
      final data = await client
          .from('community_reports')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return data.map(CommunityReport.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 신고 처리 상태를 변경한다.
  Future<void> updateStatus(String reportId, ReportStatus status) async {
    try {
      await client
          .from('community_reports')
          .update({'status': status.toJson()})
          .eq('id', reportId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
