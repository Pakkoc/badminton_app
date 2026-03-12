# Pencil → Flutter 위젯 매핑 가이드

Pencil 디자인(.pen) 노드를 Flutter 위젯으로 변환하는 규칙.

---

## 1. 변환 프로세스

### Step 1: 디자인 구조 읽기

```
batch_get(patterns=["화면이름*"])  → 노드 트리 파악
get_screenshot(nodeId)            → 시각적 확인
snapshot_layout()                 → 레이아웃 좌표 확인
```

### Step 2: 노드 → 위젯 매핑표 작성

UI 스펙의 3.x절과 대조하며 매핑표 작성:

```
| Pencil 노드 | 노드 타입 | Flutter 위젯 | 비고 |
|-------------|----------|-------------|------|
| Frame "Header" | frame | Column + Padding | 수직 레이아웃 |
| Text "title" | text | Text (titleLarge) | Theme 사용 |
| Image "avatar" | image | CircleAvatar | 48x48 |
| Frame "card" | frame | Card | radius 20 |
```

### Step 3: 위젯 코드 생성

매핑표 기반으로 코드 작성. 하나씩 생성 → 검증 → 다음.

### Step 4: 스크린샷 대조 검증

```
get_screenshot(nodeId)  → 디자인 이미지
```

생성된 위젯과 비교하여 불일치 수정.

---

## 2. 노드 타입별 위젯 매핑

### 2.1 레이아웃 노드

| Pencil 속성 | Flutter 위젯 | 조건 |
|-------------|-------------|------|
| frame (수직 정렬) | `Column` | children이 세로 배치 |
| frame (수평 정렬) | `Row` | children이 가로 배치 |
| frame (겹침) | `Stack` | children이 겹쳐있음 |
| frame (스크롤) | `SingleChildScrollView` + `Column` | 화면 초과 시 |
| frame (리스트) | `ListView.builder` | 반복 아이템 |
| frame + padding | `Padding` or Container padding | 내부 여백 |
| frame + gap | `SizedBox(height/width: N)` | children 간 간격 |

### 2.2 텍스트 노드

| Pencil 속성 | Flutter 매핑 |
|-------------|-------------|
| fontSize: 32, bold | `Theme.of(context).textTheme.displayLarge` |
| fontSize: 28, bold | `Theme.of(context).textTheme.displayMedium` |
| fontSize: 24, semibold | `Theme.of(context).textTheme.headlineLarge` |
| fontSize: 20, semibold | `Theme.of(context).textTheme.headlineMedium` |
| fontSize: 18, semibold | `Theme.of(context).textTheme.titleLarge` |
| fontSize: 16, semibold | `Theme.of(context).textTheme.titleMedium` |
| fontSize: 16, regular | `Theme.of(context).textTheme.bodyLarge` |
| fontSize: 14, regular | `Theme.of(context).textTheme.bodyMedium` |
| fontSize: 12, regular | `Theme.of(context).textTheme.bodySmall` |
| fontSize: 14, medium | `Theme.of(context).textTheme.labelLarge` |
| fontSize: 12, medium | `Theme.of(context).textTheme.labelMedium` |

**색상 매핑:**

| Pencil 색상 | Flutter 매핑 |
|-------------|-------------|
| #1A1A2E (Dark Navy) | `AppTheme.textPrimary` 또는 textTheme 기본 |
| #4A4A5A (Gray) | `AppTheme.textSecondary` |
| #9CA3AF (Light Gray) | `AppTheme.textTertiary` |
| #2563EB (Blue) | `Theme.of(context).colorScheme.primary` |
| #EF4444 (Red) | `AppTheme.error` |

### 2.3 컨테이너/카드 노드

| Pencil 속성 | Flutter 위젯 |
|-------------|-------------|
| fill + border + radius 20 | `Card(shape: RoundedRectangleBorder(...))` |
| fill + radius 14 | `Container(decoration: BoxDecoration(...))` |
| fill + radius 999 | `Container(decoration: BoxDecoration(borderRadius: 999))` — 뱃지/칩 |
| shadow | `Card` 또는 `BoxDecoration(boxShadow: ...)` |

### 2.4 인터랙티브 노드

| Pencil 속성 | Flutter 위젯 |
|-------------|-------------|
| 버튼 (primary fill) | `ElevatedButton` |
| 버튼 (outline) | `OutlinedButton` |
| 버튼 (텍스트) | `TextButton` |
| 토글/스위치 | `Switch` |
| 텍스트 입력 | `TextFormField` |
| 체크박스 | `Checkbox` |
| 탭 가능 영역 | `GestureDetector` 또는 `InkWell` |

### 2.5 이미지/아이콘 노드

| Pencil 속성 | Flutter 위젯 |
|-------------|-------------|
| 아이콘 (Material) | `Icon(Icons.xxx)` |
| 원형 이미지 | `CircleAvatar` |
| 사각 이미지 | `ClipRRect + Image.network` |
| SVG 아이콘 | `SvgPicture.asset` (flutter_svg 패키지) |

---

## 3. 크기/간격 변환 규칙

### 3.1 크기

```dart
// Pencil의 px 값 → Flutter의 logical pixel (dp)
// Pencil에서 width: 48, height: 48
Container(width: 48, height: 48)  // 1:1 대응

// 전체 너비
SizedBox(width: double.infinity)
// 또는 Expanded() 사용
```

### 3.2 간격 (Gap/Padding)

```dart
// Pencil gap: 16 (수직)
const SizedBox(height: 16)

// Pencil gap: 8 (수평)
const SizedBox(width: 8)

// Pencil padding: 16 all
const EdgeInsets.all(16)

// Pencil padding: 16 horizontal, 12 vertical
const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
```

### 3.3 최소 터치 영역

```dart
// 최소 44x44 (접근성 기준)
SizedBox(
  width: 44,
  height: 44,
  child: IconButton(icon: Icon(Icons.close), onPressed: ...),
)
```

---

## 4. 색상 변환 규칙

**절대 하드코딩하지 않는다. 항상 AppTheme 또는 Theme.of(context) 사용.**

| Pencil 색상 코드 | Flutter 코드 |
|-----------------|-------------|
| #2563EB | `Theme.of(context).colorScheme.primary` 또는 `AppTheme.primary` |
| #1D4ED8 | `AppTheme.primaryDark` |
| #60A5FA | `AppTheme.primaryLight` |
| #EFF6FF | `AppTheme.primaryContainer` |
| #FBF8F4 | `AppTheme.background` |
| #FFFFFF | `AppTheme.surface` |
| #1A1A2E | `AppTheme.textPrimary` |
| #4A4A5A | `AppTheme.textSecondary` |
| #9CA3AF | `AppTheme.textTertiary` |
| #E8E0D8 | `AppTheme.border` (dividerColor) |
| #EF4444 | `AppTheme.error` |
| #F59E0B | `AppTheme.warning` |
| #10B981 | `AppTheme.success` |
| 상태 색상 (received/inProgress/completed) | `AppTheme.xxxBackground/Foreground/Text` |

---

## 5. 반복 패턴 처리

### 5.1 동일 구조 반복 (리스트)

Pencil에서 같은 구조가 여러 번 반복되면 → `ListView.builder` + private 위젯

```dart
// Pencil: 카드가 3개 반복
ListView.builder(
  itemCount: items.length,
  itemBuilder: (_, i) => _ItemCard(item: items[i]),
)
```

### 5.2 컴포넌트 인스턴스 (ref)

Pencil에서 ref(심볼)로 연결된 컴포넌트 → 재사용 가능한 위젯 클래스

```dart
// Pencil: 여러 화면에서 같은 심볼 사용
// → lib/widgets/ 에 공통 위젯으로 추출
class OrderCard extends StatelessWidget { ... }
```

---

## 6. 검증 체크리스트

변환 완료 후 확인:

- [ ] 모든 Pencil 노드에 대응하는 Flutter 위젯이 있는가?
- [ ] 텍스트 크기/Weight가 textTheme과 일치하는가?
- [ ] 색상이 하드코딩 없이 AppTheme/colorScheme으로 매핑되었는가?
- [ ] 간격(SizedBox)이 디자인과 일치하는가?
- [ ] 모서리 둥글기가 규칙(14/20/999)을 따르는가?
- [ ] 터치 영역이 최소 44x44인가?
- [ ] get_screenshot 대조 시 시각적으로 일치하는가?
