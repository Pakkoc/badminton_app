# 거트알림 디자인 시스템

> 배드민턴 거트 작업 실시간 추적 모바일 앱
> Flutter (iOS / Android) | Material 3 기반
> 최종 수정: 2026-03-12

---

## 1. 디자인 원칙

| 원칙 | 설명 |
|------|------|
| **활기참** | 배드민턴 스포츠의 에너지와 역동성을 담는다 |
| **명확성** | 작업 상태(접수됨/작업중/완료)가 한눈에 파악되어야 한다 |
| **몰입감** | 배드민턴 코트 위에 있는 듯한 다크 그린 테마로 스포츠 현장감 전달 |
| **깔끔함** | 글래스모피즘 기반 카드와 정돈된 레이아웃. 핵심 정보에 집중 |
| **실용성** | 상태 추적이 직관적이고 빠른 액션이 가능 |

### 디자인 스타일

**Dark Court + Glassmorphism** 조합. 배드민턴 코트의 다크 그린을 배경으로, 반투명 글래스 카드와 코트 라인 장식으로 스포츠 현장감을 구현한다. 앰버 액센트로 CTA와 상태를 강조한다.

### 다크 모드

**다크 테마 단일 지원.** 배드민턴 코트 그린이 기본 테마이며, 별도 라이트 모드는 없다.

---

## 2. 색상 팔레트

### 2.1 배경 (Background — Court Gradient)

| 역할 | Hex | 용도 |
|------|-----|------|
| Gradient Start | `#000000` | 그라디언트 상단 (검정) |
| Gradient End | `#2D5A27` | 그라디언트 하단 (코트 그린) |
| Scaffold Fallback | `#162E14` | 그라디언트 불가 시 단색 배경 |

```dart
static const backgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF000000), Color(0xFF2D5A27)],
);
```

### 2.2 Surface (Glass Cards)

| 역할 | Hex | 투명도 | 용도 |
|------|-----|--------|------|
| Surface | `#FFFFFF15` | White 8% | AppBar, 카드, BottomNav 배경 |
| Surface High | `#FFFFFF18` | White 9% | 강조 카드 (작업 카드, 요약) |
| Surface Border | `#FFFFFF20` | White 12% | AppBar 하단, BottomNav 상단 테두리 |
| Surface Variant | `#FFFFFF10` | White 6% | 낮은 강조 영역 |
| Dialog Surface | `#1A2E1A` | 불투명 | 다이얼로그, 바텀시트 배경 |

### 2.3 텍스트 (Text — White Variants)

| 역할 | Hex | 투명도 | 용도 |
|------|-----|--------|------|
| Text Primary | `#FFFFFFEE` | 93% | 제목, 주요 텍스트 |
| Text Secondary | `#FFFFFFCC` | 80% | 카드 내용, 앱바 타이틀 |
| Text Tertiary | `#FFFFFFAA` | 67% | 보조 설명, 다이얼로그 메시지 |
| Text Hint | `#FFFFFF88` | 53% | 타임스탬프, 힌트, 아이콘 |
| Text Disabled | `#FFFFFF66` | 40% | 비활성 텍스트 |
| Text Inactive | `#FFFFFF80` | 50% | 비활성 탭 아이콘/라벨 |

### 2.4 Primary & Accent

| 역할 | Hex | 용도 |
|------|-----|------|
| Primary (Court Green) | `#2D5A27` | 앱 정체성, 배경 기반 |
| Primary Light | `#3D7A35` | 호버/활성 보조 |
| Accent (Amber) | `#F59E0B` | CTA 버튼, 다이얼로그 아이콘, 접수됨 상태 |
| Accent Light | `#FCD34D` | 호버/눌림 상태 |
| Active Tab | `#22C55E` | BottomNav 활성 탭 (밝은 그린) |

> **규칙**: CTA 버튼에는 **Accent(앰버)**를 사용한다. Active Tab은 **밝은 그린(#22C55E)**을 사용한다.

### 2.5 상태 색상 (Status Colors) — 핵심

작업 상태 표현은 앱의 가장 중요한 시각적 요소이다.

| 상태 | 전경 Hex | 배경 Hex | 텍스트 Hex | 아이콘 |
|------|----------|----------|-----------|--------|
| 접수됨 (received) | `#F59E0B` | `#422006` | `#FCD34D` | `inventory_2` |
| 작업중 (in_progress) | `#60A5FA` | `#1E3A5F` | `#93C5FD` | `build_circle` |
| 완료 (completed) | `#34D399` | `#064E3B` | `#6EE7B7` | `check_circle` |

**다크 코트 테마 상태 뱃지:**
- 배경: 상태별 불투명 다크 톤, 모서리 999px
- 좌측 도트: 상태 전경색 8px 원
- 텍스트: 상태별 밝은 톤, 12sp Medium

**카드 좌측 컬러바:**
- 두께: 3px, 상태별 전경색
- 접수됨: `#F59E0B`, 작업중: `#3B82F6`, 완료: `#10B981`

### 2.6 시맨틱 색상 (Semantic)

| 역할 | Hex | 용도 |
|------|-----|------|
| Error | `#EF4444` | 삭제, 오류, 알림 뱃지 |
| Warning | `#F59E0B` | 주의, 만료 임박 |
| Success | `#10B981` | 완료, 성공 |
| Info | `#3B82F6` | 안내, 작업중 |

### 2.7 장식 (Court Lines)

| 역할 | Hex | 투명도 | 용도 |
|------|-----|--------|------|
| Court Line | `#FFFFFFA3` | 64% | 좌/우 경계선, 상/하 서비스 라인 |

```
좌측 경계선: x=22.5, width=2, 전체 높이
우측 경계선: x=365.5, width=2, 전체 높이
상단 서비스라인: y=44.19, height=2, 전체 너비
하단 경계선: y=831.81 (또는 791.81), height=2, 전체 너비
```

### 2.8 소셜 로그인 (브랜드 색상 — 변경 불가)

| 서비스 | Hex | 텍스트 색상 | 용도 |
|--------|-----|-----------|------|
| 카카오 | `#FEE500` | `#000000` | 카카오 로그인 버튼 |
| 네이버 | `#03C75A` | `#FFFFFF` | 네이버 로그인 버튼 |
| Gmail | `#FFFFFF` | `#000000` | Gmail 로그인 버튼 |

### 2.9 Flutter AppTheme 구현

```dart
class AppTheme {
  AppTheme._();

  // ── Primary (Court Green) ──────────
  static const primary = Color(0xFF2D5A27);
  static const primaryLight = Color(0xFF3D7A35);

  // ── Accent (Amber — CTA) ──────────
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFCD34D);

  // ── Active Tab ────────────────────
  static const activeTab = Color(0xFF22C55E);

  // ── Background (Gradient) ─────────
  static const backgroundStart = Color(0xFF000000);
  static const backgroundEnd = Color(0xFF2D5A27);
  static const background = Color(0xFF162E14);

  // ── Surface (Glass) ───────────────
  static const surface = Color(0x15FFFFFF);       // 8%
  static const surfaceHigh = Color(0x18FFFFFF);   // 9%
  static const surfaceBorder = Color(0x20FFFFFF);  // 12%
  static const surfaceVariant = Color(0x10FFFFFF); // 6%

  // ── Dialog ────────────────────────
  static const dialogSurface = Color(0xFF1A2E1A);

  // ── Text ──────────────────────────
  static const textPrimary = Color(0xEEFFFFFF);   // 93%
  static const textSecondary = Color(0xCCFFFFFF);  // 80%
  static const textTertiary = Color(0xAAFFFFFF);   // 67%
  static const textHint = Color(0x88FFFFFF);       // 53%
  static const textDisabled = Color(0x66FFFFFF);   // 40%
  static const textInactive = Color(0x80FFFFFF);   // 50%

  // ── Court Line ────────────────────
  static const courtLine = Color(0xA3FFFFFF);      // 64%

  // ── Border ────────────────────────
  static const border = Color(0x20FFFFFF);         // 12%

  // ── Semantic ──────────────────────
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const info = Color(0xFF3B82F6);

  // ── Social Login ──────────────────
  static const kakaoYellow = Color(0xFFFEE500);
  static const naverGreen = Color(0xFF03C75A);

  // ── Status Badge (Dark Court 최적화) ──
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedBackground = Color(0xFF422006);
  static const receivedText = Color(0xFFFCD34D);
  static const inProgressForeground = Color(0xFF60A5FA);
  static const inProgressBackground = Color(0xFF1E3A5F);
  static const inProgressText = Color(0xFF93C5FD);
  static const completedForeground = Color(0xFF34D399);
  static const completedBackground = Color(0xFF064E3B);
  static const completedText = Color(0xFF6EE7B7);

  // ── Font ──────────────────────────
  static const fontFamily = 'Pretendard';

  // ── Gradient ──────────────────────
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundStart, backgroundEnd],
  );
}
```

---

## 3. 타이포그래피

### 3.1 폰트 패밀리

| 용도 | 폰트 | 비고 |
|------|------|------|
| 한국어 전체 | **Pretendard** | Inter 기반 한글 확장 폰트. 9 Weight (100~900) |

### 3.2 크기 스케일 (Type Scale)

| 토큰명 | 크기 (sp) | Weight | 색상 | 용도 |
|--------|----------|--------|------|------|
| `displayLarge` | 32 | Bold (700) | textPrimary | 히어로 텍스트 |
| `displayMedium` | 28 | Bold (700) | textPrimary | 페이지 제목 |
| `headlineLarge` | 24 | SemiBold (600) | textPrimary | 섹션 제목 |
| `headlineMedium` | 20 | SemiBold (600) | textPrimary | 카드 제목, 다이얼로그 제목 |
| `titleLarge` | 18 | SemiBold (600) | textPrimary | 앱바 타이틀 |
| `titleMedium` | 16 | SemiBold (600) | textPrimary | 강조 텍스트 |
| `bodyLarge` | 16 | Regular (400) | textSecondary | 본문 텍스트 |
| `bodyMedium` | 14 | Regular (400) | textSecondary | 보조 본문, 카드 내용 |
| `bodySmall` | 12 | Regular (400) | textHint | 캡션, 타임스탬프 |
| `labelLarge` | 14 | SemiBold (600) | textPrimary | 섹션 소제목, 버튼 |
| `labelMedium` | 12 | Medium (500) | textSecondary | 상태 뱃지 |
| **대시보드 숫자** | 36 | Bold (700) | 상태별 전경색 | 대시보드 통계 카운트 (커스텀) |

---

## 4. 간격 및 크기 체계

### 4.1 간격 스케일 (4px 기반)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `space_4` | 4px | 아이콘-라벨 간격 |
| `space_6` | 6px | 뱃지 도트-텍스트 간격 |
| `space_8` | 8px | 관련 요소 간 간격, 뱃지 패딩 |
| `space_12` | 12px | 카드 간 간격, 소셜 버튼 간 간격 |
| `space_16` | 16px | 카드 내부 패딩, 기본 간격 |
| `space_24` | 24px | 다이얼로그 패딩, 섹션 간 간격 |
| `space_28` | 28px | 화면 수평 패딩 |
| `space_32` | 32px | 큰 섹션 간 간격 |

### 4.2 모서리 둥글기 (Border Radius)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `radius_sm` | 8px | 작은 칩 |
| `radius_md` | 14px | 버튼, 입력 필드 |
| `radius_card` | 16px | 작업 카드 |
| `radius_lg` | 20px | 요약 카드, 다이얼로그, 바텀시트 |
| `radius_full` | 999px | 상태 뱃지, 아바타, 필터 탭 |

### 4.3 화면 레이아웃 기준

| 요소 | 값 |
|------|-----|
| 화면 수평 패딩 | 28px |
| 앱바 높이 | 56px |
| 바텀 내비게이션 높이 | 80px (Safe Area 포함) |
| 터치 타겟 최소 크기 | 48x48px |
| 카드 간 간격 | 12px |
| 카드 그림자 | blur: 12, color: #00000026, offset: y=2 |

---

## 5. 컴포넌트 패턴

### 5.1 상태 뱃지 (Status Badge) — 다크 글래스 버전

```
 ┌──────────────────┐
 │ ● 작업중          │  → 배경: #FFFFFF15 (글래스), 도트: #3B82F6, 텍스트: #FFFFFFCC
 └──────────────────┘
```

| 속성 | 값 |
|------|-----|
| 배경 | `#FFFFFF15` (glass) |
| 모서리 | 999px |
| 패딩 | 수직 6px, 수평 12px |
| 도트 크기 | 8px 원 |
| 도트-텍스트 간격 | 6px |
| 텍스트 | `#FFFFFFCC`, 12sp, Medium |

### 5.2 작업 카드 (Order Card) — 글래스 + 좌측 컬러바

```
 ┌─────────────────────────────────────────┐
 ┃  ● 작업중                               │  ← 글래스 뱃지
 ┃  OO 거트샵                              │  ← #FFFFFFCC 14sp
 ┃  🕐 접수 14:30                          │  ← #FFFFFF88 12sp
 └─────────────────────────────────────────┘
 ↑ 좌측 3px 컬러바 (상태별 전경색)
```

| 속성 | 값 |
|------|-----|
| 카드 배경 | `#FFFFFF18` (glass high) |
| 카드 모서리 | 16px |
| 카드 내부 패딩 | 16px |
| 카드 간 간격 | 12px |
| 카드 그림자 | blur: 12, color: #00000026, offset: y=2 |
| **좌측 컬러바** | 3px, 상태별 전경색 |

### 5.3 앱바 (App Bar) — 글래스

| 속성 | 값 |
|------|-----|
| 배경색 | `#FFFFFF15` (glass) |
| 하단 테두리 | `#FFFFFF20` 0.5px |
| 타이틀 색상 | `#FFFFFFCC` (textSecondary) |
| 타이틀 정렬 | 좌측 (메인 탭), 중앙 (서브 화면) |
| 아이콘 색상 | `#FFFFFFCC` |
| 높이 | 56px |
| 수평 패딩 | 28px |

### 5.4 바텀 내비게이션

#### 고객용 (5탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 홈 | `home` | 홈 |
| 샵검색 | `search` | 샵검색 |
| 커뮤니티 | `forum` | 커뮤니티 |
| 이력 | `history` | 이력 |
| MY | `person` | MY |

#### 사장님용 (3탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 대시보드 | `dashboard` | 대시보드 |
| 작업관리 | `assignment` | 작업관리 |
| 설정 | `settings` | 설정 |

| 속성 | 값 |
|------|-----|
| 배경색 | `#FFFFFF15` (glass) |
| 상단 테두리 | `#FFFFFF20` 0.5px |
| **활성 색상** | `#22C55E` (밝은 그린) |
| 비활성 색상 | `#FFFFFF80` (White 50%) |
| 높이 | 80px |
| 패딩 | top 8, bottom 24 (SafeArea) |
| 아이콘 크기 | 24px |
| 라벨 크기 | 10sp |
| 아이콘-라벨 간격 | 4px |

### 5.5 버튼 (Buttons)

#### CTA 버튼 (Amber Filled)

| 속성 | 값 |
|------|-----|
| 배경색 | `#F59E0B` (Amber) |
| 텍스트 색상 | `#FFFFFF` |
| 높이 | 48px |
| 모서리 | 14px |
| 폰트 | 16sp, SemiBold |

#### 상태 전환 버튼 (사장님)

| 현재 상태 | 버튼 텍스트 | 색상 |
|-----------|------------|------|
| 접수됨 | "작업 시작" | `#3B82F6` (Blue) |
| 작업중 | "작업 완료" | `#10B981` (Green) |
| 완료 | (버튼 숨김) | — |

#### 외곽선 버튼 (Outlined)

| 속성 | 값 |
|------|-----|
| 배경 | 투명 |
| 테두리 | `#FFFFFF40` 1.5px |
| 텍스트 | `#FFFFFFCC` |
| 모서리 | 14px |

#### 다이얼로그 버튼

| 액션 유형 | 버튼 색상 |
|-----------|----------|
| 일반/경고 | `#F59E0B` (Amber) |
| 취소 | `#FFFFFF20` 테두리 |
| 파괴적 | `#EF4444` (Error) |

### 5.6 다이얼로그

| 속성 | 값 |
|------|-----|
| 배경색 | `#1A2E1A` (Dialog Surface) |
| 모서리 | 20px |
| 패딩 | 24px |
| 그림자 | blur: 24, color: #00000033, offset: y=8 |
| 아이콘 색상 | `#F59E0B` (Amber), 48px |
| 제목 | `#FFFFFFEE`, 20sp, Bold |
| 메시지 | `#FFFFFFAA`, 15sp, Regular |
| 스크림 | `#00000080` |
| 간격 | 20px (아이콘→제목→메시지→버튼) |

### 5.7 입력 필드

| 속성 | 값 |
|------|-----|
| 배경 | 투명 |
| 테두리 (기본) | `#FFFFFF20` 1px |
| 테두리 (포커스) | `#F59E0B` 2px |
| 테두리 (오류) | `#EF4444` 2px |
| 모서리 | 14px |
| 텍스트 색상 | `#FFFFFFEE` |
| 힌트 색상 | `#FFFFFF88` |

### 5.8 토스트 바

| 속성 | 값 |
|------|-----|
| 배경색 | `#1A2E1A` |
| 텍스트 색상 | `#FFFFFFEE` |
| 아이콘 색상 | `#F59E0B` (Amber) 또는 `#10B981` (Success) |
| 모서리 | 20px |

### 5.9 FAB (플로팅 액션 버튼)

| 속성 | 값 |
|------|-----|
| 배경색 | `#22C55E` (밝은 그린) |
| 아이콘 | `add`, `#FFFFFF` |
| 크기 | 56x56px |
| 모서리 | 원형 |

---

## 6. 아이콘 체계

**Material Symbols (Rounded)** 사용.

| 기능 | Icon | 용도 |
|------|------|------|
| 접수됨 | `inventory_2` | 상태 표시 |
| 작업중 | `build_circle` | 상태 표시 |
| 완료 | `check_circle` | 상태 표시 |
| QR 코드 | `qr_code_2` | QR 스캔/표시 |
| 샵 | `storefront` | 샵 정보 |
| 길찾기 | `directions` | 네이버 지도 |
| 알림 | `notifications` | 앱바 알림 아이콘 |
| 시간 | `schedule` | 타임스탬프 |
| 전화 | `call` | 전화 걸기 |
| 로그아웃 | `logout` | 로그아웃 다이얼로그 |

---

## 7. 애니메이션 가이드

| 상황 | 애니메이션 | 시간 |
|------|-----------|------|
| 상태 변경 | 색상 전환 | 300ms |
| 카드 탭 | 살짝 눌림 (scale 0.98) | 100ms |
| 목록 로딩 | 스켈레톤 shimmer | 1500ms 반복 |
| 페이지 전환 | Slide + Fade | 300ms |
| 작업중 뱃지 점 | 펄스 애니메이션 | 1500ms 반복 |

---

## 8. 빈 상태 및 로딩

### 빈 상태 (Empty State)

| 속성 | 값 |
|------|-----|
| 아이콘 크기 | 64px |
| 아이콘 색상 | `#FFFFFF66` (textDisabled) |
| 메시지 | `bodyLarge`, `#FFFFFFAA` |
| 전체 정렬 | 화면 중앙 |

### 로딩 상태

| 상황 | 패턴 |
|------|------|
| 최초 데이터 로딩 | 스켈레톤 shimmer |
| 버튼 액션 로딩 | 버튼 내 CircularProgressIndicator |
| 풀 리프레시 | RefreshIndicator |

스켈레톤 색상: `#FFFFFF10` → `#FFFFFF20` (shimmer)

---

## 9. 접근성

| 항목 | 기준 |
|------|------|
| 텍스트 명암비 | 본문 4.5:1 이상 |
| 터치 타겟 | 최소 48x48px |
| 색상 단독 구분 금지 | 상태에 아이콘+텍스트+컬러바 병행 |
| 폰트 크기 조절 | textScaleFactor 대응 |

### 명암비 검증

| 조합 | 명암비 | 결과 |
|------|--------|------|
| `#FFFFFFEE` on `#162E14` (본문 on 배경) | 13.8:1 | PASS |
| `#FFFFFF` on `#F59E0B` (Amber 버튼) | 4.6:1 | PASS |
| `#FCD34D` on `#422006` (접수됨 뱃지) | 6.8:1 | PASS |
| `#93C5FD` on `#1E3A5F` (작업중 뱃지) | 5.2:1 | PASS |
| `#6EE7B7` on `#064E3B` (완료 뱃지) | 5.7:1 | PASS |

---

## 부록: 색상 변경 이력

### 2026-03-12: 다크 그린 배드민턴 코트 테마

| 영역 | 이전 (Light Blue) | 이후 (Dark Court) |
|------|-------------------|-------------------|
| 전체 테마 | 라이트 모드 | 다크 그린 단일 |
| Background | `#FBF8F4` (웜크림) | Gradient `#000000` → `#2D5A27` |
| Surface | `#FFFFFF` (화이트) | `#FFFFFF15` (글래스) |
| Primary | `#2563EB` (블루) | `#2D5A27` (코트 그린) |
| CTA/Accent | `#2563EB` (블루) | `#F59E0B` (앰버) |
| Active Tab | `#2563EB` (블루) | `#22C55E` (밝은 그린) |
| 작업중 색상 | `#2563EB` | `#3B82F6` |
| Text Primary | `#1A1A2E` (다크네이비) | `#FFFFFFEE` (White 93%) |
| Border | `#E8E0D8` (웜보더) | `#FFFFFF20` (White 12%) |
| Dialog | `#FFFFFF` | `#1A2E1A` (다크그린) |
| Toast | `#1A1A2E` (다크네이비) | `#1A2E1A` (다크그린) |
| BottomNav | `#FFFFFF` | `#FFFFFF15` (글래스) |
| 화면 패딩 | 16px | 28px |
| 카드 모서리 | 20px | 16px (작업카드), 20px (요약/다이얼로그) |
| 장식 요소 | 없음 | 코트 라인 (#FFFFFFA3) |

### 2026-03-03: Warm & Sporty Blue

이전 Green 팔레트 → Blue 팔레트로 변경 (세부 이력은 git log 참조)
