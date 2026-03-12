# Skill Structure Guide

스킬 디렉터리 구조의 상세 가이드.

---

## 디렉터리 구조

```
.claude/skills/{skill-name}/
├── SKILL.md                    ← 진입점 (자동 로딩)
└── references/                 ← 상세 참조 (on-demand)
    ├── {domain-guide}.md       ← 도메인 규칙
    ├── {template}.md           ← 산출물 템플릿
    └── {checklist}.md          ← 검증 기준
```

## SKILL.md 표준 구조

```markdown
---
name: {kebab-case}
description: {한 문장. 트리거 키워드 반드시 포함}
---

# {Title Case Name}

{한 줄 목적}

## 존재 이유
{이 스킬이 왜 필요한지. 수동으로 하면 어떤 문제가 있는지.}

## 트리거
{자연어 패턴 목록 — 한국어 + 영어}

## 전제 조건
{입력 파일, 디렉터리, 환경 변수, 필수 도구}

## 프로토콜
{Phase/Step별 실행 절차}

## 참조 문서
{references/ 파일 목록 + 설명}
```

## CLAUDE.md 등록

스킬 생성 후 반드시 CLAUDE.md의 스킬 판별 테이블에 추가:

```markdown
## 스킬 사용 판별

| 사용자 요청 패턴 | 스킬 | 진입점 |
|----------------|------|--------|
| "{새 스킬 트리거}" | {새 스킬 이름} | SKILL.md |
```

## references/ 설계 지침

### 파일 크기 기준

| 내용량 | 위치 | 근거 |
|--------|------|------|
| < 50줄 | SKILL.md에 인라인 | 별도 파일 불필요 |
| 50-300줄 | references/ 단일 파일 | on-demand 로딩 |
| > 300줄 | references/ 복수 파일로 분할 | 컨텍스트 효율 |

### 파일 명명 규칙

| 유형 | 패턴 | 예시 |
|------|------|------|
| 도메인 가이드 | `{domain}-guide.md` | `seo-guide.md` |
| 템플릿 | `{output}-template.md` | `report-template.md` |
| 체크리스트 | `{target}-checklist.md` | `qa-checklist.md` |
| 예시 | `example-{type}.md` | `example-output.md` |
| 라이브러리 | `{resource}-library.md` | `section-library.md` |
| 시스템 | `{aspect}-system.md` | `design-system.md` |
