---
name: techstack
description: "프로젝트의 기술 스택을 분석하고 docs/techstack.md 문서로 정리한다"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
---

# Techstack — 기술 스택 문서화

## 개요

프로젝트의 기술 스택을 분석하고 문서화한다. 각 기술의 선택 이유, 버전, 역할을 명확히 정리하여 이후 설계/구현 단계에서 일관된 기술 결정을 내릴 수 있게 한다.

**시작 시 안내:** "techstack 스킬을 실행합니다. 프로젝트 기술 스택을 분석하고 문서화합니다."

## 사용법

```
/techstack              # 기술 스택 문서 생성
/techstack update       # 기존 문서 갱신
```

## 실행 절차

### Step 1: 프로젝트 컨텍스트
1. **기획 문서 읽기** — 다음 파일을 탐색하여 읽는다:
   - `docs/service-overview*` 또는 `docs/requirements*`
   - `docs/plans/*.md`
   - `README.md`
2. **기존 코드베이스 확인** — `package.json`, `pubspec.yaml`, `build.gradle`, `Podfile` 등 존재 여부 확인
3. **기존 techstack 문서 확인** — `docs/techstack.md` 존재 여부 확인

### Step 2: 기술 스택 결정

기획 문서와 코드베이스를 기반으로 각 계층별 기술을 정리한다.

**결정 기준** (우선순위 순):
1. **AI 친화도** — 문서가 풍부하고 AI가 잘 다룰 수 있는가
2. **안정성** — 잦은 breaking change 없이 안정적인가
3. **유지보수** — 신뢰할 수 있는 조직/커뮤니티가 관리하는가
4. **생산성** — 빠른 개발이 가능한가

**포함할 계층**:
| 계층 | 예시 |
|------|------|
| 프론트엔드/앱 | Flutter, React Native, Next.js 등 |
| 백엔드/BaaS | Supabase, Firebase, NestJS 등 |
| 데이터베이스 | PostgreSQL, MySQL, MongoDB 등 |
| 인증 | Supabase Auth, Firebase Auth, NextAuth 등 |
| 푸시 알림 | FCM, APNs, OneSignal 등 |
| 지도/위치 | Naver Map, Google Maps, Mapbox 등 |
| 상태 관리 | Riverpod, Bloc, Redux, Zustand 등 |
| 테스트 | flutter_test, Jest, Vitest 등 |
| CI/CD | GitHub Actions, Codemagic 등 |
| 배포 | App Store, Play Store, Vercel 등 |

### Step 3: 문서 작성

다음 구조로 `docs/techstack.md`를 생성한다:

```markdown
# 기술 스택 (Tech Stack)

## 개요
[프로젝트 유형과 기술 방향 한 줄 요약]

## 기술 스택 요약

| 계층 | 기술 | 버전 | 선택 이유 |
|------|------|------|----------|
| ... | ... | ... | ... |

## 상세 설명

### [계층명]
- **기술**: [이름 + 버전]
- **역할**: [이 프로젝트에서 하는 일]
- **선택 이유**: [왜 이 기술인가]
- **대안 고려**: [검토했지만 선택하지 않은 기술과 이유]

## 외부 서비스 연동
[API 키가 필요한 서비스, SDK 설정 등]

## 개발 환경
[필요한 도구, 에디터, SDK 버전 등]
```

### Step 4: 커밋

생성된 문서를 커밋한다.

## 프로젝트 탐색 규칙

이 스킬은 특정 프로젝트에 종속되지 않는다. 다음 규칙으로 파일 위치를 동적으로 탐색한다:

| 대상 | 탐색 방법 |
|------|----------|
| 기획 문서 | `docs/service-overview*`, `docs/requirements*`, `docs/plans/*.md` |
| 기존 기술 스택 | `docs/techstack*` |
| 패키지 파일 | `pubspec.yaml`, `package.json`, `build.gradle`, `Podfile` |

## 핵심 원칙

1. **과잉 설계 금지** — 기획에 명시된 기능에 필요한 기술만 포함한다
2. **버전 명시 필수** — 모든 기술에 사용할 버전을 명시한다
3. **선택 이유 필수** — "왜 이 기술인가"를 반드시 기술한다
4. **프로젝트 무관** — 어떤 프로젝트에서도 동일하게 동작한다
