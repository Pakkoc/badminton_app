# 거트알림 - 배드민턴 거트 예약 및 진행 현황 앱 설계

## 1. 기획 의도

### 문제 인식
배드민턴 거트(스트링) 교체는 전문 샵에 직접 라켓을 맡기고, 작업 완료 후 다시 방문하여 수령하는 과정으로 이루어진다. 그러나 현재 대부분의 샵에서는 "언제까지 해드릴게요"라는 구두 약속만 이루어지며, 실제 완료 시점을 정확히 알 수 있는 방법이 없다. 이로 인해 다음과 같은 문제가 반복적으로 발생한다.

- 약속 시간에 맞춰 갔지만 작업이 아직 완료되지 않아 **헛걸음하는 사례가 빈번**
- 고객 입장에서 작업 진행 상황을 알 수 없어 **불안감과 불편함** 발생
- 샵 입장에서 고객 문의 전화를 반복적으로 받는 **운영 비효율** 발생

### 기획 목적
이러한 문제를 해결하기 위해, 거트 작업의 접수부터 완료까지 **실시간 진행 현황을 고객에게 알려주는 모바일 앱**을 개발하고자 한다.

### 기대 효과
- **고객:** 작업 완료 시 즉시 푸시 알림을 받아 헛걸음 방지. 샵 위치 길찾기로 편리한 수령
- **샵:** 작업 상태를 앱으로 관리하여 문의 전화 감소. 회원 관리를 통한 단골 고객 확보 및 재방문 유도
- **시장 확장:** 주변 샵 검색 기능을 통해 신규 고객 유입 채널 확보. 샵 홍보 효과

## 2. 앱 개요

### 핵심 가치
거트 작업 완료를 실시간으로 알려주어 고객의 헛걸음을 방지하고, 샵의 고객 관리를 돕는다.

### 사용자 역할
- **고객** — 가입 시 "고객" 선택. 주변 샵 검색, 작업 진행 현황 확인, 완료 푸시 알림 수신
- **샵 사장님** — 가입 시 "샵 사장님" 선택. 샵 등록, 작업 접수/상태 관리, 회원 관리

### 핵심 흐름
```
[오프라인] 고객이 라켓을 샵에 맡김
    ↓
[샵 앱] 사장님이 작업 접수 (고객 QR 스캔 or 수동 등록)
    ↓
[샵 앱] 상태 변경: 접수됨 → 작업중 → 완료
    ↓
[고객 앱] 각 상태 변경 시 푸시 알림 수신
    ↓
[고객 앱] 샵 위치 확인 + 네이버 지도 길찾기
    ↓
[오프라인] 고객이 라켓 수령
```

### 기술 스택
- **프론트엔드:** Flutter (iOS/Android)
- **DB/인증:** Supabase (PostgreSQL + Auth)
- **푸시 알림:** Firebase Cloud Messaging (FCM)
- **지도:** Naver Map API + 네이버 지도 앱 길찾기 연동

---

## 2. 데이터베이스 설계 (Supabase / PostgreSQL)

### users — 공통 사용자
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | Supabase Auth UID |
| role | ENUM | `customer`, `shop_owner` |
| name | TEXT | 이름 |
| phone | TEXT | 연락처 |
| fcm_token | TEXT | 푸시 알림용 토큰 |
| created_at | TIMESTAMP | 가입일 |

### shops — 샵 정보
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | |
| owner_id | UUID (FK→users) | 사장님 |
| name | TEXT | 샵 이름 |
| address | TEXT | 주소 |
| latitude | DOUBLE | 위도 |
| longitude | DOUBLE | 경도 |
| phone | TEXT | 샵 연락처 |
| description | TEXT | 소개글 |
| created_at | TIMESTAMP | 등록일 |

### members — 샵별 회원 관리
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | |
| shop_id | UUID (FK→shops) | 소속 샵 |
| user_id | UUID (FK→users, nullable) | 앱 사용자 연결 (미가입이면 null) |
| name | TEXT | 이름 |
| phone | TEXT | 연락처 |
| preferred_gut | TEXT | 선호 거트 |
| preferred_tension | TEXT | 선호 텐션 |
| racket_info | JSONB | 라켓 정보 (모델명, 수량 등) |
| memo | TEXT | 메모 |
| visit_count | INT | 방문 횟수 |
| created_at | TIMESTAMP | 등록일 |

### orders — 거트 작업 건
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID (PK) | |
| shop_id | UUID (FK→shops) | 샵 |
| member_id | UUID (FK→members) | 회원 |
| gut_name | TEXT | 사용 거트 |
| tension | TEXT | 텐션 |
| racket_model | TEXT | 라켓 모델명 |
| status | ENUM | `received`, `in_progress`, `completed` |
| memo | TEXT | 작업 메모 |
| created_at | TIMESTAMP | 접수일 |
| updated_at | TIMESTAMP | 상태 변경일 |

### 설계 포인트
- **members.user_id가 nullable** — 고객이 앱 미가입이어도 사장님이 회원 등록 가능. 나중에 고객이 앱 가입하면 phone 번호로 매칭하여 연결
- **racket_info는 JSONB** — 라켓 여러 개를 유연하게 저장 (`[{model: "YONEX AX99", count: 2}, ...]`)
- **orders에 gut/tension/racket 별도 저장** — 매번 다를 수 있으므로 member의 선호값과 독립적으로 기록

---

## 3. 화면 구성

### 공통 화면
- **스플래시** → **로그인/회원가입** (역할 선택: 고객 / 샵 사장님)

### 고객 화면
| 화면 | 설명 |
|------|------|
| **홈** | 현재 진행 중인 내 작업 목록 (상태 표시: 접수됨/작업중/완료) |
| **작업 상세** | 거트, 텐션, 라켓, 샵 정보, 상태 타임라인 |
| **주변 샵 검색** | 네이버 지도에 주변 샵 마커 표시, 리스트 뷰 전환 가능 |
| **샵 상세** | 샵 소개, 위치, 연락처, 길찾기 버튼, 현재 작업 현황 (접수 N건 / 작업중 N건) |
| **내 QR코드** | 사장님에게 보여줄 QR코드 화면 |
| **작업 이력** | 과거 완료된 작업 목록 |
| **마이페이지** | 프로필 수정, 알림 설정 |

### 샵 사장님 화면
| 화면 | 설명 |
|------|------|
| **대시보드** | 오늘의 작업 현황 (접수/진행/완료 건수), 최근 작업 목록 |
| **작업 접수** | QR 스캔 or 회원 검색 → 거트/텐션/라켓 입력 → 접수 |
| **작업 관리** | 전체 작업 목록, 상태 변경 버튼 (한 탭으로 상태 전환) |
| **회원 관리** | 회원 목록, 검색, 회원 상세 (선호 거트, 라켓 정보, 방문 이력) |
| **회원 등록** | 수동 등록 폼 (이름, 연락처, 선호 거트, 라켓 정보, 메모) |
| **샵 설정** | 샵 정보 수정 (이름, 주소, 소개글) |

---

## 4. 푸시 알림

### 알림 흐름
```
사장님이 작업 상태 변경
    ↓
Supabase DB의 orders 테이블 UPDATE 트리거 발동
    ↓
Supabase Edge Function 호출
    ↓
members → user_id → users.fcm_token 조회
    ↓
FCM으로 푸시 알림 전송
```

### 알림 메시지
| 상태 변경 | 알림 내용 |
|-----------|-----------|
| 접수됨 | "[샵이름] 거트 작업이 접수되었습니다" |
| 작업중 | "[샵이름] 거트 작업이 시작되었습니다" |
| 완료 | "[샵이름] 거트 작업이 완료되었습니다! 수령하러 오세요" |

- user_id가 null(앱 미가입)이면 알림을 보내지 않음
- 완료 알림에는 샵 위치 바로가기를 포함하여 탭 시 길찾기 화면으로 이동

---

## 5. QR코드 회원 등록

### 고객이 앱을 사용 중인 경우
```
고객이 라켓을 맡기면서 본인 폰으로 앱의 "내 QR코드" 화면을 보여줌
    ↓
사장님이 QR코드를 스캔 → 자동으로 회원 등록 (이름, 연락처 자동 입력)
    ↓
사장님이 선호 거트/텐션, 라켓 정보, 메모만 추가 입력
    ↓
바로 작업 접수 가능
```

### 고객이 앱 미가입인 경우
```
고객이 라켓을 맡김
    ↓
사장님이 수동으로 회원 등록 (이름, 연락처 직접 입력)
    ↓
members.user_id = null 상태로 저장
    ↓
나중에 고객이 앱을 설치하고 가입하면
    ↓
phone 번호 기준으로 기존 member 레코드와 자동 매칭
    ↓
이전 작업 이력까지 바로 확인 가능
```

### QR 설계 포인트
- 고객 QR에는 `user_id`만 인코딩 (개인정보 최소화)
- 사장님이 스캔 → user_id로 Supabase에서 이름/연락처 조회 → 회원 자동 생성
- 이미 해당 샵에 등록된 회원이면 "기존 회원입니다" 안내 후 바로 작업 접수로 이동

---

## 6. 네이버 지도 연동

- **주변 샵 검색**: 고객 현재 위치 기준 반경 탐색, 네이버 지도 SDK로 마커 표시
- **길찾기**: 네이버 지도 앱 URL Scheme 호출 (`nmap://route/...`), 미설치 시 웹 지도로 폴백

---

## 7. 프로젝트 구조

```
lib/
├── main.dart
├── app/
│   ├── routes.dart            # 라우팅 정의
│   └── theme.dart             # 앱 테마
├── models/                    # 데이터 모델
│   ├── user.dart
│   ├── shop.dart
│   ├── member.dart
│   └── order.dart
├── services/                  # 외부 연동
│   ├── supabase_service.dart
│   ├── fcm_service.dart
│   └── naver_map_service.dart
├── screens/
│   ├── auth/                  # 로그인, 회원가입
│   ├── customer/              # 고객 화면들
│   │   ├── home_screen.dart
│   │   ├── order_detail_screen.dart
│   │   ├── shop_search_screen.dart
│   │   ├── shop_detail_screen.dart
│   │   ├── my_qr_screen.dart
│   │   └── history_screen.dart
│   └── shop_owner/            # 사장님 화면들
│       ├── dashboard_screen.dart
│       ├── order_create_screen.dart
│       ├── order_manage_screen.dart
│       ├── member_list_screen.dart
│       ├── member_detail_screen.dart
│       └── shop_settings_screen.dart
└── widgets/                   # 공통 위젯
    ├── status_badge.dart
    └── order_card.dart
```

---

## 8. 구현 우선순위

| 순서 | 기능 | 이유 |
|------|------|------|
| **1단계** | 인증 + 샵 등록 + 회원 수동 등록 | 핵심 인프라, 이게 없으면 아무것도 안 됨 |
| **2단계** | 작업 접수 + 상태 관리 | 앱의 핵심 가치 |
| **3단계** | FCM 푸시 알림 | 고객이 앱을 쓸 이유 |
| **4단계** | QR코드 회원 등록 | 편의 기능, 수동 등록이 이미 동작하므로 후순위 |
| **5단계** | 네이버 지도 + 길찾기 | 부가 기능, 핵심 흐름과 독립적 |
| **6단계** | 작업 이력 + 통계 | 데이터가 쌓인 후에 의미 있음 |
