# 소셜 로그인 도입 설계

> 작성일: 2026-02-20

## 배경

기존 이메일/비밀번호 로그인을 소셜 로그인(카카오, 네이버, Gmail)으로 전환한다.
로그인과 회원가입을 하나의 통합 플로우로 단순화한다.

## 변경 플로우

```
스플래시 → 소셜 로그인(카카오/네이버/Gmail)
              ↓
         ┌── 기존 사용자 → 역할별 홈으로 바로 이동
         └── 신규 사용자 → 프로필 설정(역할+이름+연락처)
                              ↓
                         ┌── 고객 → 고객 홈
                         └── 사장님 → 샵 등록 → 대시보드
```

## 화면별 변경

### 1. 로그인 화면 (대폭 변경)

**제거:**
- 이메일/비밀번호 입력 필드
- 비밀번호 찾기 링크
- 회원가입 버튼 + 안내 텍스트

**추가:**
- 카카오 로그인 버튼 (배경 `#FEE500`, 텍스트 `#191919`)
- 네이버 로그인 버튼 (배경 `#03C75A`, 텍스트 `#FFFFFF`)
- Gmail 로그인 버튼 (배경 `#FFFFFF`, 테두리 `#E2E8F0`, 텍스트 `#0F172A`)
- "간편하게 시작하세요" 안내 문구

**로그인 처리:**
- Supabase Auth의 `signInWithOAuth` 사용
- 소셜 로그인 성공 후 `users` 테이블 조회
  - 레코드 존재 → 역할별 홈으로 이동
  - 레코드 없음 → 프로필 설정 화면으로 이동

### 2. 회원가입 → 프로필 설정 화면 (중간 변경)

**화면명 변경:** "회원가입" → "프로필 설정"

**제거:**
- 이메일 입력 필드
- 비밀번호 입력 필드
- 비밀번호 확인 입력 필드
- "이미 계정이 있으신가요? 로그인" 링크

**유지:**
- 역할 선택 카드 (고객/샵 사장님)
- 이름 입력 필드 (소셜 프로필 이름을 기본값으로)
- 연락처 입력 필드
- StepIndicator (사장님 선택 시)

**변경:**
- 앱바 타이틀: "회원가입" → "프로필 설정"
- 안내 문구 추가: "서비스 이용을 위해 정보를 입력해주세요"
- 버튼 텍스트: 고객 → "시작하기", 사장님 → "다음"

### 3. 샵 등록 화면 (변경 없음)

기존과 동일하게 유지.

## 기술 구현

### Supabase Auth 소셜 로그인

```dart
// 카카오 로그인
await supabase.auth.signInWithOAuth(OAuthProvider.kakao);

// 네이버 로그인
await supabase.auth.signInWithOAuth(OAuthProvider.naver);  // custom provider

// Google 로그인
await supabase.auth.signInWithOAuth(OAuthProvider.google);
```

### 신규/기존 사용자 판별

```dart
final user = supabase.auth.currentUser;
final profile = await supabase
  .from('users')
  .select('role')
  .eq('id', user!.id)
  .maybeSingle();

if (profile == null) {
  // 신규 사용자 → 프로필 설정으로 이동
} else {
  // 기존 사용자 → 역할별 홈으로 이동
}
```

## 영향 범위

| 항목 | 변경 |
|------|------|
| UI 스펙 - login.md | 대폭 수정 |
| UI 스펙 - signup.md | 중간 수정 (프로필 설정으로 변경) |
| UI 스펙 - shop-signup.md | 변경 없음 |
| Pencil - 로그인 화면 | 대폭 변경 |
| Pencil - 회원가입 화면 | 중간 변경 |
| Pencil - 샵 등록 화면 | 변경 없음 |
