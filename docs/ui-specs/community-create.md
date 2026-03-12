# 게시글 작성/수정 — UI 화면 스펙

> 최종 수정일: 2026-03-12

---

## 1. 화면 개요

| 항목 | 내용 |
|------|------|
| **화면 ID** | `community-create` |
| **화면 명** | 게시글 작성/수정 |
| **Pencil ID** | `YwMLh` |
| **목적** | 커뮤니티 게시글 작성 및 수정 (이미지 첨부 포함) |
| **사용자 역할** | 모든 로그인 사용자 |
| **진입 조건** | 로그인 필수. 수정 시 editingPostId 파라미터 필요 |

---

## 2. 레이아웃 구조

```
+----------------------------------+
|  AppBar                          |  56px
|  [뒤로]  "게시글 작성"            |
+----------------------------------+
|                                  |
|  제목 *                          |  라벨
|  ┌────────────────────────────┐  |
|  │ 제목을 입력하세요             │  |  48px, cornerRadius 14
|  └────────────────────────────┘  |
|                                  |
|  내용 *                          |  라벨
|  ┌────────────────────────────┐  |
|  │ 내용을 입력하세요             │  |  160px, cornerRadius 14
|  └────────────────────────────┘  |
|                                  |
|  이미지 (최대 5장)                |  라벨
|  [+추가] [미리보기1] [미리보기2]  |  72x72, cornerRadius 8
|                                  |
|  (여백)                          |
|                                  |
+----------------------------------+
|  하단 바                          |
|  [ 등록하기 ] (primary, full)     |  48px, cornerRadius 12
+----------------------------------+
```

---

## 3. 컴포넌트 상세

### 3.1 AppBar

| 속성 | 값 |
|------|-----|
| 높이 | 56px |
| 좌측 | 뒤로 아이콘 (arrow_back) |
| 타이틀 | "게시글 작성", fontSize 18, fontWeight 500 |
| 하단 선 | `$--border`, 0.5px |

### 3.2 제목 입력

| 속성 | 값 |
|------|-----|
| 라벨 | "제목 *", fontSize 14, fontWeight 500 |
| 높이 | 48px |
| 배경 | `$--surface-variant` |
| 모서리 | cornerRadius 14 |
| placeholder | "제목을 입력하세요", fontSize 14 |
| 패딩 | horizontal 14 |

### 3.3 내용 입력

| 속성 | 값 |
|------|-----|
| 라벨 | "내용 *", fontSize 14, fontWeight 500 |
| 높이 | 160px |
| 배경 | `$--surface-variant` |
| 모서리 | cornerRadius 14 |
| placeholder | "내용을 입력하세요", fontSize 14 |
| 패딩 | 14 |

### 3.4 이미지 섹션

| 속성 | 값 |
|------|-----|
| 라벨 | "이미지 (최대 5장)", fontSize 14, fontWeight 500 |
| 추가 버튼 | 72x72, `$--surface-variant`, add_photo_alternate 아이콘 28px |
| 미리보기 | 72x72, cornerRadius 8, 삭제(X) 버튼 포함 |
| 최대 | 5장 |

### 3.5 등록 버튼

| 속성 | 값 |
|------|-----|
| 위치 | 하단 바 (상단 border 0.5px) |
| 너비 | fill, 48px |
| 배경 | `$--primary` |
| 텍스트 | "등록하기", fontSize 16, fontWeight 600, white |
| 모서리 | cornerRadius 12 |

---

## 4. 인터랙션

| 이벤트 | 동작 |
|--------|------|
| 제목 입력 | updateTitle |
| 내용 입력 | updateContent |
| 이미지 추가 | 갤러리에서 선택 → addImage (5장 초과 시 에러) |
| 이미지 삭제 | removeImage(index) |
| 등록하기 | submit() → 유효성 검증 → create/update → pop |

---

## 5. 유효성 검증

| 필드 | 규칙 |
|------|------|
| 제목 | Validators.postTitle (필수, 길이 제한) |
| 내용 | Validators.postContent (필수, 길이 제한) |
| 이미지 | 최대 5장 |

---

## 6. 에러/로딩 상태

| 상태 | 표시 |
|------|------|
| 이미지 업로드 중 | isUploadingImage |
| 제출 중 | isSubmitting, 버튼 비활성화 |
| 에러 | errorMessage 표시 |
| 수정 모드 로딩 | isLoadingPost |
