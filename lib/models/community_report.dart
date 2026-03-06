import 'package:badminton_app/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_report.freezed.dart';
part 'community_report.g.dart';

@freezed
class CommunityReport with _$CommunityReport {
  const factory CommunityReport({
    required String id,
    @JsonKey(name: 'reporter_id') required String reporterId,
    @JsonKey(name: 'post_id') String? postId,
    @JsonKey(name: 'comment_id') String? commentId,
    required String reason,
    @JsonKey(
      fromJson: ReportStatus.fromJson,
      toJson: _reportStatusToJson,
    )
    required ReportStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CommunityReport;

  factory CommunityReport.fromJson(Map<String, dynamic> json) =>
      _$CommunityReportFromJson(json);
}

String _reportStatusToJson(ReportStatus status) => status.toJson();
