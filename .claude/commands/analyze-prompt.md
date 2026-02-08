---
description: Analyze saved prompts and session data to suggest Skill/Agent/Multi-Agent creation. Supports Deep Analysis (with session files) and Prompt-Only fallback. On user selection, create the automation file directly.
---

# Analyze Prompt Command

This command analyzes saved prompts and session data, suggests automation opportunities, and creates files on user approval.

## What This Command Does

1. **Discover Sessions** - Check `.claude/.session-path-cache` for session data
2. **Read Prompts** - Load saved prompts from `prompt/personal_prompt.md`
3. **Analyze Patterns** - Identify repeated commands, tool usage patterns, multi-step workflows
4. **Calculate Scores** - Score each pattern for Skill/Agent/Multi-Agent fit (기본 + 세션 보너스)
5. **Display Results** - Show patterns and recommendations (mode-dependent format)
6. **Wait for Selection** - MUST receive user choice
7. **Create File** - Generate and save the automation file

## When to Use

Use `/analyze-prompt` when:
- Prompts have accumulated (auto-triggered every 10 prompts)
- You want to identify automation opportunities
- Looking for repeated patterns in your workflow

## Analysis Modes

### Deep Analysis Mode (세션 데이터 있음)

세션 파일이 발견되면 자동으로 Deep Analysis Mode로 전환됩니다.

**추가 분석 항목:**
- 도구 사용 통계 (Bash, Read, Edit 등 각 도구별 호출 횟수)
- 에러 패턴 분석 (에러 발생 비율, 재시도 패턴)
- 워크플로우 시퀀스 (도구 호출 순서 패턴)
- 세션 보너스 점수 합산

### Prompt-Only Mode (세션 데이터 없음)

세션 파일이 없으면 기존 프롬프트 기반 분석으로 동작합니다.

## Output Format

### Deep Analysis Mode

```markdown
## 📊 프롬프트 분석 결과 (Deep Analysis Mode)

> 🔍 세션 파일 N개 분석 완료 — 도구 사용 데이터 기반 심층 분석

### 분석 요약
- 총 프롬프트: N개
- 분석 대상: N개
- 분석 세션: N개

### 도구 사용 통계

| 도구 | 호출 수 | 비율 |
|------|---------|------|
| Bash | 45 | 35% |
| Read | 30 | 23% |
| Edit | 20 | 15% |
| Grep | 15 | 12% |
| ... | ... | ... |

### 발견된 패턴

| 패턴 | 횟수 | 추천 | 기본점수 | 세션보너스 | 최종점수 | 근거 |
|------|------|------|----------|-----------|----------|------|
| "커밋해줘" | 4 | Skill | 5 | +3 | 8점 | git commit 패턴 5세션 반복 |
| "코드 리뷰해줘" | 3 | Agent | 5 | +3 | 8점 | Read/Grep만 사용, 읽기전용 |

### 워크플로우 패턴

| 시퀀스 | 반복 횟수 | 관련 추천 |
|--------|----------|-----------|
| Read→Grep→Edit | 5회 | Skill: edit-pattern |
| Read→Grep→Glob | 3회 | Agent: code-analyzer |

### 💡 자동화 제안

#### 1. `commit` (Skill) — 8점
📁 `.claude/commands/commit.md`
🎯 반복 커밋 작업 자동화
📋 근거: Bash에서 git commit 패턴 5개 세션 반복

#### 2. `code-reviewer` (Agent) — 8점
📁 `.claude/agents/code-reviewer.md`
🎯 코드 품질 분석 전문화
📋 근거: Read/Grep만 사용하는 읽기 전용 패턴

---
생성: 번호 입력 (1, 2, all)
상세: "상세 1"
취소: "취소"
```

### Prompt-Only Mode

```markdown
## 📊 프롬프트 분석 결과 (Prompt-Only Mode)

> ℹ️ 세션 파일 미발견 — 프롬프트 텍스트 기반 분석
> 💡 세션 분석을 활성화하려면 프롬프트를 한 번 더 입력하세요 (캐시 자동 생성)

### 분석 요약
- 총 프롬프트: N개
- 분석 대상: N개

### 발견된 패턴

| 패턴 | 횟수 | 추천 | 점수 |
|------|------|------|------|
| "커밋해줘" | 4 | Skill | 8점 |
| "코드 리뷰해줘" | 3 | Agent | 7점 |

### 💡 자동화 제안

#### 1. `commit` (Skill)
📁 `.claude/commands/commit.md`
🎯 반복 커밋 작업 자동화

#### 2. `code-reviewer` (Agent)
📁 `.claude/agents/code-reviewer.md`
🎯 코드 품질 분석 전문화

---
생성: 번호 입력 (1, 2, all)
상세: "상세 1"
취소: "취소"
```

## User Selection Handling

- **Number input** → Create selected automation
- **"상세 N"** → Show detailed explanation for item N (Deep Mode: 세션 근거 포함)
- **"all"** → Create all recommended automations
- **"취소"** → Cancel and exit

## Creation Process

When user selects a number:

1. **Ask clarifying questions** (if needed)
   - Skill: What steps? What arguments?
   - Agent: What role? Which tools? Read-only?
   - Multi-Agent: Which agents? Parallel or sequential?

2. **Generate file content** using standard format:

### Skill Format
```markdown
---
description: [What it does]. WAIT for user confirmation.
---

# [Name] Command

## What This Command Does
1. [Step 1]
2. [Step 2]

## When to Use
- [Situation]

## Example
[Example usage]
```

### Agent Format
```markdown
---
name: [agent-name]
description: Expert [role]. Use PROACTIVELY when [condition].
tools: ["Read", "Grep", "Glob"]
model: sonnet
---

You are [role description].

## Your Role
- [Responsibility 1]
- [Responsibility 2]

## Process
1. [Step 1]
2. [Step 2]

## Output Format
[Expected output structure]
```

### Multi-Agent Format
Orchestration Skill + multiple Agent files.

3. **Show preview** and wait for confirmation

4. **Create file** at appropriate location:
   - Skill: `.claude/commands/{name}.md`
   - Agent: `.claude/agents/{name}.md`

5. **Confirm creation**:
```
✅ 생성 완료!
📁 .claude/commands/commit.md
🚀 사용법: /commit
```

## Scoring Reference

Check `.claude/rules/automation-criteria.md` for detailed scoring criteria (기본 점수 + 세션 보너스 점수표 포함).
