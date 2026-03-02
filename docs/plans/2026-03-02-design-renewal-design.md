# 디자인 리뉴얼 설계

> 작성일: 2026-03-02
> 유형: Change Request (전체 디자인 톤 변경)

## 배경

현재 디자인이 기능 위주로 딱딱하고 투박한 느낌이다.
친근하고 부드러운 무드로 전환하여 사용자 경험을 개선한다.

## 변경 방향

- **무드**: Soft, Friendly, Rounded (당근마켓/토스/배민 참고)
- **접근법**: 폰트 + 색상 + 모서리/그림자 일괄 교체 (레이아웃 유지)

## 1. 색상 팔레트

| 변수 | 변경 전 | 변경 후 | 설명 |
|------|---------|---------|------|
| `--primary` | `#16A34A` | `#22C55E` | 밝고 상쾌한 그린 |
| `--primary-light` | `#22C55E` | `#86EFAC` | 민트 파스텔 |
| `--primary-dark` | `#15803D` | `#16A34A` | 기존 primary → dark |
| `--primary-container` | `#DCFCE7` | `#F0FDF4` | 크림 그린 |
| `--secondary` | `#F97316` | `#FB923C` | 따뜻한 코랄 |
| `--secondary-light` | `#FB923C` | `#FDBA74` | 부드러운 피치 |
| `--background` | `#F8FAFC` | `#FAFDF7` | 그린 틴트 배경 |
| `--surface-variant` | `#F1F5F9` | `#F0FDF4` | 그린 틴트 variant |
| `--text-primary` | `#0F172A` | `#1E293B` | 약간 부드러운 다크 |

유지: `--surface` (#FFFFFF), `--border` (#E2E8F0), `--error` (#EF4444)

## 2. 폰트

| 항목 | 변경 전 | 변경 후 |
|------|---------|---------|
| Pencil | Gmarket Sans | SUIT |
| Flutter (theme.dart) | Pretendard | SUIT |

타이포그래피 스케일은 유지한다 (32/24/20/18/16/14/12sp).

## 3. 모서리 + 그림자

| 항목 | 변경 전 | 변경 후 |
|------|---------|---------|
| 카드 모서리 | 12~16px 혼합 | 20px 통일 |
| 입력 필드 | 8~12px | 14px 통일 |
| 버튼 | 12px | 14px |
| 뱃지 (pill) | 999px | 유지 |
| 카드 스타일 | 테두리 #E2E8F0 1px | 그림자 `0 2px 8px rgba(0,0,0,0.06)`, 테두리 제거 |

## 4. 영향 범위

### Pencil (.pen)
- 변수: 색상 변수 일괄 업데이트 (`set_variables`)
- 속성: fontFamily 일괄 교체 (`replace_all_matching_properties`)
- 속성: cornerRadius 일괄 교체
- 속성: fillColor 변경된 색상 교체

### 코드
- `lib/app/theme.dart`: 색상 값, fontFamily, 모서리, 그림자 변경

### 문서
- `docs/design-system.md`: 색상/폰트/모서리 스펙 갱신 (있는 경우)
