# Pencil 디자인 전체 동기화 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Pencil에서 전면 변경된 다크 그린(배드민턴 코트) 테마를 25개 화면 + 13개 오버레이의 Flutter 코드에 반영한다.

**Architecture:** Phase 0에서 테마/공통 위젯을 먼저 변경한 뒤, 3개 팀(implementer agent)이 화면을 병렬로 구현하고, implement-checker + code-reviewer로 더블체크한다. 비즈니스 로직은 유지하고 UI 레이어만 Pencil 기준으로 재작성한다.

**Tech Stack:** Flutter 3.38.x, Riverpod 2.6.x, freezed, go_router, Supabase, Material 3, Pretendard

---

## 디자인 변경 요약

### 기존 테마 (Light)
| 영역 | 값 |
|------|-----|
| 배경 | #FBF8F4 (Warm Cream) |
| 카드 | #FFFFFF (White) + border #E8E0D8 |
| AppBar | White |
| 텍스트 | #1A1A2E (Dark Navy) / #4A4A5A / #9CA3AF |
| Primary | #2563EB (Blue) |
| BottomNav | White |

### 새 테마 (Dark Green Court)
| 영역 | 값 |
|------|-----|
| 배경 | Linear gradient #000000 → #2D5A27 (180°) |
| 카드/Surface | #ffffff15 (White 8%) + cornerRadius 20 |
| AppBar | #ffffff15 + border-bottom #ffffff20 0.5px |
| 텍스트 | #FFFFFFEE (93%) / #FFFFFFAA (67%) / #FFFFFF66 (40%) |
| Primary | #2D5A27 (Court Green) |
| Accent | #F59E0B (Amber) — CTA 버튼, 다이얼로그 아이콘 |
| BottomNav | #ffffff15 + border-top #ffffff20 0.5px |
| 다이얼로그 | #1A2E1A + shadow blur 24 |
| 코트 라인 | #FFFFFFA3 (장식, 좌/우/상/하 boundary) |
| 소셜 로그인 | 카카오 #FEE500, 네이버 #03C75A, Gmail white |

### 상태 색상 (유지)
| 상태 | 배경 | 전경 | 텍스트 |
|------|------|------|--------|
| 접수됨 | #FEF3C7 | #F59E0B | #92400E |
| 작업중 | #EFF6FF | #2563EB | #1E40AF |
| 완료 | #D1FAE5 | #10B981 | #065F46 |

---

## Phase 0: 기반 변경 (Sequential — 반드시 먼저 완료)

> Phase 0은 모든 화면의 공통 기반이므로 병렬화하지 않는다.
> 이 단계가 끝나야 Phase 1~2를 시작할 수 있다.

### Task 0.1: design-system.md 업데이트

**Files:**
- Modify: `docs/design-system.md`

**Step 1:** Pencil 디자인에서 추출한 새 색상 팔레트로 design-system.md의 색상 섹션을 업데이트한다.

**핵심 변경:**
- 배경: Warm Cream → Dark Green Gradient
- Surface: White → White 8% opacity
- 텍스트: Dark Navy → White variants
- Primary: Blue → Court Green
- Accent: Amber (신규)
- 코트 라인 장식 요소 추가

**Step 2:** 커밋
```bash
git add docs/design-system.md
git commit -m "docs: 다크 그린 테마로 디자인 시스템 업데이트"
```

---

### Task 0.2: AppTheme 전면 재작성

**Files:**
- Modify: `lib/app/theme.dart`

**Step 1:** 새 색상 상수 정의

```dart
class AppTheme {
  AppTheme._();

  // ── Court Green (Primary) ──────────
  static const primary = Color(0xFF2D5A27);
  static const primaryLight = Color(0xFF3D7A35);
  static const primaryDark = Color(0xFF1A3E18);

  // ── Accent (Amber — CTA, 다이얼로그) ──
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFCD34D);

  // ── Background (Gradient) ──────────
  static const backgroundStart = Color(0xFF000000);
  static const backgroundEnd = Color(0xFF2D5A27);
  // Scaffold 단색 fallback
  static const background = Color(0xFF162E14);

  // ── Surface (Glass-like) ───────────
  static const surface = Color(0x26FFFFFF);        // White 15%
  static const surfaceBorder = Color(0x33FFFFFF);   // White 20%
  static const surfaceVariant = Color(0x1AFFFFFF);  // White 10%

  // ── Dialog ─────────────────────────
  static const dialogSurface = Color(0xFF1A2E1A);

  // ── Text ───────────────────────────
  static const textPrimary = Color(0xEEFFFFFF);    // White 93%
  static const textSecondary = Color(0xAAFFFFFF);   // White 67%
  static const textTertiary = Color(0x66FFFFFF);    // White 40%

  // ── Court Line (장식) ──────────────
  static const courtLine = Color(0xA3FFFFFF);       // White 64%

  // ── Border ─────────────────────────
  static const border = Color(0x33FFFFFF);          // White 20%

  // ── Semantic ───────────────────────
  static const error = Color(0xFFEF4444);
  static const errorBackground = Color(0x33EF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);

  // ── Social Login ───────────────────
  static const kakaoYellow = Color(0xFFFEE500);
  static const naverGreen = Color(0xFF03C75A);

  // ── Status Badge (유지) ────────────
  static const receivedBackground = Color(0xFFFEF3C7);
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedText = Color(0xFF92400E);
  static const inProgressBackground = Color(0xFFEFF6FF);
  static const inProgressForeground = Color(0xFF2563EB);
  static const inProgressText = Color(0xFF1E40AF);
  static const completedBackground = Color(0xFFD1FAE5);
  static const completedForeground = Color(0xFF10B981);
  static const completedText = Color(0xFF065F46);

  // ── Font ───────────────────────────
  static const fontFamily = 'Pretendard';

  /// 배경 그라데이션 (모든 Scaffold에서 사용)
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundStart, backgroundEnd],
  );
}
```

**Step 2:** ThemeData 재작성 — dark 기반

```dart
static ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: accent,           // CTA = Amber
    secondary: primary,        // Court Green
    surface: dialogSurface,
    error: error,
  ),
  scaffoldBackgroundColor: background,
  // AppBar — 반투명 글래스
  appBarTheme: AppBarTheme(
    backgroundColor: surface,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: false,        // 새 디자인은 좌측 정렬
    surfaceTintColor: Colors.transparent,
  ),
  // ... 전체 컴포넌트 테마 업데이트
);
```

**Step 3:** `lightTheme` → `darkTheme` 이름 변경, main.dart 참조 수정

**Step 4:** 빌드 확인
```bash
cd C:/dev/badminton_app && flutter analyze
```

**Step 5:** 커밋
```bash
git commit -m "feat: 다크 그린 배드민턴 코트 테마로 AppTheme 전면 재작성"
```

---

### Task 0.3: 배경 그라데이션 래퍼 위젯 생성

**Files:**
- Create: `lib/widgets/court_background.dart`

모든 화면에서 사용할 배드민턴 코트 배경 위젯:

```dart
/// 배드민턴 코트 배경 + 장식 라인.
/// 모든 Scaffold의 body를 이 위젯으로 감싼다.
class CourtBackground extends StatelessWidget {
  const CourtBackground({
    super.key,
    required this.child,
    this.showCourtLines = true,
  });

  final Widget child;
  final bool showCourtLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          if (showCourtLines) const _CourtLines(),
          child,
        ],
      ),
    );
  }
}

class _CourtLines extends StatelessWidget {
  const _CourtLines();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CourtLinePainter(),
        ),
      ),
    );
  }
}
```

**Step:** 테스트 + 커밋

---

### Task 0.4: 공통 위젯 다크 테마 적용

**Files:**
- Modify: `lib/widgets/status_badge.dart`
- Modify: `lib/widgets/empty_state.dart`
- Modify: `lib/widgets/error_view.dart`
- Modify: `lib/widgets/loading_indicator.dart`
- Modify: `lib/widgets/confirm_dialog.dart`
- Modify: `lib/widgets/app_toast.dart`
- Modify: `lib/widgets/customer_bottom_nav.dart`
- Modify: `lib/widgets/skeleton_shimmer.dart`

**핵심 변경:**
- `Colors.white` → `AppTheme.textPrimary`
- `AppTheme.background` (크림) → `AppTheme.surface` (글래스)
- `Theme.of(context).colorScheme.onSurface` → `AppTheme.textPrimary`
- BottomNav: 배경 `#ffffff15`, 선택 색상 `#F59E0B`(Amber)
- Dialog: 배경 `#1A2E1A`, 아이콘 Amber, 텍스트 white variants

**Step:** 각 위젯 수정 → 위젯 테스트 → 커밋

---

### Task 0.5: 기존 테스트 수정 및 전체 테스트 통과 확인

**Step 1:** 전체 테스트 실행
```bash
cd C:/dev/badminton_app && flutter test
```

**Step 2:** 테마 변경으로 깨진 테스트 수정 (색상 비교 등)

**Step 3:** 모든 테스트 통과 확인 후 커밋
```bash
git commit -m "fix: 다크 그린 테마 적용에 따른 테스트 수정"
```

---

## Phase 1: UI 스펙 동기화 (Sequential)

> `/design-sync` 스킬로 Pencil → UI 스펙 25개 파일을 업데이트한다.
> 이 단계는 Phase 2 시작 전에 완료되어야 한다.

### Task 1.1: 전체 UI 스펙 동기화

모든 화면의 UI 스펙을 Pencil 디자인 기준으로 업데이트:

```
docs/ui-specs/splash.md           ← Pencil 75vDs
docs/ui-specs/login.md            ← Pencil hI7MJ
docs/ui-specs/signup.md           ← Pencil s2pzz
docs/ui-specs/shop-signup.md      ← Pencil PdstH
docs/ui-specs/customer-home.md    ← Pencil 0b6dS
docs/ui-specs/order-detail.md     ← Pencil l7Ghq
docs/ui-specs/order-history.md    ← Pencil cdfXb
docs/ui-specs/shop-search.md      ← Pencil KMb0t
docs/ui-specs/shop-detail.md      ← Pencil S4mUF
docs/ui-specs/notifications.md    ← Pencil fKRz8
docs/ui-specs/post-list.md        ← Pencil 0htm7
docs/ui-specs/post-detail.md      ← Pencil gkn1s
docs/ui-specs/mypage.md           ← Pencil xz11L
docs/ui-specs/profile-edit.md     ← Pencil eHCxi
docs/ui-specs/owner-dashboard.md  ← Pencil ExImm
docs/ui-specs/order-create.md     ← Pencil HEBtI
docs/ui-specs/order-manage.md     ← Pencil UVpp2
docs/ui-specs/shop-settings.md    ← Pencil qQBpR
docs/ui-specs/shop-qr.md          ← Pencil PYHid
docs/ui-specs/post-manage.md      ← Pencil v8qFN
docs/ui-specs/post-create.md      ← Pencil zQq8F
docs/ui-specs/inventory-manage.md ← Pencil frCH8
docs/ui-specs/community-list.md   ← Pencil gDZ5C
docs/ui-specs/community-detail.md ← Pencil t1yQo
docs/ui-specs/community-create.md ← Pencil YwMLh
```

**Step:** 화면별로 `batch_get` → 스펙 3.x절 업데이트 → 커밋

---

## Phase 2: 화면 구현 (3 Teams Parallel)

> 3개 implementer agent가 각자 할당된 화면을 독립적으로 구현한다.
> 각 agent는 `flutter-dev` 스킬의 가이드를 참조한다.
> **비즈니스 로직(Provider, Repository, Model)은 유지하고 UI 위젯만 Pencil 기준으로 재작성한다.**

### 화면별 공통 변경 사항

모든 화면에 적용되는 변경:

1. **Scaffold body → CourtBackground로 래핑**
2. **AppBar**: 배경 `AppTheme.surface`, 텍스트 `AppTheme.textPrimary`
3. **카드**: 배경 `AppTheme.surface`, 모서리 20px, border `AppTheme.border`
4. **텍스트**: white variant 색상으로 변경
5. **BottomNav**: `AppTheme.surface` 배경, Amber 선택 색상
6. **코트 라인**: 장식용 boundary line 추가 (CourtBackground에서 처리)

---

### Team A: 인증 + 고객 핵심 (8개 화면)

**Implementer Agent #1**

| # | 화면 | Pencil ID | 변형 |
|---|------|-----------|------|
| A1 | Splash | 75vDs | — |
| A2 | Login | hI7MJ | — |
| A3 | Profile Setup (Signup) | s2pzz | — |
| A4 | Shop Signup Step2 | PdstH | — |
| A5 | Customer Home | 0b6dS | Empty (Vdujm) |
| A6 | Order Detail | l7Ghq | — |
| A7 | Order History | cdfXb | Empty (7wPRw) |
| A8 | Notifications | fKRz8 | — |

**구현 순서:** A1 → A2 → A3 → A4 → A5 → A6 → A7 → A8

**각 화면별 작업:**
1. `batch_get`으로 Pencil 노드 분석
2. UI 스펙(docs/ui-specs/)과 대조표 작성
3. 기존 screen 파일의 UI 위젯만 재작성 (Provider/State 유지)
4. `get_screenshot`으로 디자인 대조
5. 위젯 테스트 수정/추가
6. 커밋

---

### Team B: 고객 탐색 + 커뮤니티 (9개 화면)

**Implementer Agent #2**

| # | 화면 | Pencil ID | 변형 |
|---|------|-----------|------|
| B1 | Shop Search | KMb0t | — |
| B2 | Shop Detail | S4mUF | Inventory Tab (KTMja) |
| B3 | Post List | 0htm7 | — |
| B4 | Post Detail | gkn1s | — |
| B5 | Mypage | xz11L | Dialog-Logout (FBY2O) |
| B6 | Profile Edit | eHCxi | — |
| B7 | Community List | gDZ5C | — |
| B8 | Community Detail | t1yQo | — |
| B9 | Community Create | YwMLh | — |

**구현 순서:** B1 → B2 → B3 → B4 → B5 → B6 → B7 → B8 → B9

---

### Team C: 사장님 흐름 (8개 화면)

**Implementer Agent #3**

| # | 화면 | Pencil ID | 변형 |
|---|------|-----------|------|
| C1 | Owner Dashboard | ExImm | Empty (l9xSh) |
| C2 | Order Create | HEBtI | No Result (r915A) |
| C3 | Order Manage | UVpp2 | Empty (fgXTt) |
| C4 | Shop Settings | qQBpR | — |
| C5 | Shop QR Code | PYHid | — |
| C6 | Post Manage | v8qFN | — |
| C7 | Post Create | zQq8F | — |
| C8 | Inventory Manage | frCH8 | Add BS (4eLmy), Edit BS (66Y7D) |

**구현 순서:** C1 → C2 → C3 → C4 → C5 → C6 → C7 → C8

---

## Phase 3: 공유 오버레이/다이얼로그 (Sequential)

Phase 2 완료 후 남은 공유 컴포넌트:

| # | 컴포넌트 | Pencil ID | 위치 |
|---|---------|-----------|------|
| 3.1 | Dialog - Status Change | QWByd | lib/widgets/confirm_dialog.dart |
| 3.2 | Dialog - Delete | EU8lB | lib/widgets/confirm_dialog.dart |
| 3.3 | Toast - Order Created | 7GHl1 | lib/widgets/app_toast.dart |
| 3.4 | Toast - Save Success | O5x3Q | lib/widgets/app_toast.dart |
| 3.5 | Address Search BottomSheet | nAfQv | 해당 화면 내부 |
| 3.6 | Report Action Modal | Gzbfz | admin 화면 내부 |

---

## Phase 4: 검증 (Sequential — 3단계 검증)

### Task 4.1: implement-checker (스펙 준수 검증)

각 팀의 작업물을 **implement-checker agent**로 검증:

```
검증 축:
1. UI 스펙 대조표 — 스펙 3.x절의 모든 컴포넌트가 코드에 존재하는가?
2. Pencil 디자인 대조 — get_screenshot과 코드 UI가 일치하는가?
3. 색상/텍스트 — AppTheme 사용, 하드코딩 없음 확인
4. 상태 관리 — Provider/Notifier가 기존 로직과 동일한가?
```

### Task 4.2: code-reviewer (코드 품질 검증)

```
검증 축:
1. flutter-dev 스킬의 quality-checklist 기준
2. const 사용, private 위젯, helper 메서드 금지
3. ref.watch/read 올바른 사용
4. 공통 위젯 재사용 확인
```

### Task 4.3: verification-before-completion (최종 검증)

```bash
# 전체 테스트 통과
flutter test

# 정적 분석 통과
dart analyze

# 빌드 성공
bash scripts/build.sh
```

---

## 실행 요약

```
Phase 0  ─────── [기반: 테마 + 공통 위젯] ────────── (순차)
    ↓
Phase 1  ─────── [UI 스펙 25개 동기화] ────────────── (순차)
    ↓
Phase 2  ┌─ Team A: 인증 + 고객 핵심 (8개) ─────┐
         ├─ Team B: 고객 탐색 + 커뮤니티 (9개) ──┤  (병렬)
         └─ Team C: 사장님 흐름 (8개) ───────────┘
    ↓
Phase 3  ─────── [공유 오버레이/다이얼로그] ──────── (순차)
    ↓
Phase 4  ─────── [3단계 검증] ─────────────────────── (순차)
         4.1 implement-checker (스펙 준수)
         4.2 code-reviewer (코드 품질)
         4.3 verification (테스트/빌드)
```

**예상 커밋 수:** Phase 0 (5) + Phase 1 (5) + Phase 2 (25) + Phase 3 (3) + Phase 4 (2) = ~40 커밋
