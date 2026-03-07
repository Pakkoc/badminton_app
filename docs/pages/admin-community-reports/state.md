# 커뮤니티 신고 관리 — 상태 설계

> 화면 ID: `admin-community-reports`
> 최종 수정일: 2026-03-07

---

## 상태 데이터 (State)

이 화면은 파일 로컬 FutureProvider로 관리한다. 별도 freezed 상태 클래스 없음.

---

## Provider 구조

| Provider | 타입 | 역할 |
|----------|------|------|
| `_pendingReportsProvider` | `FutureProvider.autoDispose<List<CommunityReport>>` | 대기 중인 신고 목록 조회 |

### 의존 Provider

| Provider | 소스 |
|----------|------|
| `communityReportRepositoryProvider` | 신고 CRUD (getPendingReports, updateStatus) |
| `communityPostRepositoryProvider` | 게시글 조회/삭제 |
| `communityCommentRepositoryProvider` | 댓글 삭제 |
| `notificationRepositoryProvider` | 제재 알림 발송 |

---

## 처리 흐름

### 삭제 및 제재 (_resolveReport)

```
카드 탭 → 바텀시트 모달
  └─ "삭제 및 제재" 탭
       ├─ 게시글 신고: postRepo.getById → postRepo.delete → 알림 발송
       │   (type: communityReport, "커뮤니티 규정 위반으로 게시글이 삭제되었습니다.")
       ├─ 댓글 신고: commentRepo.delete
       └─ reportRepo.updateStatus(resolved) → invalidate → 토스트
```

### 기각 (_dismissReport)

```
카드 탭 → 바텀시트 모달
  └─ "기각" 탭
       └─ reportRepo.updateStatus(dismissed) → invalidate → 토스트
```

---

## 갱신 트리거

| 이벤트 | 갱신 대상 |
|--------|----------|
| 삭제 및 제재 | `ref.invalidate(_pendingReportsProvider)` |
| 기각 | `ref.invalidate(_pendingReportsProvider)` |
