---
name: ui-screen-spec
description: 앱 요구사항 문서를 기반으로 화면별 UI 스펙 문서를 생성한다
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
---

# UI 화면 스펙 생성

## 개요

거트알림 배드민턴 앱의 요구사항 문서를 읽고, 화면별 구조화된 UI 스펙 문서를 생성한다.

**시작 시 안내:** "ui-screen-spec 스킬을 사용하여 UI 화면 스펙을 생성합니다."

## 사용법

```
/ui-screen-spec [screen-name]    # 특정 화면 스펙 생성
/ui-screen-spec all              # 전체 화면 스펙 일괄 생성
```

### 스펙 수정 모드

기존 스펙을 수정하는 경우:

```
/ui-screen-spec update [screen-name]   # 특정 화면 스펙 수정
```

**수정 절차:**
1. 기존 스펙 파일을 읽는다 (`docs/ui-specs/{screen-name}.md`)
2. 변경 사유와 범위를 파악한다
3. 변경된 내용을 반영하여 스펙을 업데이트한다
4. **Cross-reference 확인**: 다른 스펙에서 이 화면을 참조하는 부분도 업데이트한다
   - 네비게이션 섹션에서 이 화면으로 이동하는 경로
   - 화면 ID나 화면명이 변경된 경우 모든 참조 문서를 검색하여 수정
5. 커밋한다

**Cross-reference 검색 방법:**
- 변경된 화면 ID로 `docs/ui-specs/*.md` 전체를 Grep 검색한다
- 예: `signup` → `profile-setup`으로 변경 시, 모든 스펙에서 `signup`을 검색하여 참조를 업데이트

### 화면 이름 목록

공통 화면:
- `splash` — 스플래시
- `login` — 로그인 (소셜 로그인: 카카오/네이버/Gmail)
- `profile-setup` — 프로필 설정 (소셜 로그인 후 신규 사용자 역할/이름/연락처 입력)

고객 화면 (바텀 탭: 홈 / 샵검색 / 이력 / MY):
- `customer-home` — 고객 홈 (진행 중 작업 목록)
- `order-detail` — 작업 상세
- `order-history` — 작업 이력
- `shop-search` — 주변 샵 검색 (네이버 지도)
- `shop-detail` — 샵 상세 (공지/이벤트/재고 탭)
- `mypage` — 마이페이지

샵 사장님 화면 (바텀 탭: 대시보드 / 작업관리 / 회원관리 / 설정):
- `shop-signup` — 사장님 가입 2단계 (샵 등록)
- `owner-dashboard` — 대시보드
- `order-create` — 작업 접수
- `order-manage` — 작업 관리
- `member-list` — 회원 관리 (목록/검색)
- `member-register` — 회원 등록
- `shop-qr` — 샵 QR코드 관리
- `post-create` — 게시글 작성 (공지/이벤트)
- `inventory-manage` — 재고 관리
- `shop-settings` — 샵 설정

## 실행 절차

1. **요구사항 문서 읽기**: `docs/plans/2026-02-08-gut-app-design.md`를 읽어 전체 맥락을 파악한다.
2. **디자인 시스템 확인**: `docs/design-system.md`를 읽어 컬러, 타이포그래피, 간격, 컴포넌트 패턴을 확인한다.
3. **UX 가이드라인 참조** (ui-ux-pro-max 연동): 아래 UX 체크리스트를 스펙에 반영한다.
4. **기존 스펙 확인**: `docs/ui-specs/` 디렉토리에 이미 작성된 스펙이 있는지 확인한다.
5. **템플릿 참조**: `.claude/skills/ui-screen-spec/templates/screen-spec-template.md`의 구조를 따른다.
6. **예제 참조**: `.claude/skills/ui-screen-spec/examples/customer-home.md`를 참고하여 상세도와 형식을 맞춘다.
7. **스펙 생성**: 화면별로 `docs/ui-specs/{screen-name}.md` 파일을 생성한다.
8. **커밋**: 생성된 파일을 커밋한다.

## UX 가이드라인 체크리스트 (ui-ux-pro-max 기반)

스펙 작성 시 아래 항목을 반드시 확인하고 반영한다.

### 접근성 (CRITICAL)
- [ ] 텍스트 명암비 4.5:1 이상 — 디자인 시스템의 색상 조합이 충족하는지 확인
- [ ] 아이콘 전용 버튼에 접근성 라벨 명시 (aria-label / Semantics)
- [ ] 색상만으로 정보 구분하지 않음 — 상태에 아이콘+텍스트 병행

### 터치 & 인터랙션 (CRITICAL)
- [ ] 터치 타겟 최소 44x44px 이상 명시
- [ ] 인접 터치 타겟 간 최소 8px 간격
- [ ] 버튼 비동기 동작 시 로딩 상태 + 중복 클릭 방지
- [ ] 에러 발생 시 해당 필드 근처에 에러 메시지 표시
- [ ] 삭제 등 파괴적 액션은 확인 대화상자 필수

### 레이아웃 (HIGH)
- [ ] 모바일 본문 폰트 최소 16px
- [ ] 가로 스크롤 없음 — 콘텐츠가 화면 너비에 맞음
- [ ] 고정 요소(앱바, 바텀탭) 아래 콘텐츠가 가려지지 않도록 패딩 확보

### 피드백 (HIGH)
- [ ] 비동기 데이터 로딩 시 스켈레톤/로딩 상태 정의
- [ ] 빈 상태(Empty State) UI 정의 — 안내 메시지 + 액션 버튼
- [ ] 성공/실패 피드백 정의 (토스트 알림 등)
- [ ] 다단계 프로세스는 진행 표시기(Step indicator) 포함

### 폼 (MEDIUM)
- [ ] 모든 입력 필드에 라벨 명시 (placeholder만 사용 금지)
- [ ] 필수 필드 표시 (* 또는 (필수))
- [ ] 입력 타입별 적절한 키보드 (이메일, 전화번호, 숫자 등)
- [ ] 비밀번호 표시/숨기기 토글

### 모바일 특화 (MEDIUM)
- [ ] Pull-to-refresh 지원 여부 명시
- [ ] 긴 콘텐츠 잘림 처리 (ellipsis + 더보기)
- [ ] 날짜/숫자 포맷 로케일 고려

### Flutter 구현 가이드 (ui-ux-pro-max flutter stack)
- [ ] StatelessWidget vs StatefulWidget 구분 명시
- [ ] ListView.builder 사용 (긴 목록)
- [ ] Form + GlobalKey 유효성 검증
- [ ] TextEditingController dispose 필수
- [ ] Hero 위젯 (화면 전환 애니메이션) 활용 가능 여부

## 작성 원칙

- **모든 내용은 한국어**로 작성한다.
- 요구사항 문서에 명시된 DB 테이블 구조를 기반으로 **데이터 바인딩과 API 연동**을 구체적으로 기술한다.
- 각 컴포넌트의 **상태(활성/비활성/로딩/에러)**를 빠짐없이 정의한다.
- **사용자 인터랙션**은 이벤트와 결과 액션을 쌍으로 기술한다.
- 네비게이션은 **진입 경로와 이동 가능 화면**을 명확히 한다.
- 필드 검증 규칙은 **구체적인 조건**을 명시한다 (예: "2~20자", "010-XXXX-XXXX 형식").
- 화면 상태(로딩/빈 상태/에러/정상)별 **UI 분기**를 정의한다.
- **UX 가이드라인 체크리스트**를 각 스펙 문서 하단에 포함하여 충족 여부를 표시한다.
- **스펙 수정 시** 화면 ID/이름이 변경되면 다른 스펙의 네비게이션 섹션에서 해당 화면을 참조하는 부분도 함께 수정한다.
- **스펙 수정 시** 변경 이력을 최종 수정일에 반영한다.

## 출력 위치

모든 스펙 파일은 `docs/ui-specs/` 디렉토리에 저장한다.

```
docs/ui-specs/
├── splash.md
├── login.md
├── profile-setup.md
├── shop-signup.md
├── customer-home.md
├── order-detail.md
├── order-history.md
├── shop-search.md
├── shop-detail.md
├── mypage.md
├── owner-dashboard.md
├── order-create.md
├── order-manage.md
├── member-list.md
├── member-register.md
├── shop-qr.md
├── post-create.md
├── inventory-manage.md
└── shop-settings.md
```

## 참고 파일

- 템플릿: `.claude/skills/ui-screen-spec/templates/screen-spec-template.md`
- 예제: `.claude/skills/ui-screen-spec/examples/customer-home.md`
- 요구사항: `docs/plans/2026-02-08-gut-app-design.md`
- 디자인 시스템: `docs/design-system.md`
- UX 가이드라인 데이터: `.claude/skills/ui-ux-pro-max/data/ux-guidelines.csv`
- Flutter 가이드라인: `.claude/skills/ui-ux-pro-max/data/stacks/flutter.csv`
- 제품 타입 참고: `.claude/skills/ui-ux-pro-max/data/products.csv`
