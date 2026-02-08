# CLAUDE.md

## Git Commit Convention

### 규칙
- **Conventional Commits** 형식을 따른다
- 커밋 메시지는 **한국어**로 작성한다
- 형식: `<type>: <subject>`

### Type
| Type | 설명 |
|------|------|
| feat | 새로운 기능 추가 |
| fix | 버그 수정 |
| docs | 문서 변경 |
| style | 코드 포맷팅, 세미콜론 누락 등 (동작 변경 없음) |
| refactor | 리팩토링 (기능 변경 없음) |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 파일 등 기타 변경 |

### 커밋 시점
- 작업이 마무리되면 즉시 커밋한다
- 사용자에게 커밋 여부를 묻지 않고, 변경사항이 있으면 바로 커밋한다
- push는 사용자가 명시적으로 요청할 때만 수행한다
