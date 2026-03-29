# Flutter Layout Reference

Flutter 레이아웃 및 스크롤 화면 구성을 위한 필수 가이드라인입니다.

## Table of Contents

- [Layout Selection Guide](#layout-selection-guide)
- [CustomScrollView with Slivers](#customscrollview-with-slivers)
- [ListView for Forms](#listview-for-forms)
- [Common Layout Patterns](#common-layout-patterns)
- [Responsive Design](#responsive-design)
- [CarouselView (카로셀)](#carouselview-카로셀)
- [실전 예제: 자동 회전 배너 카로셀](#-실전-예제-자동-회전-배너-카로셀)
- [Rounded Corner 적용 방법](#️-rounded-corner-적용-방법-중요)
- [Timer 기반 자동 회전 구현](#timer-기반-자동-회전-구현)
- [flexWeights 가중치 이해](#flexweights-가중치-이해)

---

## Layout Selection Guide

### 화면 유형별 권장 레이아웃

| 화면 유형 | 권장 레이아웃 | 이유 |
|----------|-------------|------|
| 앱바 + 스크롤 콘텐츠 | `CustomScrollView + Sliver` | 고급 UX 가능 |
| 고정 헤더 + 리스트 | `CustomScrollView + Sliver` | 조립 가능 |
| 로그인/입력 폼 | `ListView` | 키보드 처리 용이 |
| 단순 스크롤 | `SingleChildScrollView` | 간단한 구현 |
| 고정 레이아웃 | `Column/Row` | 스크롤 불필요 |

---

## CustomScrollView with Slivers

### 사용 시점

- 앱바/탭/고정 헤더 + 스크롤 콘텐츠 조합
- 고정되는 헤더 + 리스트 + 섹션이 섞인 화면
- pinned/float/stretch 같은 고급 UX 필요 시
- 대규모 화면 표준 레이아웃

### 기본 구조

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(pinned: true, title: Text(T.title)),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => ItemWidget(i),
        childCount: 100,
      ),
    ),
  ],
)
```

### SliverAppBar 옵션

| 속성 | 설명 | 사용 사례 |
|------|------|----------|
| `pinned: true` | 스크롤해도 앱바 고정 | 항상 보이는 앱바 |
| `floating: true` | 위로 스크롤 시 앱바 표시 | 빠른 접근 필요 |
| `snap: true` | floating과 함께, 스냅 효과 | 부드러운 UX |
| `stretch: true` | 당기면 앱바 확장 | 리프레시 효과 |
| `expandedHeight` | 확장 시 높이 | 이미지 배경 앱바 |

### 다양한 Sliver 위젯

```dart
CustomScrollView(
  slivers: [
    // 고정 앱바
    SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(T.title),
        background: Image.network(url, fit: BoxFit.cover),
      ),
    ),

    // 고정 헤더
    SliverPersistentHeader(
      pinned: true,
      delegate: MySliverHeaderDelegate(),
    ),

    // 리스트
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: items.length,
      ),
    ),

    // 그리드
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => GridItem(index),
        childCount: gridItems.length,
      ),
    ),

    // 하단 패딩
    SliverPadding(
      padding: const EdgeInsets.only(bottom: 80),
      sliver: SliverToBoxAdapter(child: Container()),
    ),
  ],
)
```

### SliverToBoxAdapter

일반 위젯을 Sliver로 변환합니다.

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(...),

    // 일반 위젯을 Sliver로 변환
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(T.sectionTitle, style: theme.textTheme.titleLarge),
      ),
    ),

    SliverList(...),
  ],
)
```

---

## ListView for Forms

### 사용 시점

- 키보드 입력이 필요한 화면
- 로그인, 회원가입, 입력 폼
- 콘텐츠가 화면을 넘칠 수 있는 경우

### 기본 구조

```dart
ListView(
  padding: const EdgeInsets.all(16),
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  children: [
    ComicTextFormField(
      controller: _emailController,
      labelText: T.email,
    ),
    const SizedBox(height: 16),
    ComicTextFormField(
      controller: _passwordController,
      labelText: T.password,
      obscureText: true,
    ),
    const SizedBox(height: 24),
    ComicPrimaryButton(
      onPressed: _submit,
      child: Text(T.login),
    ),
  ],
)
```

### 장점

- 키보드 올라올 때 스크롤/레이아웃이 덜 꼬임
- `keyboardDismissBehavior`로 키보드 닫기 UX 제공
- 폼은 사실상 "필드들의 리스트"라 ListView가 적합

### ListView.builder vs ListView

| 사용 방법 | 사용 시점 |
|----------|----------|
| `ListView(children: [...])` | 아이템 수가 적을 때 (10개 미만) |
| `ListView.builder()` | 아이템 수가 많거나 동적일 때 |
| `ListView.separated()` | 구분선이 필요할 때 |

```dart
// 많은 아이템 - builder 사용
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// 구분선 필요 - separated 사용
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
  separatorBuilder: (context, index) => const Divider(),
)
```

---

## Common Layout Patterns

### 패턴 1: 앱바 + 스크롤 리스트

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(
        pinned: true,
        title: Text(T.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 2, color: scheme.outline),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListItem(items[index]),
          childCount: items.length,
        ),
      ),
    ],
  ),
)
```

### 패턴 2: 탭 + 스크롤 콘텐츠

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          title: Text(T.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tab 1'),
              Tab(text: 'Tab 2'),
              Tab(text: 'Tab 3'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        children: [
          TabContent1(),
          TabContent2(),
          TabContent3(),
        ],
      ),
    ),
  ),
)
```

### 패턴 3: 고정 헤더 + 리스트 + FAB

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(pinned: true, title: Text(T.title)),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ItemCard(items[index]),
            ),
            childCount: items.length,
          ),
        ),
      ),
      // FAB 공간 확보
      const SliverToBoxAdapter(
        child: SizedBox(height: 80),
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: _addItem,
    child: const Icon(Icons.add),
  ),
)
```

### 패턴 4: 검색 + 필터 + 리스트

```dart
CustomScrollView(
  slivers: [
    // 검색바
    SliverAppBar(
      floating: true,
      snap: true,
      title: SearchBar(controller: _searchController),
    ),

    // 필터 칩
    SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: filters.map((f) => FilterChip(label: Text(f))).toList(),
        ),
      ),
    ),

    // 결과 리스트
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ResultItem(results[index]),
        childCount: results.length,
      ),
    ),
  ],
)
```

---

## Responsive Design

### MediaQuery 사용

```dart
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;

  return isTablet
      ? TwoColumnLayout(...)
      : SingleColumnLayout(...);
}
```

### LayoutBuilder 사용

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 1200) {
      return DesktopLayout();
    } else if (constraints.maxWidth > 600) {
      return TabletLayout();
    } else {
      return MobileLayout();
    }
  },
)
```

### 그리드 반응형 레이아웃

```dart
SliverGrid(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,  // 최대 너비
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1,
  ),
  delegate: SliverChildBuilderDelegate(
    (context, index) => GridItem(index),
    childCount: items.length,
  ),
)
```

---

## Quick Reference

| 상황 | 사용 위젯 |
|------|----------|
| 앱바 + 스크롤 | `CustomScrollView + SliverAppBar + SliverList` |
| 입력 폼 | `ListView + keyboardDismissBehavior` |
| 탭 + 스크롤 | `NestedScrollView + TabBarView` |
| 그리드 레이아웃 | `SliverGrid` 또는 `GridView.builder` |
| 일반 위젯을 Sliver로 | `SliverToBoxAdapter` |
| 고정 헤더 | `SliverPersistentHeader` |
| 카로셀/슬라이더 | `CarouselView` 또는 `CarouselView.weighted` |

---

## CarouselView (카로셀)

### 필수 지침

> **⚠️ 중요**: Flutter에서 카로셀(슬라이더) UI를 구현할 때는 **반드시 `CarouselView`를 사용**합니다.
> 외부 패키지(carousel_slider 등)를 사용하지 않고 Flutter 기본 제공 위젯을 활용합니다.

### 개요

`CarouselView`는 Material Design 3의 카로셀 위젯으로, 스크롤 가능한 아이템 목록을 표시하며 선택한 레이아웃에 따라 각 아이템의 크기가 동적으로 변경됩니다.

### Material Design 3 카로셀 레이아웃 유형

| 레이아웃 | 설명 | 지원 생성자 |
|----------|------|-------------|
| **Multi-browse** | 한 번에 대/중/소 크기 아이템 표시 | `CarouselView.weighted` |
| **Uncontained** (기본) | 컨테이너 가장자리까지 스크롤되는 아이템 | `CarouselView` |
| **Hero** | 하나의 큰 아이템과 작은 아이템 표시 | `CarouselView.weighted` |
| **Full-screen** | 화면 전체를 채우는 단일 아이템 | 둘 다 지원 |

### 생성자 선택 가이드

| 사용 사례 | 생성자 |
|----------|--------|
| 균일한 크기의 아이템 | `CarouselView` |
| 동적 크기 변경이 필요한 아이템 | `CarouselView.weighted` |
| 전체 화면 카로셀 | 둘 다 가능 |

---

### 🚀 CarouselView 구현 단계

카로셀을 구현할 때 다음 단계를 따릅니다:

#### Step 1: CarouselController 생성

```dart
// 초기 표시할 아이템 인덱스 지정
final controller = CarouselController(
  initialItem: 0,  // 첫 번째 아이템부터 시작
);
```

#### Step 2: CarouselView에 Controller 전달

```dart
CarouselView(
  controller: controller,
  // ...
)
```

#### Step 3: children과 itemExtent 추가

```dart
CarouselView(
  controller: controller,
  itemExtent: 200.0,  // 각 아이템의 기본 크기
  children: items,
)
```

---

### ⚠️ 중요 옵션

#### shrinkExtent - Edge 아이템 크기 조절

`shrinkExtent`를 사용하여 **컨테이너 가장자리(edge)에 있는 아이템의 최소 크기**를 지정합니다.

```dart
CarouselView(
  itemExtent: 330,      // 기본 아이템 크기
  shrinkExtent: 200,    // edge 아이템의 최소 크기
  children: items,
)
```

#### flexWeights - 동적 크기 비율 조절

`CarouselView.weighted`의 `flexWeights`로 **각 위치의 아이템 크기 비율**을 세밀하게 조절합니다.

```dart
// edge로 갈수록 작아지는 레이아웃
CarouselView.weighted(
  flexWeights: const <int>[3, 3, 3, 2, 1],  // 중앙 → edge 순서
  consumeMaxWeight: false,
  children: items,
)
```

#### Full-screen 레이아웃 구현 (2가지 방법)

```dart
// 방법 1: itemExtent 사용
CarouselView(
  scrollDirection: Axis.vertical,
  itemExtent: double.infinity,  // 전체 화면 차지
  children: items,
)

// 방법 2: flexWeights 사용
CarouselView.weighted(
  scrollDirection: Axis.vertical,
  flexWeights: const <int>[1],  // 단일 가중치 = 전체 화면
  children: items,
)
```

---

### CarouselView (기본 생성자)

균일한 크기의 아이템을 표시하는 기본 카로셀입니다. `ListView`와 유사하게 동작합니다.

#### 주요 속성

| 속성 | 설명 |
|------|------|
| `itemExtent` | 아이템의 기본 크기 (필수) |
| `shrinkExtent` | 압축 시 최소 허용 크기 |
| `scrollDirection` | 스크롤 방향 (기본: `Axis.horizontal`) |
| `itemSnapping` | 스냅 효과 활성화 |

#### 기본 사용 예시

```dart
CarouselView(
  itemExtent: 330,
  shrinkExtent: 200,
  children: List<Widget>.generate(20, (int index) {
    return ColoredBox(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(
        child: Text('Item $index'),
      ),
    );
  }),
)
```

#### 전체 화면 세로 카로셀

```dart
Scaffold(
  body: CarouselView(
    scrollDirection: Axis.vertical,
    itemExtent: double.infinity,
    children: List<Widget>.generate(10, (int index) {
      return Center(child: Text('Item $index'));
    }),
  ),
)
```

---

### CarouselView.weighted (동적 크기)

`flexWeights`를 사용하여 각 아이템이 뷰포트에서 차지하는 비율을 동적으로 조절합니다.

#### 가중치(flexWeights) 이해하기

가중치는 **상대적 비율**입니다:

- `[3, 2, 1]` → 첫 번째 아이템 3/6, 두 번째 2/6, 세 번째 1/6 차지
- 스크롤 시 뒤의 아이템이 앞 아이템의 크기로 점진적 변화
- 첫 번째 아이템이 화면을 벗어나면 이전과 동일한 레이아웃 유지

#### Hero 레이아웃 (중앙 강조)

```dart
ConstrainedBox(
  constraints: BoxConstraints(maxHeight: height / 2),
  child: CarouselView.weighted(
    controller: controller,
    itemSnapping: true,
    flexWeights: const <int>[1, 7, 1],  // 중앙 아이템 강조
    children: images.map((image) {
      return HeroLayoutCard(imageInfo: image);
    }).toList(),
  ),
)
```

#### Multi-browse 레이아웃

```dart
// 간단한 Multi-browse
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 50),
  child: CarouselView.weighted(
    flexWeights: const <int>[1, 2, 3, 2, 1],
    consumeMaxWeight: false,
    children: List<Widget>.generate(20, (int index) {
      return ColoredBox(
        color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.8),
        child: const SizedBox.expand(),
      );
    }),
  ),
)

// 카드 형태 Multi-browse
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 200),
  child: CarouselView.weighted(
    flexWeights: const <int>[3, 3, 3, 2, 1],
    consumeMaxWeight: false,
    children: cardInfoList.map((info) {
      return ColoredBox(
        color: info.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(info.icon, color: info.color, size: 32.0),
              Text(info.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }).toList(),
  ),
)
```

#### 전체 화면 세로 카로셀 (weighted)

```dart
Scaffold(
  body: CarouselView.weighted(
    scrollDirection: Axis.vertical,
    flexWeights: const <int>[1],  // 배열 길이 1 = 전체 화면
    children: List<Widget>.generate(10, (int index) {
      return Center(child: Text('Item $index'));
    }),
  ),
)
```

---

### CarouselController

카로셀의 초기 아이템 설정 및 프로그래밍 방식 제어를 위한 컨트롤러입니다.

#### 주요 속성 및 메서드

| 속성/메서드 | 설명 |
|-------------|------|
| `initialItem` | 처음 표시될 때 최대 크기로 확장될 아이템 인덱스 |
| `animateToItem()` | 지정 아이템으로 애니메이션 이동 (기본 300ms, ease) |

#### 사용 예시

```dart
class _CarouselExampleState extends State<CarouselExample> {
  // 초기 아이템을 1번 인덱스로 설정
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();  // 반드시 dispose 호출
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselView.weighted(
      controller: controller,
      itemSnapping: true,
      flexWeights: const <int>[1, 7, 1],
      children: items,
    );
  }

  // 특정 아이템으로 이동
  void goToItem(int index) {
    controller.animateToItem(index);
  }
}
```

#### weighted에서의 initialItem 동작

`CarouselView.weighted`에서 `flexWeights`가 `[1, 2, 3, 2, 1]`이고 `initialItem`이 4인 경우:
- 화면에 2, 3, 4, 5, 6번 아이템이 표시됨
- 각각 1, 2, 3, 2, 1 가중치로 배치됨

---

### 데스크톱/웹 동작

- 마우스 드래그로 스크롤은 기본적으로 **비활성화**
- **Shift + 마우스 휠**로 가로 스크롤 가능
- `ScrollBehavior.pointerAxisModifiers`로 키 조합 동작 제어
- `ScrollBehavior.dragDevices`로 드래그 가능 기기 설정

---

### 종합 예제

```dart
class CarouselExample extends StatefulWidget {
  const CarouselExample({super.key});

  @override
  State<CarouselExample> createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;

    return ListView(
      children: <Widget>[
        // Hero 레이아웃 카로셀
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height / 2),
          child: CarouselView.weighted(
            controller: controller,
            itemSnapping: true,
            flexWeights: const <int>[1, 7, 1],
            children: images.map((image) => HeroCard(image: image)).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Multi-browse 레이아웃
        const Padding(
          padding: EdgeInsetsDirectional.only(top: 8.0, start: 8.0),
          child: Text('Multi-browse layout'),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: CarouselView.weighted(
            flexWeights: const <int>[3, 3, 3, 2, 1],
            consumeMaxWeight: false,
            children: cards,
          ),
        ),
        const SizedBox(height: 20),

        // Uncontained 레이아웃
        const Padding(
          padding: EdgeInsetsDirectional.only(top: 8.0, start: 8.0),
          child: Text('Uncontained layout'),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: CarouselView(
            itemExtent: 330,
            shrinkExtent: 200,
            children: List<Widget>.generate(20, (int index) {
              return UncontainedCard(index: index, label: 'Show $index');
            }),
          ),
        ),
      ],
    );
  }
}
```

---

### 🎯 실전 예제: 자동 회전 배너 카로셀

API에서 배너 데이터를 받아와 자동 회전하는 카로셀 구현 예제입니다.

#### 전체 구조

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class AutoRotatingBannerCarousel extends StatefulWidget {
  const AutoRotatingBannerCarousel({super.key});

  @override
  State<AutoRotatingBannerCarousel> createState() => _AutoRotatingBannerCarouselState();
}

class _AutoRotatingBannerCarouselState extends State<AutoRotatingBannerCarousel> {
  /// 배너 데이터 목록
  List<BannerModel> banners = [];

  /// 로딩 상태
  bool isLoading = true;

  /// 카로셀 컨트롤러 (자동 회전 제어용)
  CarouselController? _carouselController;

  /// 자동 회전 타이머
  Timer? _autoScrollTimer;

  /// 현재 표시 중인 아이템 인덱스
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    /// 타이머 해제 (메모리 누수 방지)
    _autoScrollTimer?.cancel();
    /// 컨트롤러 해제
    _carouselController?.dispose();
    super.dispose();
  }

  /// 배너 데이터 로드
  Future<void> _loadBanners() async {
    final result = await BannerApi.getBanners();

    if (mounted) {
      setState(() {
        banners = result;
        isLoading = false;

        /// 데이터 로드 완료 후 컨트롤러 초기화 및 자동 회전 시작
        if (banners.isNotEmpty) {
          _carouselController = CarouselController();
          _startAutoScroll();
        }
      });
    }
  }

  /// 자동 회전 타이머 시작
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (banners.isEmpty || _carouselController == null) return;

      /// 다음 인덱스로 이동
      _currentIndex = _currentIndex + 1;

      /// 끝에서 N개 전에 도달하면 처음으로 리셋
      /// (flexWeights 배열 길이에 맞춰 조정)
      if (_currentIndex >= banners.length - 3) {
        _currentIndex = 0;
      }

      /// 애니메이션과 함께 해당 인덱스로 이동
      _carouselController!.animateToItem(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();
    if (banners.isEmpty) return const SizedBox.shrink();

    /// 화면 너비 기준으로 아이템 크기 계산
    final screenWidth = MediaQuery.sizeOf(context).width;
    final itemExtent = screenWidth / 4;

    return SizedBox(
      height: itemExtent,
      child: CarouselView.weighted(
        controller: _carouselController,
        flexWeights: const <int>[4, 4, 4, 3],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: banners.map((banner) => _buildBannerItem(banner)).toList(),
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return InkWell(
      onTap: () => _handleBannerTap(banner),
      child: ClipRRect(
        /// ⚠️ 중요: 이미지에 rounded corner 적용
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: banner.url,
          width: double.infinity,
          height: double.infinity,
          /// BoxFit.cover로 컨테이너를 꽉 채워야 ClipRRect 효과 적용됨
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
```

---

### ⚠️ Rounded Corner 적용 방법 (중요)

CarouselView에서 아이템에 둥근 모서리를 적용하는 **2가지 방법**이 있습니다:

#### 방법 1: CarouselView의 `shape` 속성 사용

```dart
CarouselView.weighted(
  /// CarouselView 전체 아이템에 일괄 적용
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  children: items,
)
```

> **주의**: `shape`는 CarouselView가 아이템을 감싸는 컨테이너에 적용됩니다.

#### 방법 2: 개별 아이템에 `ClipRRect` 사용 (권장)

```dart
/// ✅ 권장: 이미지에 직접 ClipRRect 적용
Widget _buildBannerItem(BannerModel banner) {
  return ClipRRect(
    /// 원하는 radius 값 지정
    borderRadius: BorderRadius.circular(8),
    child: CachedNetworkImage(
      imageUrl: banner.url,
      width: double.infinity,
      height: double.infinity,
      /// ⚠️ 필수: BoxFit.cover로 설정해야 ClipRRect 효과가 보임
      fit: BoxFit.cover,
    ),
  );
}
```

#### shape 비활성화 + ClipRRect 조합

```dart
CarouselView.weighted(
  /// shape를 직사각형으로 설정 (기본 rounded 제거)
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  padding: const EdgeInsets.symmetric(horizontal: 4),
  children: banners.map((banner) {
    /// 개별 아이템에 ClipRRect로 rounded corner 적용
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(banner.url, fit: BoxFit.cover),
    );
  }).toList(),
)
```

---

### Timer 기반 자동 회전 구현

#### 핵심 코드

```dart
class _CarouselState extends State<CarouselWidget> {
  CarouselController? _carouselController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void dispose() {
    /// ⚠️ 반드시 타이머와 컨트롤러 해제
    _autoScrollTimer?.cancel();
    _carouselController?.dispose();
    super.dispose();
  }

  /// 자동 회전 시작
  void _startAutoScroll() {
    /// 기존 타이머 취소 (중복 실행 방지)
    _autoScrollTimer?.cancel();

    /// N초마다 다음 아이템으로 이동
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (items.isEmpty || _carouselController == null) return;

      _currentIndex = _currentIndex + 1;

      /// 인덱스 리셋 조건 (flexWeights 길이 고려)
      /// flexWeights: [4, 4, 4, 3] = 4개이므로 length - 3에서 리셋
      if (_currentIndex >= items.length - 3) {
        _currentIndex = 0;
      }

      /// 애니메이션과 함께 이동
      _carouselController!.animateToItem(_currentIndex);
    });
  }

  /// 데이터 로드 후 초기화
  void _initCarousel() {
    _carouselController = CarouselController();
    _startAutoScroll();
  }
}
```

#### 인덱스 리셋 조건 설정

| flexWeights 길이 | 권장 리셋 조건 | 설명 |
|-----------------|---------------|------|
| 3개 `[1, 7, 1]` | `length - 2` | 마지막 2개 전에 리셋 |
| 4개 `[4, 4, 4, 3]` | `length - 3` | 마지막 3개 전에 리셋 |
| 5개 `[3, 3, 3, 2, 1]` | `length - 4` | 마지막 4개 전에 리셋 |

> **공식**: `리셋 조건 = items.length - (flexWeights.length - 1)`

---

### flexWeights 가중치 이해

```dart
/// 예시: 4개 아이템이 화면에 표시되는 레이아웃
flexWeights: const <int>[4, 4, 4, 3]
```

| 위치 | 가중치 | 설명 |
|------|--------|------|
| 첫 번째 | 4 | 현재 보이는 첫 아이템 |
| 두 번째 | 4 | 두 번째 아이템 |
| 세 번째 | 4 | 세 번째 아이템 |
| 네 번째 | 3 | 가장자리 아이템 (약간 작음) |

#### 가중치 합계와 비율 계산

```
총 가중치 = 4 + 4 + 4 + 3 = 15
첫 번째 아이템 너비 = 화면너비 × (4/15) ≈ 26.7%
네 번째 아이템 너비 = 화면너비 × (3/15) = 20%
```
