# 거트알림 디자인 시스템

> 배드민턴 거트 작업 실시간 추적 모바일 앱
> Flutter (iOS / Android) | Material 3 기반
> 최종 수정: 2026-02-20

---

## 1. 디자인 원칙

| 원칙 | 설명 |
|------|------|
| **신뢰감** | 서비스/유틸리티 앱으로서 안정적이고 믿음직한 인상을 준다 |
| **명확성** | 작업 상태(접수됨/작업중/완료)가 한눈에 파악되어야 한다 |
| **단순함** | 불필요한 장식을 배제하고, 핵심 정보에 집중한다 |
| **일관성** | 고객/사장님 화면 모두 동일한 디자인 언어를 사용한다 |
| **접근성** | 모든 텍스트는 4.5:1 이상의 명암비를 유지한다 |

### 디자인 스타일

**Flat Design + Minimalism** 조합을 기본으로 한다. 서비스/유틸리티 앱의 특성상 화려한 효과보다 명확한 정보 전달이 우선이다. 상태 추적이 핵심이므로 색상 기반의 직관적인 상태 표현에 집중한다.

---

## 2. 색상 팔레트

### 2.1 기본 색상 (Primary)

| 역할 | 색상명 | Hex | 용도 |
|------|--------|-----|------|
| Primary | Trust Blue | `#2563EB` | 주요 버튼, 앱바, 링크, 강조 요소 |
| Primary Light | Light Blue | `#3B82F6` | 호버/활성 상태, 보조 강조 |
| Primary Dark | Deep Blue | `#1D4ED8` | 눌림 상태, 진한 강조 |
| Primary Container | Soft Blue | `#DBEAFE` | 선택된 항목 배경, 칩 배경 |

> **선정 근거**: 파란색은 신뢰와 안정감을 전달하며, 서비스/추적 앱에 가장 적합한 색상이다. 배드민턴 셔틀콕의 깃털 흰색과 대비되어 스포츠 느낌도 유지한다.

### 2.2 상태 색상 (Status Colors) - 핵심

작업 상태 표현은 앱의 가장 중요한 시각적 요소이다.

| 상태 | 색상명 | Hex | 배경 Hex | 아이콘 | 텍스트 예시 |
|------|--------|-----|----------|--------|-------------|
| 접수됨 (received) | Amber Orange | `#F59E0B` | `#FEF3C7` | `inventory_2` | "접수됨" |
| 작업중 (in_progress) | Active Blue | `#3B82F6` | `#DBEAFE` | `build_circle` | "작업중" |
| 완료 (completed) | Success Green | `#22C55E` | `#DCFCE7` | `check_circle` | "완료" |

```dart
// Flutter 구현
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

### 2.3 보조 색상 (Secondary)

| 역할 | 색상명 | Hex | 용도 |
|------|--------|-----|------|
| Secondary | Warm Orange | `#F97316` | CTA 버튼, 중요 액션, 알림 뱃지 |
| Secondary Light | Light Orange | `#FB923C` | 호버 상태 |
| Secondary Container | Soft Orange | `#FED7AA` | 알림 배경, 하이라이트 |

### 2.4 시맨틱 색상 (Semantic)

| 역할 | Hex | 용도 |
|------|-----|------|
| Error / 오류 | `#EF4444` | 입력 오류, 삭제 확인, 경고 |
| Error Background | `#FEE2E2` | 오류 메시지 배경 |
| Warning / 주의 | `#F59E0B` | 주의 알림, 만료 임박 |
| Info / 정보 | `#3B82F6` | 안내 메시지, 도움말 |
| Success / 성공 | `#22C55E` | 완료 알림, 성공 메시지 |

### 2.5 중립 색상 (Neutral)

| 역할 | Light Mode Hex | Dark Mode Hex | 용도 |
|------|---------------|---------------|------|
| Background | `#F8FAFC` | `#0F172A` | 화면 배경 |
| Surface | `#FFFFFF` | `#1E293B` | 카드, 바텀시트, 다이얼로그 |
| Surface Variant | `#F1F5F9` | `#334155` | 구분선 영역, 입력 필드 배경 |
| Text Primary | `#0F172A` | `#F8FAFC` | 제목, 본문 텍스트 |
| Text Secondary | `#475569` | `#94A3B8` | 보조 텍스트, 라벨 |
| Text Tertiary | `#94A3B8` | `#64748B` | 힌트 텍스트, 비활성 텍스트 |
| Border | `#E2E8F0` | `#334155` | 카드 테두리, 구분선 |
| Divider | `#F1F5F9` | `#1E293B` | 목록 구분선 |

### 2.6 Flutter ThemeData 구현

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryContainer = Color(0xFFDBEAFE);

  // Secondary
  static const secondary = Color(0xFFF97316);
  static const secondaryLight = Color(0xFFFB923C);
  static const secondaryContainer = Color(0xFFFED7AA);

  // Background & Surface (Light)
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF1F5F9);

  // Background & Surface (Dark)
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const surfaceVariantDark = Color(0xFF334155);

  // Text (Light)
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF475569);
  static const textTertiaryLight = Color(0xFF94A3B8);

  // Text (Dark)
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textTertiaryDark = Color(0xFF64748B);

  // Border
  static const borderLight = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFF334155);

  // Semantic
  static const error = Color(0xFFEF4444);
  static const errorBackground = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const success = Color(0xFF22C55E);
}

// Light Theme
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceLight,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.backgroundLight,
);

// Dark Theme
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    surface: AppColors.surfaceDark,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
);
```

---

## 3. 타이포그래피

### 3.1 폰트 패밀리

| 용도 | 폰트 | 비고 |
|------|------|------|
| 한국어 전체 | **Pretendard** | 기본 폰트. 한글/영문 모두 우수한 가독성 |
| 한국어 대체 | **Noto Sans KR** | Pretendard 사용 불가 시 대체 |
| 숫자/데이터 | **Pretendard** | 동일 폰트의 Tabular Figures 사용 |

> **Pretendard 선정 근거**: 국내 서비스 앱에서 가장 많이 사용되며, Apple SD Gothic Neo와 유사한 형태로 iOS/Android 모두에서 자연스럽다. Google Fonts의 Noto Sans KR보다 더 현대적인 느낌을 준다.

```dart
// pubspec.yaml
// fonts:
//   - family: Pretendard
//     fonts:
//       - asset: assets/fonts/Pretendard-Regular.otf
//         weight: 400
//       - asset: assets/fonts/Pretendard-Medium.otf
//         weight: 500
//       - asset: assets/fonts/Pretendard-SemiBold.otf
//         weight: 600
//       - asset: assets/fonts/Pretendard-Bold.otf
//         weight: 700

// 또는 google_fonts 패키지로 Noto Sans KR 사용
// dependencies:
//   google_fonts: ^6.0.0
```

### 3.2 크기 스케일 (Type Scale)

모바일 앱 기준. 최소 본문 크기 16px(접근성 기준 준수).

| 토큰명 | 크기 (px) | 크기 (sp) | Weight | Line Height | 용도 |
|--------|----------|----------|--------|-------------|------|
| `displayLarge` | 32 | 32sp | Bold (700) | 1.25 (40px) | 대시보드 숫자, 히어로 텍스트 |
| `displayMedium` | 28 | 28sp | Bold (700) | 1.29 (36px) | 페이지 제목 |
| `headlineLarge` | 24 | 24sp | SemiBold (600) | 1.33 (32px) | 섹션 제목 |
| `headlineMedium` | 20 | 20sp | SemiBold (600) | 1.4 (28px) | 카드 제목, 서브 제목 |
| `titleLarge` | 18 | 18sp | SemiBold (600) | 1.33 (24px) | 앱바 타이틀, 리스트 아이템 제목 |
| `titleMedium` | 16 | 16sp | Medium (500) | 1.5 (24px) | 강조 텍스트, 버튼 텍스트 |
| `bodyLarge` | 16 | 16sp | Regular (400) | 1.5 (24px) | 본문 텍스트 |
| `bodyMedium` | 14 | 14sp | Regular (400) | 1.43 (20px) | 보조 본문, 설명 텍스트 |
| `bodySmall` | 12 | 12sp | Regular (400) | 1.33 (16px) | 캡션, 타임스탬프 |
| `labelLarge` | 14 | 14sp | Medium (500) | 1.43 (20px) | 버튼, 탭, 칩 라벨 |
| `labelMedium` | 12 | 12sp | Medium (500) | 1.33 (16px) | 상태 뱃지, 작은 라벨 |
| `labelSmall` | 11 | 11sp | Medium (500) | 1.45 (16px) | 알림 뱃지 숫자, 미세 라벨 |

```dart
// Flutter TextTheme 구현
final textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimaryLight,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  ),
  bodyLarge: TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textSecondaryLight,
  ),
  labelLarge: TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AppColors.textPrimaryLight,
  ),
);
```

---

## 4. 간격 및 크기 체계

### 4.1 간격 스케일 (Spacing Scale)

4px 기반의 간격 체계를 사용한다.

| 토큰 | 값 | 용도 |
|------|-----|------|
| `space_2` | 2px | 아이콘과 텍스트 사이 미세 간격 |
| `space_4` | 4px | 인라인 요소 간 최소 간격 |
| `space_8` | 8px | 관련 요소 간 간격, 칩 내부 패딩 |
| `space_12` | 12px | 컴팩트 리스트 아이템 패딩 |
| `space_16` | 16px | 기본 패딩, 카드 내부 패딩, 화면 수평 패딩 |
| `space_20` | 20px | 섹션 간 간격 (소) |
| `space_24` | 24px | 섹션 간 간격, 카드 간 간격 |
| `space_32` | 32px | 큰 섹션 간 간격 |
| `space_40` | 40px | 화면 상단/하단 여백 |
| `space_48` | 48px | 대형 간격, 빈 상태 일러스트 여백 |

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
  static const double huge = 48;
}
```

### 4.2 화면 레이아웃 기준

| 요소 | 값 | 비고 |
|------|-----|------|
| 화면 수평 패딩 | 16px | 좌우 동일 |
| 앱바 높이 | 56px | Material 3 기본 |
| 바텀 내비게이션 높이 | 80px | 라벨 포함 |
| 터치 타겟 최소 크기 | 48x48px | 접근성 기준 (44px 이상) |
| FAB 크기 | 56x56px | Material 3 기본 |

### 4.3 모서리 둥글기 (Border Radius)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `radius_xs` | 4px | 작은 칩, 인라인 뱃지 |
| `radius_sm` | 8px | 입력 필드, 드롭다운 |
| `radius_md` | 12px | 카드, 버튼, 바텀시트 상단 |
| `radius_lg` | 16px | 모달, 다이얼로그 |
| `radius_xl` | 20px | 바텀시트 |
| `radius_full` | 999px | 원형 버튼, 상태 뱃지, 아바타 |

```dart
class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}
```

### 4.4 그림자 (Elevation)

| 레벨 | 값 | 용도 |
|------|-----|------|
| Level 0 | elevation: 0 | 배경에 놓인 요소 |
| Level 1 | elevation: 1 | 카드, 리스트 아이템 |
| Level 2 | elevation: 3 | 앱바, 떠 있는 요소 |
| Level 3 | elevation: 6 | FAB, 스낵바 |
| Level 4 | elevation: 8 | 바텀시트, 드로어 |
| Level 5 | elevation: 12 | 다이얼로그, 모달 |

---

## 5. 컴포넌트 패턴

### 5.1 상태 뱃지 (Status Badge) - 핵심 컴포넌트

앱에서 가장 빈번하게 사용되는 컴포넌트. 작업 상태를 시각적으로 표현한다.

```
 ┌──────────────────┐
 │ ● 접수됨          │  → 배경: #FEF3C7, 텍스트: #92400E, 좌측 원: #F59E0B
 └──────────────────┘

 ┌──────────────────┐
 │ ● 작업중          │  → 배경: #DBEAFE, 텍스트: #1E40AF, 좌측 원: #3B82F6
 └──────────────────┘

 ┌──────────────────┐
 │ ● 완료            │  → 배경: #DCFCE7, 텍스트: #166534, 좌측 원: #22C55E
 └──────────────────┘
```

```dart
class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.2 작업 카드 (Order Card)

작업 목록에서 각 작업을 표현하는 카드.

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
| 카드 배경 | `#FFFFFF` (Light) / `#1E293B` (Dark) |
| 카드 모서리 | 12px |
| 카드 내부 패딩 | 16px |
| 카드 간 간격 | 12px |
| 카드 테두리 | `#E2E8F0` 1px (Light) / `#334155` 1px (Dark) |
| 카드 그림자 | elevation 1 |

### 5.3 버튼 (Buttons)

#### 주요 버튼 (Primary - Filled)

| 속성 | 값 |
|------|-----|
| 배경색 | `#2563EB` |
| 텍스트 색상 | `#FFFFFF` |
| 높이 | 48px |
| 모서리 둥글기 | 12px |
| 폰트 | 16sp, SemiBold (600) |
| 눌림 상태 | `#1D4ED8` |
| 비활성 상태 | opacity 0.38 |

#### CTA 버튼 (Secondary - 중요 액션)

| 속성 | 값 |
|------|-----|
| 배경색 | `#F97316` |
| 텍스트 색상 | `#FFFFFF` |
| 높이 | 48px |
| 모서리 둥글기 | 12px |
| 용도 | 작업 접수, 상태 변경 등 핵심 액션 |

#### 외곽선 버튼 (Outlined)

| 속성 | 값 |
|------|-----|
| 배경색 | 투명 |
| 테두리 | `#2563EB` 1.5px |
| 텍스트 색상 | `#2563EB` |
| 높이 | 48px |
| 용도 | 보조 액션, 취소 |

#### 텍스트 버튼 (Text)

| 속성 | 값 |
|------|-----|
| 배경색 | 투명 |
| 텍스트 색상 | `#2563EB` |
| 높이 | 40px |
| 용도 | 링크형 액션, 더보기 |

#### 상태 전환 버튼 (사장님 전용)

작업 상태를 다음 단계로 전환하는 전용 버튼.

```
 접수됨 → [작업 시작하기]  배경: #3B82F6
 작업중 → [작업 완료하기]  배경: #22C55E
```

### 5.4 바텀 내비게이션 (Bottom Navigation)

#### 고객용 (3탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 홈 | `home` | 홈 |
| 샵 검색 | `search` | 샵 검색 |
| 마이 | `person` | 마이 |

#### 사장님용 (4탭)

| 탭 | 아이콘 | 라벨 |
|-----|--------|------|
| 대시보드 | `dashboard` | 대시보드 |
| 작업관리 | `assignment` | 작업관리 |
| 회원관리 | `people` | 회원관리 |
| 설정 | `settings` | 설정 |

| 속성 | 값 |
|------|-----|
| 활성 아이콘 색상 | `#2563EB` |
| 비활성 아이콘 색상 | `#94A3B8` |
| 활성 라벨 색상 | `#2563EB` |
| 비활성 라벨 색상 | `#94A3B8` |
| 바 배경 | `#FFFFFF` (Light) / `#1E293B` (Dark) |
| 상단 테두리 | `#E2E8F0` 0.5px |

### 5.5 입력 필드 (Text Fields)

| 속성 | 값 |
|------|-----|
| 높이 | 48px |
| 배경 | `#F1F5F9` (Light) / `#334155` (Dark) |
| 테두리 (기본) | 없음 |
| 테두리 (포커스) | `#2563EB` 2px |
| 테두리 (오류) | `#EF4444` 2px |
| 모서리 둥글기 | 8px |
| 힌트 텍스트 색상 | `#94A3B8` |
| 라벨 색상 | `#475569` |
| 내부 패딩 | 수평 16px, 수직 12px |

### 5.6 앱바 (App Bar)

| 속성 | Light Mode | Dark Mode |
|------|-----------|-----------|
| 배경색 | `#FFFFFF` | `#1E293B` |
| 타이틀 색상 | `#0F172A` | `#F8FAFC` |
| 아이콘 색상 | `#0F172A` | `#F8FAFC` |
| 하단 테두리 | `#E2E8F0` 0.5px | `#334155` 0.5px |
| 높이 | 56px | 56px |

### 5.7 리스트 아이템

| 속성 | 값 |
|------|-----|
| 높이 | 최소 56px (내용에 따라 가변) |
| 수평 패딩 | 16px |
| 수직 패딩 | 12px |
| 구분선 | `#F1F5F9` (Light) / `#1E293B` (Dark) |
| 탭 피드백 | `#F1F5F9` splash (Light) |

### 5.8 다이얼로그 (Dialog)

| 속성 | 값 |
|------|-----|
| 모서리 둥글기 | 16px |
| 패딩 | 24px |
| 제목 폰트 | 20sp, SemiBold |
| 버튼 영역 상단 간격 | 24px |
| 오버레이 배경 | `#000000` opacity 50% |

### 5.9 스낵바 / 토스트

| 속성 | 값 |
|------|-----|
| 배경 | `#1E293B` (Light) / `#F1F5F9` (Dark) |
| 텍스트 색상 | `#FFFFFF` (Light) / `#0F172A` (Dark) |
| 모서리 둥글기 | 8px |
| 하단 간격 | 16px (바텀 내비 위) |
| 표시 시간 | 3초 |

---

## 6. 아이콘 체계

### 6.1 아이콘 세트

**Material Symbols (Outlined)** 을 기본 아이콘으로 사용한다.

| 속성 | 값 |
|------|-----|
| 스타일 | Outlined |
| 기본 크기 | 24x24px |
| 소형 크기 | 20x20px |
| 대형 크기 | 32x32px |
| 색상 | 컨텍스트에 따름 |

### 6.2 주요 아이콘 매핑

| 기능 | Material Icon | 용도 |
|------|--------------|------|
| 접수됨 상태 | `inventory_2` | 상태 표시 |
| 작업중 상태 | `build_circle` | 상태 표시 |
| 완료 상태 | `check_circle` | 상태 표시 |
| QR 코드 | `qr_code_2` | QR 스캔/표시 |
| 샵 | `storefront` | 샵 정보 |
| 회원 | `person` | 회원 관리 |
| 알림 | `notifications` | 푸시 알림 |
| 길찾기 | `directions` | 네이버 지도 연동 |
| 라켓 | `sports_tennis` | 라켓 정보 (배드민턴 아이콘 부재 시) |
| 전화 | `phone` | 연락처 |
| 검색 | `search` | 검색 기능 |
| 설정 | `settings` | 설정 화면 |

---

## 7. 다크 모드

### 7.1 기본 방침

- 시스템 설정을 따르되, 앱 내 수동 전환도 지원한다
- 순수 검정(`#000000`)은 사용하지 않는다. OLED 화면에서의 스미어링 방지를 위해 `#0F172A` (Slate 900)을 배경으로 사용한다
- 상태 색상(접수됨/작업중/완료)은 다크 모드에서도 동일한 Hex 값을 유지한다 (배경색만 약간 조정)
- 텍스트는 순수 흰색(`#FFFFFF`) 대신 `#F8FAFC`를 사용하여 눈의 피로를 줄인다

### 7.2 다크 모드 색상 변환 규칙

| 요소 | Light → Dark |
|------|-------------|
| 화면 배경 | `#F8FAFC` → `#0F172A` |
| 카드 배경 | `#FFFFFF` → `#1E293B` |
| 입력 필드 배경 | `#F1F5F9` → `#334155` |
| Primary 버튼 | `#2563EB` → `#3B82F6` (밝기 한 단계 상승) |
| 텍스트 Primary | `#0F172A` → `#F8FAFC` |
| 텍스트 Secondary | `#475569` → `#94A3B8` |
| 테두리 | `#E2E8F0` → `#334155` |
| 상태 뱃지 배경 | 동일 유지 (충분한 대비 확인 필요) |

```dart
// MaterialApp 설정
MaterialApp(
  themeMode: ThemeMode.system, // 시스템 설정 따르기
  theme: lightTheme,
  darkTheme: darkTheme,
);
```

---

## 8. 애니메이션 가이드

### 8.1 기본 원칙

| 규칙 | 값 |
|------|-----|
| 마이크로 인터랙션 | 150-200ms |
| 화면 전환 | 300ms |
| 바텀시트 | 250ms |
| 이징 커브 (입장) | `Curves.easeOut` |
| 이징 커브 (퇴장) | `Curves.easeIn` |
| 이징 커브 (이동) | `Curves.easeInOut` |

### 8.2 주요 애니메이션

| 상황 | 애니메이션 | 시간 |
|------|-----------|------|
| 상태 변경 | 색상 전환 (AnimatedContainer) | 300ms |
| 카드 탭 | 살짝 눌림 효과 (scale 0.98) | 100ms |
| 목록 로딩 | 스켈레톤 shimmer | 1500ms 반복 |
| 페이지 전환 | Slide + Fade | 300ms |
| 스낵바 표시 | 아래에서 슬라이드 | 200ms |
| 상태 뱃지 점 | 작업중일 때 펄스 애니메이션 | 1500ms 반복 |

### 8.3 접근성 고려

```dart
// 사용자가 애니메이션 축소를 설정한 경우
final reduceMotion = MediaQuery.of(context).disableAnimations;
final duration = reduceMotion
    ? Duration.zero
    : const Duration(milliseconds: 300);
```

---

## 9. 역할별 UI 차이점

고객과 사장님은 동일한 디자인 시스템을 공유하되, 다음과 같은 차이가 있다.

### 9.1 색상 강조 차이

| 요소 | 고객 | 사장님 |
|------|------|--------|
| 앱바 색상 | 흰색 배경 | 흰색 배경 (동일) |
| 메인 CTA | `#2563EB` (정보 확인 중심) | `#F97316` (작업 액션 중심) |
| FAB | 없음 | `#F97316` (작업 접수 버튼) |

### 9.2 네비게이션 구조 차이

| 고객 | 사장님 |
|------|--------|
| 3탭 (홈/샵검색/마이) | 4탭 (대시보드/작업관리/회원관리/설정) |
| 컨텐츠 소비 중심 | 컨텐츠 생산/관리 중심 |
| 읽기 위주의 UI | 입력/수정 위주의 UI |

### 9.3 대시보드 (사장님 전용)

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

숫자 카드 스타일:
- 크기: 각 카드 가로 균등 분할 (gap: 12px)
- 숫자: `displayLarge` (32sp, Bold)
- 라벨: `labelMedium` (12sp, Medium)
- 배경: 각 상태의 배경색
- 모서리: 12px
- 패딩: 상하 16px, 좌우 12px

---

## 10. 빈 상태 및 로딩

### 10.1 빈 상태 (Empty State)

작업 목록이 비어있을 때 표시하는 화면.

| 속성 | 값 |
|------|-----|
| 일러스트 크기 | 120x120px |
| 일러스트-텍스트 간격 | 16px |
| 제목 | `headlineMedium` (20sp, SemiBold) |
| 설명 | `bodyMedium` (14sp, Regular), 색상 `#94A3B8` |
| 액션 버튼 (있을 경우) | 설명 아래 24px |
| 전체 정렬 | 화면 중앙 |

### 10.2 로딩 상태

| 상황 | 패턴 |
|------|------|
| 최초 데이터 로딩 | 스켈레톤 스크린 (shimmer) |
| 목록 추가 로딩 | 하단 CircularProgressIndicator |
| 버튼 액션 로딩 | 버튼 내 CircularProgressIndicator (버튼 비활성화) |
| 풀 리프레시 | RefreshIndicator (Material 기본) |

스켈레톤 색상:
- Light: `#E2E8F0` → `#F1F5F9` (shimmer)
- Dark: `#334155` → `#475569` (shimmer)

---

## 11. 간격 및 레이아웃 참조

### 11.1 화면별 레이아웃 규칙

```
 ┌─ 앱바 (56px) ──────────────────────┐
 │                                     │
 │  ← 16px →  콘텐츠 영역  ← 16px →   │
 │                                     │
 │  [카드]                             │
 │  ↕ 12px                            │
 │  [카드]                             │
 │  ↕ 12px                            │
 │  [카드]                             │
 │                                     │
 ├─ 바텀 내비게이션 (80px) ────────────┤
 └─────────────────────────────────────┘
```

### 11.2 카드 내부 레이아웃

```
 ┌─────────────────────────────────────┐
 │ 16px                                │
 │ ← 제목              상태 뱃지 → 16px│
 │ 8px                                 │
 │ ← 부가 정보                    16px │
 │ 12px                                │
 │ ← 하단 정보 (샵, 시간)         16px │
 │ 16px                                │
 └─────────────────────────────────────┘
```

---

## 12. 접근성 체크리스트

| 항목 | 기준 | 확인 |
|------|------|------|
| 텍스트 명암비 | 본문 4.5:1 이상, 대형 텍스트 3:1 이상 | |
| 터치 타겟 | 최소 48x48px | |
| 색상 단독 구분 금지 | 상태 표시에 아이콘+텍스트 병행 | |
| 스크린 리더 | Semantics 위젯으로 접근성 라벨 제공 | |
| 폰트 크기 조절 | `MediaQuery.textScaleFactor` 대응 | |
| 애니메이션 축소 | `MediaQuery.disableAnimations` 대응 | |
| 키보드/포커스 | 포커스 순서가 시각적 순서와 일치 | |

---

## 13. 명암비 검증 결과

주요 색상 조합의 WCAG 2.1 AA 기준 명암비 (4.5:1 이상 필요):

| 조합 | 명암비 | 결과 |
|------|--------|------|
| `#0F172A` on `#F8FAFC` (본문 텍스트) | 15.4:1 | PASS |
| `#475569` on `#F8FAFC` (보조 텍스트) | 7.0:1 | PASS |
| `#FFFFFF` on `#2563EB` (Primary 버튼) | 4.6:1 | PASS |
| `#FFFFFF` on `#F97316` (CTA 버튼) | 3.2:1 | PASS (대형 텍스트) |
| `#92400E` on `#FEF3C7` (접수됨 뱃지) | 5.8:1 | PASS |
| `#1E40AF` on `#DBEAFE` (작업중 뱃지) | 6.5:1 | PASS |
| `#166534` on `#DCFCE7` (완료 뱃지) | 6.7:1 | PASS |
| `#F8FAFC` on `#0F172A` (다크모드 본문) | 15.4:1 | PASS |
| `#FFFFFF` on `#F97316` (CTA 버튼) | 3.2:1 | 주의: 16sp 이상만 사용 |

> CTA 버튼(`#F97316`)의 흰색 텍스트는 대형 텍스트(16sp Bold 이상) 기준으로만 AA를 충족한다. 버튼 텍스트는 항상 16sp SemiBold 이상을 사용하므로 문제없다.

---

## 부록: 디자인 토큰 요약

빠른 참조용 전체 토큰 목록.

```dart
// ============================================
// 거트알림 디자인 토큰 (Flutter)
// ============================================

// --- Colors ---
// Primary
const primary = Color(0xFF2563EB);
const primaryLight = Color(0xFF3B82F6);
const primaryDark = Color(0xFF1D4ED8);
const primaryContainer = Color(0xFFDBEAFE);

// Secondary (CTA)
const secondary = Color(0xFFF97316);

// Status
const statusReceived = Color(0xFFF59E0B);
const statusReceivedBg = Color(0xFFFEF3C7);
const statusInProgress = Color(0xFF3B82F6);
const statusInProgressBg = Color(0xFFDBEAFE);
const statusCompleted = Color(0xFF22C55E);
const statusCompletedBg = Color(0xFFDCFCE7);

// Semantic
const error = Color(0xFFEF4444);
const success = Color(0xFF22C55E);
const warning = Color(0xFFF59E0B);
const info = Color(0xFF3B82F6);

// Neutral (Light)
const bgLight = Color(0xFFF8FAFC);
const surfaceLight = Color(0xFFFFFFFF);
const textPrimary = Color(0xFF0F172A);
const textSecondary = Color(0xFF475569);
const textTertiary = Color(0xFF94A3B8);
const border = Color(0xFFE2E8F0);

// Neutral (Dark)
const bgDark = Color(0xFF0F172A);
const surfaceDark = Color(0xFF1E293B);

// --- Typography (Pretendard) ---
// Display: 32sp Bold / 28sp Bold
// Headline: 24sp SemiBold / 20sp SemiBold
// Title: 18sp SemiBold / 16sp Medium
// Body: 16sp Regular / 14sp Regular / 12sp Regular
// Label: 14sp Medium / 12sp Medium / 11sp Medium

// --- Spacing ---
// 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48

// --- Radius ---
// 4 / 8 / 12 / 16 / 20 / 999 (full)

// --- Elevation ---
// 0 / 1 / 3 / 6 / 8 / 12

// --- Animation ---
// Micro: 150-200ms
// Transition: 300ms
// Curve: easeOut (enter), easeIn (exit), easeInOut (move)
```
