# Epi Care App 개발 가이드

## 프로젝트 구조

```
epi_care_app/
├── lib/
│   ├── main.dart                    # 메인 앱 (현재 테스트용)
│   ├── widgets/
│   │   └── loading_screen.dart      # 로딩 화면 위젯
│   └── utils/
│       └── loading_utils.dart       # 로딩 유틸리티
├── assets/
│   ├── images/                      # 이미지 파일들
│   └── fonts/                       # 폰트 파일들
└── pubspec.yaml                     # 프로젝트 설정 파일
```

---

## 구현된 기능

### 1. 로딩 화면 (`loading_screen.dart`)

백엔드 응답이 지연될 때 자동으로 표시되는 로딩 화면입니다.

**특징:**
- 고양이 캐릭터 이미지 표시 (이미지 추가 시)
- "로딩중..." 텍스트
- 애니메이션 로딩 인디케이터

**이미지 추가 방법:**
1. PNG 파일을 `assets/images/loading_cat.png` 경로에 저장
2. [loading_screen.dart](lib/widgets/loading_screen.dart:17) 파일에서 주석 해제:
   ```dart
   // 이 부분 주석 해제
   Image.asset(
     'assets/images/loading_cat.png',
     width: 200,
     height: 200,
   ),

   // 그리고 아래 Container 코드 삭제
   Container(...)
   ```

---

### 2. 로딩 유틸리티 (`loading_utils.dart`)

백엔드 요청 시 자동으로 로딩 화면을 관리하는 유틸리티입니다.

#### 2-1. `LoadingUtils.runWithLoading()` 사용법

**자동 로딩 표시:**
```dart
// 500ms 이상 걸리면 자동으로 로딩 화면 표시
final result = await LoadingUtils.runWithLoading(
  context,
  () => fetchDataFromBackend(),
);
```

**커스텀 임계값 설정:**
```dart
// 1000ms 이상 걸리면 로딩 화면 표시
final result = await LoadingUtils.runWithLoading(
  context,
  () => fetchDataFromBackend(),
  threshold: 1000,  // 1초
);
```

#### 2-2. `LoadingFutureBuilder` 사용법

**FutureBuilder 대신 사용:**
```dart
LoadingFutureBuilder<String>(
  future: () => fetchDataFromBackend(),
  builder: (context, data) {
    return Text(data);
  },
  errorBuilder: (context, error) {
    return Text('오류: $error');
  },
)
```

---

## 실행 방법

### 1. 의존성 설치
```bash
cd epi_care_app
flutter pub get
```

### 2. 앱 실행
```bash
flutter run
```

### 3. 테스트 버튼 설명
- **빠른 요청 (300ms)**: 응답이 빠르므로 로딩 화면이 표시되지 않음
- **느린 요청 (2000ms)**: 500ms 이상 걸려서 로딩 화면이 표시됨
- **FutureBuilder 방식**: 새 화면으로 이동하여 LoadingFutureBuilder 테스트

---

## PNG 이미지 추가하는 방법

### 1. 이미지 파일 저장
```
epi_care_app/assets/images/your_image.png
```

### 2. 코드에서 사용
```dart
Image.asset(
  'assets/images/your_image.png',
  width: 200,
  height: 200,
)
```

### 주의사항
- 이미지는 이미 `pubspec.yaml`에 등록되어 있습니다
- `assets/images/` 폴더에 저장하면 자동으로 인식됩니다
- PNG, JPG, GIF 등 모든 이미지 형식 사용 가능

---

## 백엔드 연동 준비

현재는 Mock 데이터를 사용하고 있습니다.

### Mock 함수 예시 ([main.dart](lib/main.dart:28))
```dart
Future<String> _fetchDataFromBackend({int delay = 2000}) async {
  await Future.delayed(Duration(milliseconds: delay));
  return '데이터 로드 완료!';
}
```

### 백엔드 연동 시 수정 방법

**나중에 Kotlin 백엔드 파일을 받으면:**

1. HTTP 패키지 추가 (`pubspec.yaml`):
   ```yaml
   dependencies:
     http: ^1.1.0
   ```

2. Mock 함수를 실제 API 호출로 교체:
   ```dart
   Future<String> _fetchDataFromBackend() async {
     final response = await http.get(Uri.parse('YOUR_API_URL'));
     return response.body;
   }
   ```

3. 로딩 유틸리티는 그대로 사용 가능:
   ```dart
   final result = await LoadingUtils.runWithLoading(
     context,
     () => _fetchDataFromBackend(),  // 실제 API 호출
   );
   ```

---

## 다음 단계

1. **로딩 화면 이미지 추가**
   - 고양이 캐릭터 PNG 파일을 `assets/images/loading_cat.png`에 저장
   - [loading_screen.dart](lib/widgets/loading_screen.dart:17)에서 주석 해제

2. **새로운 기능 추가**
   - 기능별로 위젯을 `lib/widgets/` 폴더에 추가
   - 공통 유틸리티는 `lib/utils/` 폴더에 추가

3. **백엔드 연동**
   - Kotlin 백엔드 파일을 받으면 연동
   - 현재 Mock 함수를 실제 API 호출로 교체

---

## 파일 경로 참고

- **로딩 화면**: [lib/widgets/loading_screen.dart](lib/widgets/loading_screen.dart)
- **로딩 유틸리티**: [lib/utils/loading_utils.dart](lib/utils/loading_utils.dart)
- **메인 앱**: [lib/main.dart](lib/main.dart)
- **이미지 폴더**: `assets/images/`
- **프로젝트 설정**: [pubspec.yaml](pubspec.yaml)
