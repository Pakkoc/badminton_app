# 게시글 관리 기능 설계

> 작성일: 2026-03-02
> 유형: Change Request (기존 기능 변경)

## 배경

사장님은 현재 게시글 **작성만** 가능하고 수정/삭제/목록 조회가 불가능하다.
"게시글 작성" → **"게시글 관리"**로 변경하여 CRUD 전체를 지원한다.

## 변경 요약

| 항목 | 변경 전 | 변경 후 |
|------|---------|---------|
| 설정 메뉴 항목명 | 게시글 작성 | **게시글 관리** |
| 설정 메뉴 아이콘 | `edit_note` | **`article`** |
| 진입 화면 | PostCreateScreen (바로 작성 폼) | **PostManageScreen (내 게시글 목록)** |
| 라우트 | `/owner/settings/post-create` | **`/owner/settings/post-manage`** |
| 지원 기능 | CREATE | **CREATE, READ, UPDATE, DELETE** |

## 1. 화면 구조 및 네비게이션

### 라우트 구조

```
/owner/settings/post-manage          → PostManageScreen (목록)
/owner/settings/post-manage/create   → PostCreateScreen (작성)
/owner/settings/post-manage/edit/:id → PostCreateScreen (수정 모드)
```

### PostManageScreen (신규)

- **AppBar**: "← 게시글 관리"
- **카테고리 탭**: 전체 / 공지사항 / 이벤트
- **게시글 카드 목록**: 제목, 카테고리 뱃지, 날짜, 편집/삭제 아이콘
- **FAB**: "+" → 새 게시글 작성
- **빈 상태**: EmptyState 위젯
- **삭제**: 카드 삭제 아이콘 → ConfirmDialog → 삭제 후 목록 갱신

### PostCreateScreen (기존 개선)

- **postId 파라미터** 추가: null = 작성, 값 있으면 = 수정
- AppBar: 작성 "게시글 작성" / 수정 "게시글 수정"
- 하단 버튼: 작성 "등록하기" / 수정 "수정하기"
- 수정 모드 진입 시 기존 데이터 로드

## 2. Repository 변경

### PostRepository 추가 메서드

```dart
Future<Post> update(String postId, Post post);
Future<void> delete(String postId);
Future<List<Post>> getByShop(String shopId, {PostCategory? category});
```

### Supabase RLS

- `posts` 테이블: shop_owner가 자기 샵의 게시글을 UPDATE/DELETE 가능 정책 필요

## 3. 상태 관리

### PostManageState (신규, freezed)

```dart
PostManageState {
  posts: List<Post>
  selectedCategory: PostCategory?  // null = 전체
  isLoading: bool
  isDeleting: bool
  errorMessage: String?
}
```

### PostCreateState 변경

```dart
// 기존 필드 유지 + 추가
editingPostId: String?       // null = 작성, 값 있으면 = 수정
isLoadingPost: bool          // 수정 모드 데이터 로드 중
```

## 4. 영향 범위

### 문서

| 문서 | 변경 |
|------|------|
| `docs/screen-registry.yaml` | owner-post-manage 추가, owner-post-create 수정 |
| `docs/ui-specs/post-create.md` | 수정 모드 관련 내용 추가 |
| `docs/ui-specs/post-manage.md` | 신규 작성 |
| Pencil 디자인 | shop-settings 메뉴명 변경, PostManage 화면 추가 |

### 코드

| 파일 | 변경 |
|------|------|
| `lib/repositories/post_repository.dart` | update, delete 추가 |
| `lib/screens/owner/post_create/` | 수정 모드 지원 |
| `lib/screens/owner/post_manage/` | 신규 디렉토리 |
| `lib/app/router.dart` | 라우트 변경 |
| `lib/screens/owner/shop_settings/` | 메뉴 항목명/경로 변경 |

### 테스트

- PostRepository: update, delete 단위 테스트
- PostManageNotifier: 목록 로드, 필터, 삭제 테스트
- PostCreateNotifier: 수정 모드 데이터 로드, 업데이트 테스트
