---
name: skill-creator
description: Claude Code용 스킬(.claude/skills/{name}/)을 자동 생성하는 메타 스킬. "스킬 만들어줘", "새 스킬 생성", "skill 추가" 등의 요청 시 사용. WHY/WHAT/HOW/VERIFY 체계를 자동 적용.
---

# Skill Creator

Claude Code용 스킬 디렉터리(`.claude/skills/{name}/`)를 설계하고 생성하는 메타 스킬.

## 존재 이유

스킬은 일관된 구조(목적, 프로토콜, 검증)를 가져야 한다. 이 스킬은 일관된 구조와 품질을 가진 스킬을 자동 생성한다.

## 트리거

- "스킬 만들어줘", "새 스킬 생성", "skill 추가"
- "커스텀 스킬 만들어줘"
- "자동화 스킬 필요해"

---

## 스킬 구조 원칙

```
.claude/skills/{skill-name}/
├── SKILL.md              ← WHY + WHAT: 목적, 트리거, 프로토콜
└── references/            ← HOW + VERIFY: 템플릿, 가이드, 체크리스트
    ├── {domain-guide}.md
    ├── {template}.md
    └── ...
```

| 파일 | 역할 | 로딩 시점 |
|------|------|----------|
| **SKILL.md** | 스킬의 존재 이유(WHY) + 실행 프로토콜(WHAT) | 스킬 트리거 시 자동 |
| **references/** | 상세 구현 가이드(HOW) + 검증 기준(VERIFY) | SKILL.md에서 참조 시 on-demand |

---

## 생성 프로토콜

### Step 1: 요구사항 수집

사용자의 요청에서 다음을 파악:

| 항목 | 필수 | 설명 |
|------|------|------|
| **목적 (Purpose)** | ✅ | 스킬이 달성할 최종 산출물 |
| **트리거 (Trigger)** | ✅ | 사용자가 사용할 자연어 패턴 |
| **입력 (Input)** | ✅ | 스킬이 필요로 하는 입력 데이터 |
| **산출물 (Output)** | ✅ | 스킬이 생산하는 결과물 |
| **도메인 (Domain)** | ⬜ | 적용 분야 (웹, 모바일, 데이터 등) |
| **에이전트 필요** | ⬜ | 스킬 내에서 호출할 서브에이전트 |

**질문 규칙**: 최대 3개 질문, 각 2-3개 선택지. 명확하면 질문 없이 진행.

### Step 2: SKILL.md 설계

#### 2.1 Frontmatter

```yaml
---
name: {skill-name}
description: {한 문장 설명 — 트리거 키워드 포함}
---
```

#### 2.2 필수 섹션 구조

```markdown
# {Skill Name}

{한 줄 목적 설명}

## 존재 이유
{WHY — 이 스킬이 필요한 이유}

## 트리거
{사용자 요청 패턴 목록}

## 전제 조건
{입력 파일, 환경 요구사항}

## 프로토콜
{단계별 실행 절차}

## 참조 문서
{references/ 내 파일 목록}
```

#### 2.3 프로토콜 설계 원칙

1. **순서 명시**: 각 Phase/Step에 번호 부여
2. **입출력 명시**: 각 단계의 입력과 산출물 정의
3. **검증 포함**: 각 단계 또는 최종에 검증 체크리스트
4. **에이전트 매핑**: 어떤 에이전트가 어떤 단계를 수행하는지
5. **human-in-the-loop**: 사람 개입이 필요한 지점 표시

### Step 3: references/ 설계

| 파일 유형 | 용도 | 예시 |
|----------|------|------|
| **도메인 가이드** | 해당 분야의 규칙·패턴 | `design-system.md`, `seo-guide.md` |
| **템플릿** | 산출물의 표준 형식 | `report-template.md`, `component-template.md` |
| **체크리스트** | 검증 기준 상세 | `qa-checklist.md`, `review-criteria.md` |
| **예시** | 좋은 산출물 예시 | `example-output.md` |

> **on-demand 원칙**: references/는 SKILL.md가 참조할 때만 로딩된다. 큰 가이드는 references/에 넣고, SKILL.md에서 필요할 때 참조하는 구조.

### Step 4: 파일 생성

1. 디렉터리 생성: `.claude/skills/{name}/references/`
2. SKILL.md 작성
3. references/ 파일 작성
4. CLAUDE.md의 스킬 판별 테이블 업데이트

### Step 5: 검증

생성된 스킬을 검증:

- [ ] SKILL.md frontmatter 완전성 (name, description)
- [ ] 존재 이유 섹션 존재 (WHY)
- [ ] 트리거 패턴 정의
- [ ] 프로토콜 단계별 정의 (WHAT)
- [ ] references/ 파일이 SKILL.md에서 참조됨
- [ ] CLAUDE.md 스킬 판별 테이블에 등록

---

## 참조 문서

- 스킬 구조 가이드: `references/skill-structure-guide.md`
