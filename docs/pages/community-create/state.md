# 게시글 작성/수정 — 상태 설계

> 화면 ID: `community-create`
> 최종 수정일: 2026-03-07

---

## 상태 데이터 (State)

freezed 클래스: `CommunityCreateState`

| 이름 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `title` | `String` | `''` | 게시글 제목 |
| `content` | `String` | `''` | 게시글 내용 |
| `images` | `List<String>` | `[]` | 첨부 이미지 URL 목록 (최대 5) |
| `isSubmitting` | `bool` | `false` | 제출 중 여부 |
| `isUploadingImage` | `bool` | `false` | 이미지 업로드 중 여부 |
| `errorMessage` | `String?` | `null` | 에러 메시지 |
| `editingPostId` | `String?` | `null` | 수정 모드 시 게시글 ID |
| `isLoadingPost` | `bool` | `false` | 수정 모드 초기 로딩 |

---

## Provider 구조

| Provider | 타입 | 역할 |
|----------|------|------|
| `communityCreateNotifierProvider` | `NotifierProvider<CommunityCreateNotifier, CommunityCreateState>` | 작성/수정 상태 관리 |

### 의존 Provider

| Provider | 소스 |
|----------|------|
| `communityPostRepositoryProvider` | 게시글 create/update |
| `storageRepositoryProvider` | 이미지 업로드 (community-images 버킷) |
| `supabaseProvider` | 현재 사용자 ID |

---

## Notifier 메서드

| 메서드 | 설명 |
|--------|------|
| `updateTitle(String)` | 제목 변경 |
| `updateContent(String)` | 내용 변경 |
| `loadPost(String postId)` | 수정 모드: 기존 게시글 로드 |
| `addImage(Uint8List, String ext)` | 이미지 업로드 (5장 제한) |
| `removeImage(int index)` | 이미지 제거 |
| `submit()` | 유효성 검증 → create/update → true/false |

---

## 유효성 검증

| 필드 | Validator | 시점 |
|------|-----------|------|
| title | `Validators.postTitle` | submit 시 |
| content | `Validators.postContent` | submit 시 |
| images | length <= 5 | addImage 시 |

---

## 데이터 흐름

```
사용자 입력
  └─ CommunityCreateNotifier
       ├─ updateTitle / updateContent → state 갱신
       ├─ addImage → StorageRepository.uploadImage → state.images 추가
       └─ submit → Validators 검증 → CommunityPostRepository.create/update
            └─ 성공 시 true 반환 → 화면에서 pop
```
