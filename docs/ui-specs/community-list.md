# 커뮤니티 목록 — UI 화면 스펙

> 최종 수정일: 2026-03-07

---

## 1. 화면 개요

| 항목 | 내용 |
|------|------|
| **화면 ID** | `community-list` |
| **화면 명** | 커뮤니티 목록 |
| **Pencil ID** | `gDZ5C` |
| **목적** | 자유게시판 게시글 목록을 조회하고, 검색 및 새 글 작성으로 진입한다 |
| **사용자 역할** | 모든 로그인 사용자 (customer, owner) |
| **진입 조건** | 로그인 필수 |

---

## 2. 레이아웃 구조

```
+----------------------------------+
|  AppBar                          |  56px
|  "커뮤니티"       [검색 아이콘]    |
+----------------------------------+
|  검색바 (토글)                    |  선택적
|  "검색어를 입력하세요"             |
+----------------------------------+
|                                  |
|  게시글 카드 1                    |
|  ┌────────────────────────────┐  |
|  │ 제목 (1줄 말줄임)            │  |
|  │ 작성자 · 시간   댓글N 좋아요N│  |
|  └────────────────────────────┘  |
|        Divider                   |
|  게시글 카드 2 ...               |  ← 스크롤 (Pull-to-refresh)
|                                  |
+----------------------------------+
|  하단 네비게이션 (5탭)            |  80px
|  홈 · 샵검색 · 커뮤니티 · 이력 · MY |
+----------------------------------+
       [FAB: 글쓰기 아이콘]
```

---

## 3. 컴포넌트 상세

### 3.1 AppBar

| 속성 | 값 |
|------|-----|
| 높이 | 56px |
| 배경 | `$--surface` |
| 타이틀 | "커뮤니티", fontSize 18, fontWeight 500 |
| 우측 액션 | 검색 아이콘 (`search` / 검색 중일 때 `close`) |
| 하단 선 | `$--border`, 0.5px |

### 3.2 검색 모드

- 검색 아이콘 탭 시 타이틀이 TextField로 전환
- autofocus, hintText: "검색어를 입력하세요"
- 제목+내용 기준 검색
- close 아이콘 탭 시 검색 해제

### 3.3 게시글 카드 (_PostListTile)

| 속성 | 값 |
|------|-----|
| contentPadding | vertical 8px |
| 제목 | textTheme.titleSmall, 1줄 말줄임 |
| 작성자 | textTheme.bodySmall |
| 시간 | textTheme.bodySmall, color grey |
| 댓글 수 | chat_bubble_outline 14px + count (0이면 미표시) |
| 좋아요 수 | favorite_border 14px + count (0이면 미표시) |
| 이미지 표시 | 이미지 있으면 trailing에 image 아이콘 16px |
| 탭 동작 | `/community/{postId}`로 이동 |

### 3.4 FloatingActionButton

| 속성 | 값 |
|------|-----|
| 아이콘 | `edit` |
| 동작 | `/community/create`로 이동 |

### 3.5 빈 상태

| 속성 | 값 |
|------|-----|
| 아이콘 | article_outlined |
| 메시지 | "게시글이 없습니다" |

### 3.6 하단 네비게이션

| 탭 | 아이콘 | 라벨 | 인덱스 |
|----|--------|------|--------|
| 홈 | home | 홈 | 0 |
| 샵검색 | search | 샵검색 | 1 |
| 커뮤니티 | forum | 커뮤니티 | 2 (활성) |
| 이력 | history | 이력 | 3 |
| MY | person | MY | 4 |

---

## 4. 인터랙션

| 이벤트 | 동작 |
|--------|------|
| Pull-to-refresh | communityPostListProvider 갱신 |
| 카드 탭 | `/community/{postId}` 상세로 이동 |
| 검색 아이콘 탭 | 검색 모드 토글 |
| 검색어 submit | communitySearchProvider로 검색 |
| FAB 탭 | `/community/create`로 이동 |

---

## 5. 에러/로딩 상태

| 상태 | 표시 |
|------|------|
| 로딩 | LoadingIndicator |
| 에러 | ErrorView (메시지 + 재시도 버튼) |
| 빈 목록 | EmptyState |
