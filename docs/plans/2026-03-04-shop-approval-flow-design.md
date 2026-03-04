# 샵 등록 승인 플로우 설계

> **날짜**: 2026-03-04
> **상태**: 확정

**목표**: 샵 등록을 즉시 승인이 아닌, 관리자 승인 기반으로 변경한다. 사업자등록증 번호를 제출하고 관리자가 승인/거절한다.

**핵심 원칙**: 샵 등록은 누구나 하는 게 아니라, 요청 후 관리자가 승인해야 한다.

---

## 1. 역할 구분

| 역할 | 설명 |
|------|------|
| `customer` | 일반 회원. 기본 역할 |
| `shop_owner` | 승인된 샵을 보유한 사장님. 고객 기능도 사용 가능 |
| `admin` | 앱 운영자. 샵 승인/거절 등 관리 업무. DB에서 직접 role 부여 |

---

## 2. DB 스키마 변경

### shops 테이블 컬럼 추가

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `status` | `TEXT NOT NULL DEFAULT 'pending'` | `pending` / `approved` / `rejected` |
| `business_number` | `TEXT NOT NULL` | 사업자등록증 번호 (10자리) |
| `reject_reason` | `TEXT` | 거절 사유 (거절 시에만 값 존재) |
| `reviewed_at` | `TIMESTAMPTZ` | 심사 완료 시각 |

```sql
ALTER TABLE shops ADD COLUMN status TEXT NOT NULL DEFAULT 'pending';
ALTER TABLE shops ADD COLUMN business_number TEXT NOT NULL;
ALTER TABLE shops ADD COLUMN reject_reason TEXT;
ALTER TABLE shops ADD COLUMN reviewed_at TIMESTAMPTZ;
ALTER TABLE shops ADD CONSTRAINT shops_status_check
  CHECK (status IN ('pending', 'approved', 'rejected'));
```

### users 테이블 role CHECK 변경

```sql
-- 기존: CHECK (role IN ('customer', 'shop_owner'))
-- 변경: CHECK (role IN ('customer', 'shop_owner', 'admin'))
```

### RLS 정책

- 관리자만 `status`, `reject_reason`, `reviewed_at` 업데이트 가능
- 일반 사용자(고객/사장님)는 `status = 'approved'`인 샵만 검색/조회 가능
- 본인 샵은 status 무관하게 조회 가능

---

## 3. 앱 플로우

### 변경 전
```
회원가입 → 역할 선택 → (사장님) 프로필 설정 → 샵 등록 → 즉시 사장님 대시보드
```

### 변경 후
```
일반 회원가입 → 고객으로 앱 사용
                  ↓ (마이페이지 "샵 등록 신청")
           샵 정보 + 사업자번호 입력 → status=pending INSERT
                  ↓
           고객 모드로 계속 사용 (마이페이지에 "승인 대기 중" 표시)
                  ↓
           관리자 승인 → FCM 푸시 → 사장님 모드 전환 가능
           관리자 거절 → FCM 푸시 → 거절 사유 확인 + 재신청
```

---

## 4. 화면 변경

### 수정 대상

#### 마이페이지 (mypage)
- "샵 등록 신청" 메뉴 추가
- 상태별 표시:
  - **미신청**: "샵 등록 신청" (탭 → 샵 등록 화면)
  - **pending**: "승인 대기 중" (비활성, 대기 아이콘)
  - **approved**: "사장님 모드 전환" (탭 → owner 모드 전환)
  - **rejected**: "거절됨 — 재신청" (탭 → 샵 등록 화면, 기존 정보 채움)

#### 샵 등록 화면 (shop-signup)
- 사업자등록증 번호 필드 추가 (10자리 숫자)
- submit 후 사장님 대시보드가 아닌 **마이페이지로 복귀** + "샵 등록 신청이 완료되었습니다" 토스트
- 재신청 시: 기존 정보를 불러와서 수정 가능

### 신규 화면

#### 관리자 - 승인 요청 목록 (admin-shop-requests)
- `status = 'pending'`인 샵 목록 표시
- 각 카드: 샵 이름, 사장님 이름, 사업자번호, 신청일
- 탭 → 상세 화면 이동

#### 관리자 - 승인 요청 상세 (admin-shop-request-detail)
- 샵 정보 전체: 이름, 주소, 연락처, 소개글, 사업자번호
- 사장님 정보: 이름, 연락처
- 하단 버튼: **승인** / **거절**
- 거절 시: 사유 입력 다이얼로그 (필수 입력)
- 처리 후: FCM 푸시 전송 + 목록 복귀

---

## 5. 모델/코드 변경

### 모델

| 변경 | 내용 |
|------|------|
| `UserRole` enum | `admin` 값 추가 |
| `ShopStatus` enum (신규) | `pending`, `approved`, `rejected` |
| `Shop` 모델 | `status`, `businessNumber`, `rejectReason`, `reviewedAt` 필드 추가 |

### Repository

| 변경 | 내용 |
|------|------|
| `ShopRepository.getPendingShops()` | pending 상태 샵 목록 조회 (관리자용) |
| `ShopRepository.approve(id)` | status → approved, reviewed_at 설정 |
| `ShopRepository.reject(id, reason)` | status → rejected, reject_reason, reviewed_at 설정 |

### Provider

| 변경 | 내용 |
|------|------|
| `hasShopProvider` | approved 상태인 샵이 있을 때만 true |
| `shopStatusProvider` (신규) | 현재 사용자의 샵 승인 상태 반환 (null/pending/approved/rejected) |

### 라우터
- admin role → 관리자 전용 라우트 접근 가능
- owner 모드 → approved 샵이 있을 때만 전환 가능

---

## 6. FCM 푸시 알림

| 이벤트 | 메시지 |
|--------|--------|
| 승인 | "샵 등록이 승인되었습니다! 사장님 모드로 전환할 수 있습니다." |
| 거절 | "샵 등록이 거절되었습니다. 사유: {reject_reason}" |

- Edge Function에서 shops status 업데이트 + FCM 전송을 처리
- 또는 관리자 앱에서 직접 FCM 전송 (Repository 레벨)

---

## 7. 영향 범위

| 영역 | 파일/대상 |
|------|----------|
| DB | shops 테이블, users role CHECK, RLS 정책 |
| 모델 | `enums.dart`, `shop.dart`, `shop.freezed.dart`, `shop.g.dart` |
| Repository | `shop_repository.dart` |
| Provider | `app_mode_provider.dart`, 신규 provider |
| 라우터 | `router.dart` |
| 화면 (수정) | `mypage`, `shop_signup` |
| 화면 (신규) | `admin-shop-requests`, `admin-shop-request-detail` |
| Edge Function | 승인/거절 FCM 알림 |
| Pencil 디자인 | 관리자 화면 2개 신규, 마이페이지/샵등록 수정 |
| UI 스펙 | 관리자 화면 2개 신규, mypage/shop-signup 수정 |
| 상태 설계 | 관리자 화면, mypage, shop-signup 상태 수정 |
