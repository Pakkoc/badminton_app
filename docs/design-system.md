# 거트알림 디자인 시스템

> 배드민턴 거트 작업 실시간 추적 모바일 앱
> Flutter (iOS / Android) | Material 3 기반
> 최종 수정: 2026-03-03

---

## 1. 디자인 원칙

| 원칙 | 설명 |
|------|------|
| **활기참** | 배드민턴 스포츠의 에너지와 역동성을 담는다 |
| **명확성** | 작업 상태(접수됨/작업중/완료)가 한눈에 파악되어야 한다 |
| **친근함** | 동네 스포츠샵처럼 부드럽고 접근하기 쉬운 UI. 둥근 모서리, 여유로운 간격 |
| **깔끔함** | 토스처럼 카드 기반의 정돈된 레이아웃. 핵심 정보에 집중 |
| **실용성** | 카카오택시처럼 상태 추적이 직관적이고 빠른 액션이 가능 |

### 디자인 스타일

**Flat Design + Warm & Sporty** 조합. 배민의 둥근 UI와 토스의 카드 레이아웃을 참고하되, 딥블루 + 앰버 + 웜크림 팔레트로 친근하고 따뜻한 동네 스포츠샵 느낌을 담는다.

### 다크 모드

**라이트 모드만 지원한다.** 다크 모드는 지원하지 않는다.

---

## 2. 색상 팔레트

### 2.1 기본 색상 (Primary — Sporty Blue)

| 역할 | 색상명 | Hex | 용도 |
|------|--------|-----|------|
| Primary | Deep Blue | `#2563EB` | 주요 버튼, 활성 탭, 링크, CTA |
| Primary Light | Sky Blue | `#60A5FA` | 호버/활성 상태, 보조 강조 |
| Primary Dark | Navy Blue | `#1D4ED8` | 눌림 상태, 진한 강조 |
| Primary Container | Soft Blue | `#EFF6FF` | 선택된 항목 배경, 칩 배경 |

> **선정 근거**: 딥블루는 배드민턴 코트의 스포티한 느낌을 전달하면서, 상태 색상(앰버/에메랄드)과 명확히 구분된다. 초록 primary는 완료 상태와 혼동되어 변경.

### 2.2 상태 색상 (Status Colors) — 핵심

작업 상태 표현은 앱의 가장 중요한 시각적 요소이다.

| 상태 | 색상명 | Hex | 배경 Hex | 텍스트 Hex | 아이콘 | 텍스트 예시 |
|------|--------|-----|----------|-----------|--------|-------------|
| 접수됨 (received) | Amber | `#F59E0B` | `#FEF3C7` | `#92400E` | `inventory_2` | "접수됨" |
| 작업중 (in_progress) | Blue | `#2563EB` | `#EFF6FF` | `#1E40AF` | `build_circle` | "작업중" |
| 완료 (completed) | Emerald | `#10B981` | `#D1FAE5` | `#065F46` | `check_circle` | "완료" |

**상태 구분 3중 체계:**
1. **뱃지** — 배경색 + 전경색 + 텍스트로 상태 표시
2. **카드 좌측 컬러바** — 4px 좌측 스트로크로 카드마다 상태 색상 적용
3. **필터 탭 도트** — 6px 컬러 도트로 탭과 상태 연결

```dart
class StatusColors {
  // 접수됨
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedBackground = Color(0xFFFEF3C7);
  static const receivedText = Color(0xFF92400E);

  // 작업중
  static const inProgressForeground = Color(0xFF2563EB);
  static const inProgressBackground = Color(0xFFEFF6FF);
  static const inProgressText = Color(0xFF1E40AF);

  // 완료
  static const completedForeground = Color(0xFF10B981);
  static const completedBackground = Color(0xFFD1FAE5);
  static const completedText = Color(0xFF065F46);
}
```

### 2.3 보조 색상 (Secondary — Warm Amber)

| 역할 | 색상명 | Hex | 용도 |
|------|--------|-----|------|
| Secondary | Warm Amber | `#F59E0B` | 접수됨 상태 전용, 경고 다이얼로그 확인 버튼 |
| Secondary Light | Light Amber | `#FCD34D` | 호버 상태 |

> **중요**: Secondary(앰버)는 **접수됨 상태 전용**이다. CTA 버튼에는 Primary(블루)를 사용한다.

### 2.4 시맨틱 색상 (Semantic)

| 역할 | Hex | 용도 |
|------|-----|------|
| Error / 오류 | `#EF4444` | 입력 오류, 삭제 확인, 경고 |
| Error Background | `#FEE2E2` | 오류 메시지 배경 |
| Warning / 주의 | `#F59E0B` | 주의 알림, 만료 임박 |
| Info / 정보 | `#2563EB` | 안내 메시지, 도움말 |
| Success / 성공 | `#10B981` | 완료 알림, 성공 메시지 |

### 2.5 중립 색상 (Neutral — Warm Tone)

| 역할 | Hex | 용도 |
|------|-----|------|
| Background | `#FBF8F4` | 화면 배경 (웜크림) |
| Surface | `#FFFFFF` | 카드, 바텀시트, 다이얼로그, 앱바 |
| Surface Variant | `#F5F0EB` | 구분선 영역, 입력 필드 배경 (웜베이지) |
| Text Primary | `#1A1A2E` | 제목, 본문 텍스트 (다크네이비) |
| Text Secondary | `#4A4A5A` | 보조 텍스트, 라벨 |
| Text Tertiary | `#9CA3AF` | 힌트 텍스트, 비활성 텍스트 |
| Border | `#E8E0D8` | 카드 테두리, 구분선 (웜보더) |
| Divider | `#F5F0EB` | 목록 구분선 |

### 2.6 소셜 로그인 (브랜드 색상 — 변경 불가)

| 서비스 | Hex | 용도 |
|--------|-----|------|
| 카카오 | `#FEE500` | 카카오 로그인 버튼 배경 |
| 네이버 | `#03C75A` | 네이버 로그인 버튼 배경 |

### 2.7 Flutter ThemeData 구현

```dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Primary (Blue)
  static const courtGreen = Color(0xFF2563EB);  // 역사적 이름 유지, 실제 블루
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryContainer = Color(0xFFEFF6FF);

  // Secondary (Amber — 접수됨 상태 전용)
  static const secondary = Color(0xFFF59E0B);
  static const secondaryLight = Color(0xFFFCD34D);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF4A4A5A);
  static const textTertiary = Color(0xFF9CA3AF);

  // Background & Surface
  static const background = Color(0xFFFBF8F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F0EB);

  // Border
  static const border = Color(0xFFE8E0D8);

  // Semantic
  static const error = Color(0xFFEF4444);
  static const errorBackground = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF2563EB);
  static const success = Color(0xFF10B981);

  // Social Login
  static const kakaoYellow = Color(0xFFFEE500);
  static const naverGreen = Color(0xFF03C75A);

  // Status Badge
  static const receivedBackground = Color(0xFFFEF3C7);
  static const receivedForeground = Color(0xFFF59E0B);
  static const receivedText = Color(0xFF92400E);

  static const inProgressBackground = Color(0xFFEFF6FF);
  static const inProgressForeground = Color(0xFF2563EB);
  static const inProgressText = Color(0xFF1E40AF);

  static const completedBackground = Color(0xFFD1FAE5);
  static const completedForeground = Color(0xFF10B981);
  static const completedText = Color(0xFF065F46);

  // Font
  static const fontFamily = 'Pretendard';

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: courtGreen,
      brightness: Brightness.light,
      primary: courtGreen,
      secondary: secondary,
      surface: surface,
      error: error,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: courtGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: courtGreen,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: courtGreen, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: courtGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: textSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: textTertiary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary),
    ),
    dividerColor: border,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: courtGreen,
      unselectedItemColor: textTertiary,
    ),
  );
}
```

---

## 3. 타이포그래피

### 3.1 폰트 패밀리

| 용도 | 폰트 | 비고 |
|------|------|------|
| 한국어 전체 | **Pretendard** | Inter 기반 한글 확장 폰트. 한영 혼용 최적화, 9 Weight (100~900) |

### 3.2 크기 스케일 (Type Scale)

| 토큰명 | 크기 (sp) | Weight | Line Height | 용도 |
|--------|----------|--------|-------------|------|
| `displayLarge` | 32 | Bold (700) | 1.25 | 히어로 텍스트 |
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
| **대시보드 숫자** | 36 | Bold (700) | 1.2 | 대시보드 통계 카운트 (커스텀) |

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

| 토큰 | 값 | 용도 |
|------|-----|------|
| `radius_sm` | 8px | 작은 칩 |
| `radius_md` | 14px | 버튼, 입력 필드 |
| `radius_lg` | 20px | 카드, 바텀시트 상단, 다이얼로그 |
| `radius_full` | 999px | 상태 뱃지, 아바타, 원형 버튼, 필터 탭 |

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
  static const double md = 14;
  static const double lg = 20;
  static const double full = 999;
}
```

---

## 5. 컴포넌트 패턴

### 5.1 상태 뱃지 (Status Badge) — 핵심 컴포넌트

```
 ┌──────────────────┐
 │ ● 접수됨          │  → 배경: #FEF3C7, 텍스트: #92400E, 좌측 원: #F59E0B
 └──────────────────┘

 ┌──────────────────┐
 │ ● 작업중          │  → 배경: #EFF6FF, 텍스트: #1E40AF, 좌측 원: #2563EB
 └──────────────────┘

 ┌──────────────────┐
 │ ✓ 완료            │  → 배경: #D1FAE5, 텍스트: #065F46, 좌측 원: #10B981
 └──────────────────┘
```

- 패딩: 수평 12px, 수직 6px
- 모서리: `radius_full` (999px)
- 폰트: `labelMedium` (12sp, Medium)
- 작업중 상태의 점은 펄스 애니메이션 적용

### 5.2 작업 카드 (Order Card) — 좌측 컬러바 패턴

```
 ┌─────────────────────────────────────────┐
 ┃  ● 작업중                               │  ← 상태 뱃지
 ┃  OO 거트 스트링샵                        │  ← 샵 이름
 ┃  📅 접수 14:30                           │  ← 접수 시간
 └─────────────────────────────────────────┘
 ↑ 좌측 3px 컬러바 (상태별 색상)
```

| 속성 | 값 |
|------|-----|
| 카드 배경 | `#FFFFFF` (`$--surface`) |
| 카드 모서리 | 20px (`radius_lg`) |
| 카드 내부 패딩 | 16px |
| 카드 간 간격 | 12px |
| 카드 테두리 | `#E8E0D8` (`$--border`) 0.5px |
| 카드 그림자 | `blur: 8, color: #0000000D, offset: {x:0, y:2}` |
| **좌측 컬러바** | 4px, 상태별 색상 (접수=#F59E0B, 작업중=#2563EB, 완료=#10B981) |

### 5.3 버튼 (Buttons)

#### 주요 버튼 (Primary — Filled)

| 속성 | 값 |
|------|-----|
| 배경색 | `#2563EB` (Deep Blue) |
| 텍스트 색상 | `#FFFFFF` |
| 높이 | 48px |
| 모서리 둥글기 | 14px (`radius_md`) |
| 폰트 | 16sp, SemiBold (600) |
| 눌림 상태 | `#1D4ED8` |

#### 상태 전환 버튼 (사장님 전용)

| 현재 상태 | 버튼 텍스트 | 버튼 색상 |
|-----------|------------|----------|
| 접수됨 | "작업 시작" | `#2563EB` (Primary) |
| 작업중 | "작업 완료" | `#2563EB` (Primary) |
| 완료 | (버튼 숨김) | — |

> **규칙**: CTA/액션 버튼은 모두 **Primary(블루)**를 사용한다. 상태 색상(앰버/에메랄드)은 **표시용**으로만 사용한다.

#### 외곽선 버튼 (Outlined)

| 속성 | 값 |
|------|-----|
| 배경색 | 투명 |
| 테두리 | `#2563EB` 1.5px |
| 텍스트 색상 | `#2563EB` |
| 높이 | 48px |
| 용도 | 보조 액션, 취소 |

#### 다이얼로그 확인 버튼 (의미 기반 색상)

| 액션 유형 | 버튼 색상 | 예시 |
|-----------|----------|------|
| 일반 확인 | `#2563EB` (Primary) | 상태 변경 |
| 경고/주의 | `#F59E0B` (Amber) | 로그아웃 |
| 파괴적 | `#EF4444` (Error) | 삭제 |

### 5.4 바텀 내비게이션

#### 고객용 (4탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 홈 | `home` | 홈 |
| 샵 검색 | `search` | 샵검색 |
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
| 활성 아이콘/라벨 색상 | `#2563EB` (`$--primary`) |
| 비활성 아이콘/라벨 색상 | `#9CA3AF` (`$--text-tertiary`) |
| 바 배경 | `#FFFFFF` (`$--surface`) |
| 상단 테두리 | `#E8E0D8` (`$--border`) 0.5px |
| 바 높이 | 80px (Safe Area 포함) |
| 아이콘 폰트 | Material Symbols Rounded |
| 아이콘 크기 | 24px |
| 라벨 폰트 크기 | 10sp |
| 아이콘-라벨 간격 | 4px |

### 5.5 입력 필드

| 속성 | 값 |
|------|-----|
| 높이 | 48px |
| 배경 | `#F5F0EB` (`$--surface-variant`) |
| 테두리 (기본) | `#E8E0D8` 1px |
| 테두리 (포커스) | `#2563EB` 2px |
| 테두리 (오류) | `#EF4444` 2px |
| 모서리 둥글기 | 14px (`radius_md`) |
| 힌트 텍스트 색상 | `#9CA3AF` |

### 5.6 앱바

| 속성 | 값 |
|------|-----|
| 배경색 | `#FFFFFF` (`$--surface`) |
| 타이틀 색상 | `#1A1A2E` (`$--text-primary`) |
| 타이틀 폰트 (메인 탭) | 20sp, Bold |
| 타이틀 폰트 (서브 화면) | 18sp, SemiBold |
| 아이콘 색상 | `#1A1A2E` (`$--text-primary`) |
| 하단 테두리 | 없음 (elevation 0) |
| 높이 | 56px |

### 5.7 지도 마커

| 속성 | 값 |
|------|-----|
| 마커 형태 | 원형 배경 + 아이콘 |
| 마커 크기 | 28x28px |
| 마커 배경 | `#2563EB` (`$--primary`) |
| 아이콘 | `storefront` (Material Symbols Outlined) |
| 아이콘 크기 | 14px |
| 아이콘 색상 | `#FFFFFF` |
| 선택된 마커 크기 | 32x32px |
| 선택된 마커 배경 | `#1D4ED8` (Primary Dark) |

### 5.8 토스트 바

| 속성 | 값 |
|------|-----|
| 배경색 | `#1A1A2E` (다크네이비) |
| 텍스트 색상 | `#FFFFFF` |
| 모서리 둥글기 | 20px |
| 아이콘 색상 | `#FFFFFF` |

### 5.9 FAB (플로팅 액션 버튼)

| 속성 | 값 |
|------|-----|
| 배경색 | `#2563EB` (`$--primary`) |
| 아이콘 | `add`, `#FFFFFF` |
| 크기 | 56x56px |
| 모서리 | 원형 (28px) |
| 그림자 | `blur: 16, color: #2563EB40, offset: {x:0, y:4}` |

---

## 6. 아이콘 체계

**Material Symbols (Rounded)** 사용.

| 기능 | Icon | 용도 |
|------|------|------|
| 접수됨 | `inventory_2` | 상태 표시 |
| 작업중 | `build_circle` | 상태 표시 |
| 완료 | `check_circle` | 상태 표시 |
| QR 코드 | `qr_code_2` | QR 스캔/표시 |
| 샵 | `storefront` | 샵 정보, 빈 상태 |
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

> **구현 참고**: Splash 화면과 빈 상태에 Lottie 일러스트 애니메이션 추가 권장. 배드민턴 셔틀콕/라켓 모티프 사용.

---

## 8. 역할별 UI 차이점

| 요소 | 고객 | 사장님 |
|------|------|--------|
| 메인 CTA 색상 | `#2563EB` (Primary) | `#2563EB` (Primary) |
| FAB | 없음 | `#2563EB` (작업 접수) |
| 바텀 탭 수 | 4탭 | 3탭 |
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
 │   #FEF3C7   #EFF6FF   #D1FAE5           │
 │   숫자36sp  숫자36sp  숫자36sp            │
 └──────────────────────────────────────────┘
```

---

## 9. 빈 상태 및 로딩

### 빈 상태 (Empty State)

| 속성 | 값 |
|------|-----|
| 아이콘 크기 | 64px |
| 아이콘 색상 | `#F59E0B` (Amber) 또는 `#2563EB` (Primary) |
| 제목 | `headlineMedium` (20sp, SemiBold) |
| 설명 | `bodyMedium` (14sp), 색상 `#9CA3AF` |
| 전체 정렬 | 화면 중앙 |

> **구현 참고**: 빈 상태에 커스텀 일러스트(배드민턴 셔틀콕/라켓/상점) 추가 시 더 친근한 느낌. Lottie 애니메이션 권장.

### 로딩 상태

| 상황 | 패턴 |
|------|------|
| 최초 데이터 로딩 | 스켈레톤 shimmer |
| 버튼 액션 로딩 | 버튼 내 CircularProgressIndicator |
| 풀 리프레시 | RefreshIndicator |

스켈레톤 색상: `#E8E0D8` → `#F5F0EB` (shimmer)

---

## 10. 접근성

| 항목 | 기준 |
|------|------|
| 텍스트 명암비 | 본문 4.5:1 이상 |
| 터치 타겟 | 최소 48x48px |
| 색상 단독 구분 금지 | 상태에 아이콘+텍스트+컬러바 병행 |
| 폰트 크기 조절 | textScaleFactor 대응 |

### 명암비 검증

| 조합 | 명암비 | 결과 |
|------|--------|------|
| `#1A1A2E` on `#FBF8F4` (본문) | 14.2:1 | PASS |
| `#FFFFFF` on `#2563EB` (Primary 버튼) | 4.6:1 | PASS |
| `#92400E` on `#FEF3C7` (접수됨 뱃지) | 5.8:1 | PASS |
| `#1E40AF` on `#EFF6FF` (작업중 뱃지) | 7.2:1 | PASS |
| `#065F46` on `#D1FAE5` (완료 뱃지) | 7.1:1 | PASS |

---

## 부록: 색상 변경 이력 (2026-03-03)

### 변경 사유
기존 Green 단색 팔레트가 "AI스러운" 제네릭 느낌을 주어, "친근한 동네 스포츠샵" 컨셉에 맞게 **Warm & Sporty Blue** 팔레트로 전면 교체.

### 주요 변경 내역

| 영역 | 이전 (Green) | 이후 (Blue) |
|------|-------------|-------------|
| Primary | `#22C55E` / `#16A34A` (Green) | `#2563EB` (Deep Blue) |
| Secondary | `#F97316` (Orange, CTA용) | `#F59E0B` (Amber, 접수됨 상태 전용) |
| Background | `#F8FAFC` (쿨그레이) | `#FBF8F4` (웜크림) |
| Surface Variant | `#F1F5F9` (쿨그레이) | `#F5F0EB` (웜베이지) |
| Text Primary | `#0F172A` | `#1A1A2E` (다크네이비) |
| Border | `#E2E8F0` | `#E8E0D8` (웜보더) |
| Completed Status | `#22C55E` (Primary와 혼동) | `#10B981` (에메랄드, 구분됨) |
| CTA 버튼 역할 | Secondary(오렌지) 사용 | Primary(블루) 통일 |
| 카드 스타일 | 테두리만 | 테두리 + 그림자 + 좌측 컬러바 |
| Font | Gmarket Sans | Pretendard |
| 카드 모서리 | 16px | 20px |
| 버튼/입력 모서리 | 12px / 8px | 14px |
| 대시보드 숫자 | 32sp | 36sp |
| FAB 색상 | `#FB923C` (Secondary) | `#2563EB` (Primary) |
| 토스트 배경 | `#22C55E` (Primary) | `#1A1A2E` (다크네이비) |

### 새로 추가된 디자인 요소

| 요소 | 설명 |
|------|------|
| **카드 좌측 컬러바** | 3px 좌측 스트로크, 상태별 색상으로 카드 식별 |
| **필터 탭 상태 도트** | 6px 컬러 도트로 탭-상태 연결 |
| **알림 아이콘 배경색** | 상태별 아이콘 배경색 매핑 |
| **타임라인 컬러** | 완료 단계 연결선 착색 + 현재 단계 블루 하이라이트 |
| **품절 카드 빨간 보더** | 재고 0인 아이템에 `#EF4444` 보더 |
| **FAB 블루 글로우** | Primary 색상 기반 그림자 효과 |
| **토글 블루 글로우** | 활성 토글에 Primary 색상 글로우 |
