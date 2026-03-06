---
name: app-design-workflow
description: "앱 기획부터 디자인, 구현까지의 전체 워크플로우를 안내한다. 새 프로젝트 시작 시 또는 기존 프로젝트에서 다음 단계를 확인할 때 사용한다."
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task
---

# 앱 디자인 워크플로우

앱 기획부터 디자인, 구현까지의 전체 과정을 단계별로 안내하는 워크플로우이다.

## 실행 방법

사용자가 이 스킬을 호출하면 다음을 수행한다:

1. **현재 프로젝트 상태 파악** — 아래 진단 절차에 따라 어느 Phase에 있는지 판단
2. **다음 단계 안내** — 해당 Phase에서 해야 할 구체적 작업을 안내
3. **인자에 따른 동작 분기**:
   - 인자 없음 또는 `status`: 현재 상태 진단 및 다음 단계 안내
   - `next`: 바로 다음 해야 할 작업을 구체적으로 안내
   - `phase N`: 특정 Phase로 이동하여 해당 작업 안내

## 프로젝트 상태 진단 절차

다음 파일/디렉토리 존재 여부를 확인하여 현재 Phase를 판단한다:

```
0. 브레인스토밍: docs/service-overview* 존재? → 없으면 Phase 0
1. 기획: docs/requirements* 존재? → 없으면 Phase 1
2. 기술 설계: docs/techstack*, docs/database* 존재? → 없으면 Phase 2
3. 디자인 시스템: docs/design-system* 존재? → 없으면 Phase 3
4. Pencil 디자인 + UI 스펙: *.pen, docs/ui-specs/*.md 존재? → 없으면 Phase 4
5. 공통 모듈: docs/common-modules* 존재? → 없으면 Phase 5 (동기화 장벽)
6. 상태 설계: docs/pages/*/state.md 존재? → 없으면 Phase 6
7. 코드 구현: lib/screens/ 존재? → 없으면 Phase 7
8. 검증: 테스트 통과 여부 → 미완료 Phase 8
```

**정석 순서**: 기획 → 기술설계 → 디자인시스템 → Pencil 디자인(+UI 스펙 자동) → 공통 모듈 → 상태 설계 → 구현 → 검증

**기능 추가 시**: brainstorming → Pencil 디자인 → state.md → 구현 → 검증 (Hook이 동기화 자동 처리)

## 전체 워크플로우

> **SOT 자동 동기화**: PostToolUse Hook이 파일 수정을 감지하여 자동으로 동기화 지시를 inject합니다.
> 수동으로 `/design-sync`, `/doc-sync`를 호출할 필요가 없습니다 — Hook이 알아서 알려줍니다.

### Phase 0: 브레인스토밍 (Brainstorming)

**목표**: 프로젝트 아이디어를 발산하고 핵심 방향을 잡는다.

**수행 작업**:
- brainstorming 스킬을 사용하여 아이디어 발산 및 구체화
- 핵심 기능과 차별점 도출, 사용자 페르소나 정의

**산출물**: docs/service-overview.md

---

### Phase 1: 기획 (Planning)

**목표**: 프로젝트의 방향과 범위를 정한다.

**수행 작업**:
- 기존 기획 문서 확인, 부족한 부분을 사용자에게 질문
- 구현 우선순위 확정

**산출물**: docs/requirements.md

---

### Phase 2: 기술 설계 (Technical Design)

**목표**: 기술 스택과 데이터베이스를 설계한다.

**수행 작업**:
- `/techstack` 스킬로 기술 스택 문서화
- `/database` 스킬로 DB 스키마 설계

**산출물**: docs/techstack.md, docs/database.md

---

### Phase 3: 디자인 시스템 정의

**목표**: 일관된 UI를 위한 디자인 시스템을 수립한다.

**수행 작업**:
- UI UX Pro Max 스킬로 디자인 시스템 생성
- 색상 팔레트, 타이포그래피, 간격 규칙, 컴포넌트 패턴

**산출물**: docs/design-system.md

---

### Phase 4: Pencil 디자인 + UI 스펙

**목표**: 화면을 디자인하고, Hook이 UI 스펙을 자동 동기화한다.

**수행 작업**:
- Pencil MCP 도구로 시각적 디자인
- 디자인 시스템 적용, 사용자 피드백 반영
- **Hook 자동 동기화**: batch_design 호출 후 Hook이 UI 스펙 업데이트를 지시
- screen-registry.yaml에 화면 메타정보 등록

**산출물**:
- Pencil 디자인 파일 (*.pen)
- docs/ui-specs/*.md (Hook 지시에 따라 자동 동기화)
- docs/screen-registry.yaml

**완료 기준**:
- 현재 단계의 모든 화면이 디자인됨
- UI 스펙이 Pencil과 일치함 (Hook이 자동 검증)
- 사용자가 디자인을 승인함

---

### Phase 5: 공통 모듈 설계

**목표**: 병렬 개발을 위한 공통 모듈을 설계한다.

⚠️ **동기화 장벽**: 이 Phase 완료 전에 화면별 구현을 시작하지 않는다.

**수행 작업**:
- `/common-modules` 스킬로 공통 모듈 설계
- 3회 자가 검증 (완전성, 독립성, 최소성)

**산출물**: docs/common-modules.md

---

### Phase 6: 화면별 상태 설계

**목표**: 각 화면의 상태 관리와 비즈니스 로직을 설계한다.

**수행 작업**:
- `/state-plan` 스킬로 화면별 상태 관리 설계

**산출물**: docs/pages/{name}/state.md

---

### Phase 7: 코드 구현

**목표**: 설계를 실제 코드로 구현한다.

**수행 작업**:
- `implementer` 에이전트를 사용하여 구현
- TDD: 테스트 먼저 작성, 구현, 리팩토링
- **Hook 자동 검증**: 코드 수정 시 Hook이 스펙 준수 확인을 지시

**산출물**: 소스 코드, 단위 테스트

**완료 기준**:
- 빌드/린트 에러 0, 단위 테스트 통과
- Hook 동기화 지시 모두 반영됨

---

### Phase 8: 검증

**목표**: 구현이 설계대로 되었는지 검증한다.

**수행 작업**:
- `implement-checker` 에이전트로 스펙 준수 검증
- `code-reviewer` 에이전트로 코드 품질 검증
- `verification-before-completion` 스킬로 최종 확인

**산출물**: 검증 보고서

---

### 기능 추가 (기존 프로젝트)

기존 프로젝트에 기능을 추가할 때:

```
brainstorming → Pencil 디자인 → (Hook이 UI 스펙 자동 동기화)
→ state.md 작성 → 코드 구현 → (Hook이 스펙 준수 자동 확인) → 검증
```

**기획 변경 시:**
1. **영향 범위 분석** — 문서 의존 체인 참조
2. **설계 문서 갱신** — Hook이 의존 체인 불일치를 자동 감지
3. **Pencil 디자인 수정** — Hook이 UI 스펙 동기화 자동 지시
4. **검증** — Hook이 코드-스펙 일치 자동 확인

---

## 사용법

- `/app-design-workflow` — 현재 프로젝트 상태를 파악하고 다음 단계를 안내
- `/app-design-workflow status` — 현재 어느 Phase에 있는지 확인
- `/app-design-workflow next` — 다음 해야 할 작업 안내
- `/app-design-workflow phase N` — 특정 Phase의 작업을 안내

## 필요한 스킬/에이전트

| 스킬/에이전트 | 용도 | 사용 Phase |
|-------------|------|-----------|
| brainstorming | 아이디어 발산, 서비스 방향 탐색 | Phase 0 |
| techstack | 기술 스택 문서화 | Phase 2 |
| database | DB 스키마 설계 | Phase 2 |
| ui-ux-pro-max | 디자인 시스템 생성 | Phase 3 |
| Pencil MCP | 시각적 디자인 | Phase 4 |
| common-modules | 공통 모듈 설계 | Phase 5 |
| state-plan | 화면별 상태 관리 설계 | Phase 6 |
| implementer (agent) | 체계적 코드 구현 | Phase 7 |
| implement-checker (agent) | 스펙 준수 검증 | Phase 8 |
| code-reviewer (agent) | 코드 품질 검증 | Phase 8 |

## SOT 자동 동기화 (Hook 기반)

수동 호출 없이 PostToolUse Hook이 자동으로 동기화를 지시한다:

| Hook | 트리거 | 동작 |
|------|--------|------|
| sot-design-sync | Pencil batch_design 후 | UI 스펙 동기화 지시 |
| sot-doc-sync | docs/*.md 수정 후 | 의존 체인 불일치 감지 |
| sot-code-check | lib/*.dart 수정 후 | 스펙 준수 확인 지시 |

## 핵심 원칙

1. **Hook이 동기화한다** — 수동으로 `/design-sync`, `/doc-sync`를 호출할 필요 없다. Hook이 자동으로 알려준다.
2. **Pencil이 디자인 SOT** — 시각 디자인은 항상 Pencil에서 먼저 수정하고, UI 스펙이 따라간다.
3. **점진적 진행** — 한번에 전체를 하지 않고, 단계별로 나눠서 진행한다.
4. **산출물 연결** — 각 Phase의 산출물이 다음 Phase의 입력이 된다.
5. **검증 필수** — 구현 후 반드시 스펙 대비 검증을 수행한다.
6. **동기화 장벽** — 공통 모듈(Phase 5) 완료 전에 화면별 구현을 시작하지 않는다.
