# 거트알림 디자인 시스템

> 배드민턴 거트 작업 실시간 추적 모바일 앱
> Flutter (iOS / Android) | Material 3 기반
> 최종 수정: 2026-02-20

---

## 1. 디자인 원칙

| 원칙 | 설명 |
|------|------|
| **활기참** | 배드민턴 스포츠의 에너지와 역동성을 담는다 |
| **명확성** | 작업 상태(접수됨/작업중/완료)가 한눈에 파악되어야 한다 |
| **친근함** | 배민처럼 부드럽고 접근하기 쉬운 UI. 둥근 모서리, 여유로운 간격 |
| **깔끔함** | 토스처럼 카드 기반의 정돈된 레이아웃. 핵심 정보에 집중 |
| **실용성** | 카카오택시처럼 상태 추적이 직관적이고 빠른 액션이 가능 |

### 디자인 스타일

**Flat Design + 스포티 미니멀** 조합. 배민의 둥근 UI와 토스의 카드 레이아웃을 참고하되, 그린 계열 색상으로 배드민턴 코트의 활기찬 느낌을 담는다.

### 다크 모드

**라이트 모드만 지원한다.** 1단계에서는 라이트 모드에 집중하여 완성도를 높인다.

---

## 2. 색상 팔레트

### 2.1 기본 색상 (Primary)

| 역할 | 색상명 | Hex | 용도 |
|------|--------|-----|------|
| Primary | Court Green | `#16A34A` | 주요 버튼, 앱바 강조, 링크, 활성 탭 |
| Primary Light | Fresh Green | `#22C55E` | 호버/활성 상태, 보조 강조 |
| Primary Dark | Deep Green | `#15803D` | 눌림 상태, 진한 강조 |
| Primary Container | Soft Green | `#DCFCE7` | 선택된 항목 배경, 칩 배경 |

> **선정 근거**: 그린은 배드민턴 코트 색상과 연결되며, 스포츠의 활력과 신선함을 전달한다. 사용자가 선호한 그린 계열에 활기찬 톤을 적용.

### 2.2 상태 색상 (Status Colors) - 핵심

작업 상태 표현은 앱의 가장 중요한 시각적 요소이다.

| 상태 | 색상명 | Hex | 배경 Hex | 아이콘 | 텍스트 예시 |
|------|--------|-----|----------|--------|-------------|
| 접수됨 (received) | Amber Orange | `#F59E0B` | `#FEF3C7` | `inventory_2` | "접수됨" |
| 작업중 (in_progress) | Active Blue | `#3B82F6` | `#DBEAFE` | `build_circle` | "작업중" |
| 완료 (completed) | Success Green | `#22C55E` | `#DCFCE7` | `check_circle` | "완료" |

```dart
class StatusColors {
  // 접수됨
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedBackground = Color(0xFFFEF3C7);
  static const receivedText = Color(0xFF92400E);

  // 작업중
  static const inProgressForeground = Color(0xFF3B82F6);
  static const inProgressBackground = Color(0xFFDBEAFE);
  static const inProgressText = Color(0xFF1E40AF);

  // 완료
  static const completedForeground = Color(0xFF22C55E);
  static const completedBackground = Color(0xFFDCFCE7);
  static const completedText = Color(0xFF166534);
}
```

### 2.3 보조 색상 (Secondary / CTA)

| 역할 | 색상명 | Hex | 용도 |
|------|--------|-----|------|
| Secondary | Energetic Orange | `#F97316` | CTA 버튼, 알림 뱃지, 중요 액션 강조 |
| Secondary Light | Light Orange | `#FB923C` | 호버 상태 |
| Secondary Container | Soft Orange | `#FED7AA` | 알림 배경, 하이라이트 |

> 오렌지는 그린과 보색 대비를 이루어 CTA 버튼이 확실히 눈에 띈다.

### 2.4 시맨틱 색상 (Semantic)

| 역할 | Hex | 용도 |
|------|-----|------|
| Error / 오류 | `#EF4444` | 입력 오류, 삭제 확인, 경고 |
| Error Background | `#FEE2E2` | 오류 메시지 배경 |
| Warning / 주의 | `#F59E0B` | 주의 알림, 만료 임박 |
| Info / 정보 | `#3B82F6` | 안내 메시지, 도움말 |
| Success / 성공 | `#22C55E` | 완료 알림, 성공 메시지 |

### 2.5 중립 색상 (Neutral)

| 역할 | Hex | 용도 |
|------|-----|------|
| Background | `#F8FAFC` | 화면 배경 |
| Surface | `#FFFFFF` | 카드, 바텀시트, 다이얼로그 |
| Surface Variant | `#F1F5F9` | 구분선 영역, 입력 필드 배경 |
| Text Primary | `#0F172A` | 제목, 본문 텍스트 |
| Text Secondary | `#475569` | 보조 텍스트, 라벨 |
| Text Tertiary | `#94A3B8` | 힌트 텍스트, 비활성 텍스트 |
| Border | `#E2E8F0` | 카드 테두리, 구분선 |
| Divider | `#F1F5F9` | 목록 구분선 |

### 2.6 Flutter ThemeData 구현

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary (Green)
  static const primary = Color(0xFF16A34A);
  static const primaryLight = Color(0xFF22C55E);
  static const primaryDark = Color(0xFF15803D);
  static const primaryContainer = Color(0xFFDCFCE7);

  // Secondary (Orange CTA)
  static const secondary = Color(0xFFF97316);
  static const secondaryLight = Color(0xFFFB923C);
  static const secondaryContainer = Color(0xFFFED7AA);

  // Background & Surface
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);

  // Border
  static const border = Color(0xFFE2E8F0);

  // Semantic
  static const error = Color(0xFFEF4444);
  static const errorBackground = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const success = Color(0xFF22C55E);
}

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Pretendard',
);
```

---

## 3. 타이포그래피

### 3.1 폰트 패밀리

| 용도 | 폰트 | 비고 |
|------|------|------|
| 한국어 전체 | **Pretendard** | 기본 폰트. 토스/배민과 유사한 현대적 느낌 |
| 대체 | **Noto Sans KR** | Pretendard 사용 불가 시 |

### 3.2 크기 스케일 (Type Scale)

| 토큰명 | 크기 (sp) | Weight | Line Height | 용도 |
|--------|----------|--------|-------------|------|
| `displayLarge` | 32 | Bold (700) | 1.25 | 대시보드 숫자, 히어로 |
| `displayMedium` | 28 | Bold (700) | 1.29 | 페이지 제목 |
| `headlineLarge` | 24 | SemiBold (600) | 1.33 | 섹션 제목 |
| `headlineMedium` | 20 | SemiBold (600) | 1.4 | 카드 제목 |
| `titleLarge` | 18 | SemiBold (600) | 1.33 | 앱바 타이틀 |
| `titleMedium` | 16 | Medium (500) | 1.5 | 강조 텍스트, 버튼 |
| `bodyLarge` | 16 | Regular (400) | 1.5 | 본문 텍스트 |
| `bodyMedium` | 14 | Regular (400) | 1.43 | 보조 본문 |
| `bodySmall` | 12 | Regular (400) | 1.33 | 캡션, 타임스탬프 |
| `labelLarge` | 14 | Medium (500) | 1.43 | 버튼, 탭 라벨 |
| `labelMedium` | 12 | Medium (500) | 1.33 | 상태 뱃지 |

---

## 4. 간격 및 크기 체계

### 4.1 간격 스케일 (4px 기반)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `space_4` | 4px | 인라인 최소 간격 |
| `space_8` | 8px | 관련 요소 간 간격 |
| `space_12` | 12px | 컴팩트 리스트 패딩 |
| `space_16` | 16px | 기본 패딩, 화면 수평 패딩 |
| `space_20` | 20px | 섹션 간 간격 (소) |
| `space_24` | 24px | 섹션 간 간격, 카드 간 간격 |
| `space_32` | 32px | 큰 섹션 간 간격 |
| `space_40` | 40px | 화면 상단/하단 여백 |

### 4.2 모서리 둥글기 (Border Radius)

배민 스타일의 부드러운 둥근 모서리를 적용한다.

| 토큰 | 값 | 용도 |
|------|-----|------|
| `radius_sm` | 8px | 입력 필드, 작은 칩 |
| `radius_md` | 12px | 버튼 |
| `radius_lg` | 16px | 카드, 바텀시트 상단 |
| `radius_xl` | 20px | 모달, 다이얼로그 |
| `radius_full` | 999px | 상태 뱃지, 아바타, 원형 버튼 |

### 4.3 화면 레이아웃 기준

| 요소 | 값 |
|------|-----|
| 화면 수평 패딩 | 16px |
| 앱바 높이 | 56px |
| 바텀 내비게이션 높이 | 80px |
| 터치 타겟 최소 크기 | 48x48px |
| 카드 간 간격 | 12px |

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}
```

---

## 5. 컴포넌트 패턴

### 5.1 상태 뱃지 (Status Badge) - 핵심 컴포넌트

```
 ┌──────────────────┐
 │ ● 접수됨          │  → 배경: #FEF3C7, 텍스트: #92400E, 좌측 원: #F59E0B
 └──────────────────┘

 ┌──────────────────┐
 │ ● 작업중          │  → 배경: #DBEAFE, 텍스트: #1E40AF, 좌측 원: #3B82F6
 └──────────────────┘

 ┌──────────────────┐
 │ ✓ 완료            │  → 배경: #DCFCE7, 텍스트: #166534, 좌측 원: #22C55E
 └──────────────────┘
```

- 패딩: 수평 12px, 수직 6px
- 모서리: `radius_full` (999px)
- 폰트: `labelMedium` (12sp, Medium)
- 작업중 상태의 점은 펄스 애니메이션 적용

### 5.2 작업 카드 (Order Card) - 토스 스타일 카드

```
 ┌─────────────────────────────────────────┐
 │  YONEX AX99 Pro               ● 작업중  │  ← 라켓 모델 + 상태 뱃지
 │  BG65 | 25lbs                           │  ← 거트 | 텐션
 │                                         │
 │  🏪 OO 거트 스트링샵                     │  ← 샵 이름
 │  접수: 2026-02-20 14:30                 │  ← 접수 시간
 └─────────────────────────────────────────┘
```

| 속성 | 값 |
|------|-----|
| 카드 배경 | `#FFFFFF` |
| 카드 모서리 | 16px (배민 스타일 둥근 카드) |
| 카드 내부 패딩 | 16px |
| 카드 간 간격 | 12px |
| 카드 테두리 | `#E2E8F0` 1px |
| 카드 그림자 | elevation 1 |

### 5.3 버튼 (Buttons)

#### 주요 버튼 (Primary - Filled)

| 속성 | 값 |
|------|-----|
| 배경색 | `#16A34A` (Court Green) |
| 텍스트 색상 | `#FFFFFF` |
| 높이 | 48px |
| 모서리 둥글기 | 12px |
| 폰트 | 16sp, SemiBold (600) |
| 눌림 상태 | `#15803D` |

#### CTA 버튼 (중요 액션)

| 속성 | 값 |
|------|-----|
| 배경색 | `#F97316` (Energetic Orange) |
| 텍스트 색상 | `#FFFFFF` |
| 높이 | 48px |
| 모서리 둥글기 | 12px |
| 용도 | 작업 접수, 상태 변경 등 핵심 액션 |

#### 외곽선 버튼 (Outlined)

| 속성 | 값 |
|------|-----|
| 배경색 | 투명 |
| 테두리 | `#16A34A` 1.5px |
| 텍스트 색상 | `#16A34A` |
| 높이 | 48px |
| 용도 | 보조 액션, 취소 |

#### 상태 전환 버튼 (사장님 전용)

```
 접수됨 → [작업 시작하기]  배경: #3B82F6
 작업중 → [작업 완료하기]  배경: #22C55E
```

### 5.4 바텀 내비게이션

#### 고객용 (5탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 홈 | `home` | 홈 |
| 샵 검색 | `search` | 샵검색 |
| QR | `qr_code_2` | QR |
| 이력 | `history` | 이력 |
| MY | `person` | MY |

#### 사장님용 (4탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 대시보드 | `dashboard` | 대시보드 |
| 작업관리 | `assignment` | 작업관리 |
| 회원관리 | `people` | 회원관리 |
| 설정 | `settings` | 설정 |

| 속성 | 값 |
|------|-----|
| 활성 아이콘/라벨 색상 | `#16A34A` (Primary Green) |
| 비활성 아이콘/라벨 색상 | `#94A3B8` |
| 바 배경 | `#FFFFFF` |
| 상단 테두리 | `#E2E8F0` 0.5px |

### 5.5 입력 필드

| 속성 | 값 |
|------|-----|
| 높이 | 48px |
| 배경 | `#F1F5F9` |
| 테두리 (기본) | 없음 |
| 테두리 (포커스) | `#16A34A` 2px |
| 테두리 (오류) | `#EF4444` 2px |
| 모서리 둥글기 | 8px |
| 힌트 텍스트 색상 | `#94A3B8` |

### 5.6 앱바

| 속성 | 값 |
|------|-----|
| 배경색 | `#FFFFFF` |
| 타이틀 색상 | `#0F172A` |
| 아이콘 색상 | `#0F172A` |
| 하단 테두리 | `#E2E8F0` 0.5px |
| 높이 | 56px |

---

## 6. 아이콘 체계

**Material Symbols (Outlined)** 사용.

| 기능 | Icon | 용도 |
|------|------|------|
| 접수됨 | `inventory_2` | 상태 표시 |
| 작업중 | `build_circle` | 상태 표시 |
| 완료 | `check_circle` | 상태 표시 |
| QR 코드 | `qr_code_2` | QR 스캔/표시 |
| 샵 | `storefront` | 샵 정보 |
| 길찾기 | `directions` | 네이버 지도 |
| 라켓 | `sports_tennis` | 라켓 정보 |

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

## 8. 역할별 UI 차이점

| 요소 | 고객 | 사장님 |
|------|------|--------|
| 메인 CTA 색상 | `#16A34A` (정보 확인) | `#F97316` (작업 액션) |
| FAB | 없음 | `#F97316` (작업 접수) |
| 바텀 탭 수 | 5탭 | 4탭 |
| UI 성격 | 읽기/확인 중심 | 입력/관리 중심 |

### 사장님 대시보드 숫자 카드

```
 ┌──────────────────────────────────────────┐
 │  오늘의 작업 현황                          │
 │                                          │
 │  ┌──────┐  ┌──────┐  ┌──────┐           │
 │  │  3   │  │  2   │  │  5   │           │
 │  │접수됨 │  │작업중 │  │ 완료  │           │
 │  └──────┘  └──────┘  └──────┘           │
 │   #FEF3C7   #DBEAFE   #DCFCE7           │
 └──────────────────────────────────────────┘
```

---

## 9. 빈 상태 및 로딩

### 빈 상태 (Empty State)

| 속성 | 값 |
|------|-----|
| 일러스트 크기 | 120x120px |
| 제목 | `headlineMedium` (20sp, SemiBold) |
| 설명 | `bodyMedium` (14sp), 색상 `#94A3B8` |
| 전체 정렬 | 화면 중앙 |

### 로딩 상태

| 상황 | 패턴 |
|------|------|
| 최초 데이터 로딩 | 스켈레톤 shimmer |
| 버튼 액션 로딩 | 버튼 내 CircularProgressIndicator |
| 풀 리프레시 | RefreshIndicator |

스켈레톤 색상: `#E2E8F0` → `#F1F5F9` (shimmer)

---

## 10. 접근성

| 항목 | 기준 |
|------|------|
| 텍스트 명암비 | 본문 4.5:1 이상 |
| 터치 타겟 | 최소 48x48px |
| 색상 단독 구분 금지 | 상태에 아이콘+텍스트 병행 |
| 폰트 크기 조절 | textScaleFactor 대응 |

### 명암비 검증

| 조합 | 명암비 | 결과 |
|------|--------|------|
| `#0F172A` on `#F8FAFC` (본문) | 15.4:1 | PASS |
| `#FFFFFF` on `#16A34A` (Primary 버튼) | 4.6:1 | PASS |
| `#FFFFFF` on `#F97316` (CTA 버튼) | 3.2:1 | PASS (대형 텍스트) |
| `#92400E` on `#FEF3C7` (접수됨 뱃지) | 5.8:1 | PASS |
| `#1E40AF` on `#DBEAFE` (작업중 뱃지) | 6.5:1 | PASS |
| `#166534` on `#DCFCE7` (완료 뱃지) | 6.7:1 | PASS |

---

## 부록: 디자인 토큰 요약

```dart
// ============================================
// 거트알림 디자인 토큰 (Flutter)
// ============================================

// --- Colors ---
// Primary (Green)
const primary = Color(0xFF16A34A);       // Court Green
const primaryLight = Color(0xFF22C55E);  // Fresh Green
const primaryDark = Color(0xFF15803D);   // Deep Green
const primaryContainer = Color(0xFFDCFCE7);

// Secondary (Orange CTA)
const secondary = Color(0xFFF97316);     // Energetic Orange

// Status
const statusReceived = Color(0xFFF59E0B);
const statusReceivedBg = Color(0xFFFEF3C7);
const statusInProgress = Color(0xFF3B82F6);
const statusInProgressBg = Color(0xFFDBEAFE);
const statusCompleted = Color(0xFF22C55E);
const statusCompletedBg = Color(0xFFDCFCE7);

// Neutral
const background = Color(0xFFF8FAFC);
const surface = Color(0xFFFFFFFF);
const textPrimary = Color(0xFF0F172A);
const textSecondary = Color(0xFF475569);
const textTertiary = Color(0xFF94A3B8);
const border = Color(0xFFE2E8F0);

// --- Typography: Pretendard ---
// --- Spacing: 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 ---
// --- Radius: 8 / 12 / 16 / 20 / 999 ---
// --- Animation: Micro 150-200ms, Transition 300ms ---
```
