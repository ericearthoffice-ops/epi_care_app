# 백엔드 연동 체크리스트

> 전체 코드 검토를 통해 파악한 백엔드 API 연동이 필요한 모든 항목

---

## 1. 갤럭시 워치 헬스 데이터 및 발작 예측

### 1.1 헬스 데이터 전송 API
**파일**: `lib/services/seizure_prediction_service.dart`

- **엔드포인트**: `POST /api/health-data`
- **위치**: 74-90번 줄
- **현재 상태**: URL placeholder 사용 중 (`https://your-backend-api.com`)
- **필요 작업**:
  - [ ] 실제 백엔드 서버 URL 설정 (12번 줄)
  - [ ] 인증 토큰 헤더 추가 (79번 줄)
  - [ ] 백엔드 응답 형식 검증
- **전송 데이터**:
  ```json
  {
    "metadata": {
      "batchSize": 10,
      "trackers": ["heart_rate", "spo2", "bia", ...],
      "window": {"start": "2025-11-07T...", "end": "2025-11-07T..."},
      "sentAt": "2025-11-07T..."
    },
    "data": [
      {
        "type": "heart_rate",
        "timestamp": "2025-11-07T...",
        "value": 72.0,
        "unit": "bpm",
        "status": 0,
        "metrics": {...}
      },
      ...
    ]
  }
  ```
- **기대 응답**:
  ```json
  {
    "status": "success",
    "predictionProbability": 75.5
  }
  ```

### 1.2 발작 예측 요청 API
**파일**: `lib/services/seizure_prediction_service.dart`

- **엔드포인트**: `GET /api/seizure-prediction`
- **위치**: 114-138번 줄
- **필요 작업**:
  - [ ] 인증 토큰 헤더 추가 (121번 줄)
- **기대 응답**:
  ```json
  {
    "predictionProbability": 75.5,
    "timestamp": "2025-11-07T...",
    "model_version": "v1.2.3"
  }
  ```

---

## 2. 발작 예측 및 기록 관리

### 2.1 발작 예측 데이터 조회 API
**파일**: `lib/utils/backend_service.dart`

- **엔드포인트**: `GET /seizure-prediction`
- **위치**: 14-33번 줄
- **현재 상태**: Mock 데이터 사용 중
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] SeizurePredictionData 모델 응답 파싱

### 2.2 발작 발생 확인 전송 API
**파일**: `lib/utils/backend_service.dart`

- **엔드포인트**: `POST /seizure-occurred`
- **위치**: 40-67번 줄
- **현재 상태**: Mock 구현
- **필요 작업**:
  - [ ] 실제 HTTP POST 요청 구현
- **전송 데이터**:
  ```json
  {
    "timestamp": "2025-11-07T...",
    "predictionRate": 75.5
  }
  ```

### 2.3 발작 기록 조회 API
**파일**: `lib/utils/backend_service.dart`

- **엔드포인트**: `GET /seizure-records`
- **위치**: 74-94번 줄
- **현재 상태**: Mock 데이터 반환
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] SeizureRecord 리스트 파싱
- **기대 응답**:
  ```json
  [
    {
      "id": "1",
      "date": "2025-11-07T...",
      "duration": 120,
      "severity": "중증",
      "triggers": ["수면부족", "스트레스"],
      "notes": "..."
    },
    ...
  ]
  ```

### 2.4 월별 발작 통계 API
**파일**: `lib/utils/backend_service.dart`

- **엔드포인트**: `GET /seizure-stats/{year}`
- **위치**: 101-121번 줄
- **현재 상태**: Mock 데이터 반환
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] 연도별 월별 통계 파싱

### 2.5 예측 피드백 전송 API (머신러닝 학습용)
**파일**: `lib/utils/backend_service.dart`

- **엔드포인트**: `POST /prediction-feedback`
- **위치**: 130-167번 줄
- **현재 상태**: Mock 구현
- **필요 작업**:
  - [ ] 실제 HTTP POST 요청 구현
  - [ ] 머신러닝 모델 재학습 트리거 확인
- **전송 데이터**:
  ```json
  {
    "timestamp": "2025-11-07T...",
    "predictionRate": 75.5,
    "actualSeizureOccurred": true,
    "additionalData": {
      "heart_rate": 85,
      "spo2": 97,
      ...
    }
  }
  ```

---

## 3. 커뮤니티 및 레시피 관리

### 3.1 커뮤니티 게시글 목록 조회 API
**파일**: `lib/widgets/community_list_screen.dart`

- **엔드포인트**: `GET /community/posts`
- **위치**: 75-84번 줄
- **현재 상태**: Mock 데이터 생성 중
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] 카테고리 필터링 파라미터 추가
  - [ ] 정렬 옵션 파라미터 추가 (인기순, 최신순, 댓글순)
- **쿼리 파라미터**:
  - `category`: korean, western, chinese, japanese, snack, drink
  - `sort`: popular, latest, comments, saved
  - `page`, `limit`
- **기대 응답**:
  ```json
  {
    "posts": [
      {
        "id": "1",
        "userId": "user001",
        "userName": "김민지",
        "title": "케토 야채볶음 만드는 법",
        "content": "...",
        "category": "korean",
        "imageUrls": ["..."],
        "createdAt": "2025-11-07T...",
        "likeCount": 45,
        "commentCount": 12,
        "saveCount": 8,
        "nutrition": {
          "calories": 320,
          "fat": 28,
          "protein": 12,
          "carbs": 5
        }
      },
      ...
    ],
    "totalCount": 150,
    "page": 1
  }
  ```

### 3.2 게시글 작성 API
**파일**: `lib/widgets/community_write_screen.dart`

- **엔드포인트**: `POST /community/posts`
- **현재 상태**: Mock 구현
- **필요 작업**:
  - [ ] 실제 HTTP POST 요청 구현
  - [ ] 이미지 업로드 처리 (multipart/form-data)
  - [ ] 영양성분 정보 포함
- **전송 데이터**: FormData로 이미지 + JSON

### 3.3 게시글 상세 조회 API
**파일**: `lib/widgets/community_detail_screen.dart`

- **엔드포인트**: `GET /community/posts/{postId}`
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] 댓글 목록 포함

### 3.4 좋아요/저장 API
**파일**: `lib/widgets/community_detail_screen.dart`

- **엔드포인트**:
  - `POST /community/posts/{postId}/like`
  - `POST /community/posts/{postId}/save`
- **필요 작업**:
  - [ ] 좋아요 토글 구현
  - [ ] 저장 토글 구현

### 3.5 댓글 API
**파일**: `lib/widgets/community_detail_screen.dart`

- **엔드포인트**:
  - `GET /community/posts/{postId}/comments`
  - `POST /community/posts/{postId}/comments`
- **필요 작업**:
  - [ ] 댓글 목록 조회 구현
  - [ ] 댓글 작성 구현

### 3.6 추천 레시피 API
**파일**: `lib/widgets/recommended_recipes_screen.dart`

- **엔드포인트**: `GET /community/recommended`
- **필요 작업**:
  - [ ] 추천 알고리즘 기반 레시피 조회
  - [ ] 사용자 선호도 기반 필터링

---

## 4. Q&A 관리

### 4.1 Q&A 목록 조회 API
**파일**: `lib/widgets/qna_list_screen.dart`

- **엔드포인트**: `GET /qna/posts`
- **위치**: 35-45번 줄
- **현재 상태**: Mock 데이터 생성 중
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] 카테고리 필터링 (medication, diet, seizure, other)
  - [ ] 전문가 타입 필터링
- **기대 응답**:
  ```json
  {
    "posts": [
      {
        "id": "1",
        "userId": "user001",
        "userName": "김민지",
        "title": "레베티라세탐을 늦게 먹으면...",
        "content": "...",
        "category": "medication",
        "expertType": "pharmacist",
        "isPrivate": false,
        "createdAt": "2025-11-07T...",
        "viewCount": 24,
        "answerCount": 2,
        "hasAcceptedAnswer": true
      },
      ...
    ]
  }
  ```

### 4.2 Q&A 작성 API
**파일**: `lib/widgets/qna_write_screen.dart`

- **엔드포인트**: `POST /qna/posts`
- **필요 작업**:
  - [ ] 실제 HTTP POST 요청 구현
  - [ ] 비공개 질문 옵션 처리

### 4.3 답변 작성 API
**위치**: Q&A 상세 화면 (예상)

- **엔드포인트**: `POST /qna/posts/{postId}/answers`
- **필요 작업**:
  - [ ] 전문가 답변 작성 API 구현
  - [ ] 답변 채택 API 구현

---

## 5. 전문가 칼럼 관리

### 5.1 칼럼 목록 조회 API
**파일**: `lib/widgets/column_list_screen.dart`

- **엔드포인트**: `GET /columns`
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] 카테고리 필터링

### 5.2 칼럼 상세 조회 API
**파일**: `lib/widgets/column_detail_screen.dart`

- **엔드포인트**: `GET /columns/{columnId}`
- **필요 작업**:
  - [ ] 실제 HTTP GET 요청 구현
  - [ ] 조회수 증가 처리

---

## 6. 식단 관리

### 6.1 식단 추가 API
**파일**: `lib/services/diet_service.dart`

- **엔드포인트**: `POST /diet/entries`
- **위치**: 16-37번 줄
- **현재 상태**: 메모리 기반 저장소 사용 중
- **필요 작업**:
  - [ ] 실제 HTTP POST 요청 구현
  - [ ] 사용자별 식단 저장
- **전송 데이터**:
  ```json
  {
    "date": "2025-11-07",
    "mealTime": "breakfast",
    "recipeId": "recipe123",
    "nutrition": {
      "calories": 320,
      "fat": 28,
      "protein": 12,
      "carbs": 5
    }
  }
  ```

### 6.2 식단 조회 API
**파일**: `lib/services/diet_service.dart`

- **엔드포인트**:
  - `GET /diet/entries?date={date}`
  - `GET /diet/entries?date={date}&mealTime={mealTime}`
- **위치**: 40-49번 줄
- **필요 작업**:
  - [ ] 날짜별 식단 조회 구현
  - [ ] 시간대별 식단 조회 구현

### 6.3 식단 삭제 API
**파일**: `lib/services/diet_service.dart`

- **엔드포인트**: `DELETE /diet/entries/{entryId}`
- **위치**: 52-59번 줄
- **필요 작업**:
  - [ ] 실제 HTTP DELETE 요청 구현

---

## 7. 약물 관리

### 7.1 약물 복용 기록 저장 API
**파일**: `lib/services/medication_notification_service.dart`

- **엔드포인트**: `POST /medication/logs`
- **필요 작업**:
  - [ ] 복용 시간 기록 API 구현
  - [ ] 복용 여부 (taken/skipped) 기록

### 7.2 약물 복용 기록 조회 API
**파일**: `lib/services/medical_report_service.dart`

- **엔드포인트**: `GET /medication/logs?startDate={startDate}&endDate={endDate}`
- **위치**: 79-106번 줄
- **현재 상태**: 임시 데이터 생성 중 (90% 순응도)
- **필요 작업**:
  - [ ] 실제 복용 기록 데이터 조회 구현
  - [ ] 순응도 계산 로직 백엔드에서 처리
- **기대 응답**:
  ```json
  {
    "logs": [
      {
        "date": "2025-11-07",
        "medicationId": "med001",
        "medicationName": "레비티라세탐",
        "scheduledTime": "08:00",
        "takenTime": "08:05",
        "taken": true
      },
      ...
    ],
    "adherenceRate": 89.5,
    "totalDays": 30,
    "takenDays": 27,
    "missedDays": 3
  }
  ```

### 7.3 약물 목록 조회 API
**파일**: `lib/widgets/medication_list_screen.dart`

- **엔드포인트**: `GET /medications`
- **필요 작업**:
  - [ ] 사용자 등록 약물 목록 조회
  - [ ] 약물별 복용 스케줄 포함

### 7.4 약물 등록/수정/삭제 API
**파일**: `lib/widgets/medication_setup_screen.dart`

- **엔드포인트**:
  - `POST /medications`
  - `PUT /medications/{medicationId}`
  - `DELETE /medications/{medicationId}`
- **필요 작업**:
  - [ ] 약물 등록 API 구현
  - [ ] 약물 정보 수정 API 구현
  - [ ] 약물 삭제 API 구현

---

## 8. 의료 보고서

### 8.1 의료 보고서 생성 API
**파일**: `lib/services/medical_report_service.dart`

- **엔드포인트**: `GET /reports/generate?startDate={startDate}&endDate={endDate}`
- **위치**: 12-32번 줄
- **현재 상태**: 로컬에서 데이터 수집 및 생성
- **필요 작업**:
  - [ ] 백엔드에서 통합 리포트 생성 API 구현
  - [ ] 발작 통계, 약물 순응도, 식이 요약 통합
- **기대 응답**:
  ```json
  {
    "startDate": "2025-10-01",
    "endDate": "2025-10-31",
    "seizureStats": {
      "totalSeizures": 5,
      "averagePerWeek": 1.2,
      "averageDuration": 120,
      "dailySeizures": {...}
    },
    "medicationAdherence": {
      "adherenceRate": 89.5,
      "takenDays": 27,
      "missedDays": 3
    },
    "dietSummary": {
      "averageKetoneRatio": 3.5,
      "completionRate": 85,
      "nutritionAverages": {...}
    }
  }
  ```

---

## 9. 사용자 인증 및 관리

### 9.1 회원가입 API
**위치**: 프로필/로그인 화면 (예상)

- **엔드포인트**: `POST /auth/register`
- **필요 작업**:
  - [ ] 회원가입 API 구현
  - [ ] 이메일 인증 처리
- **전송 데이터**:
  ```json
  {
    "email": "user@example.com",
    "password": "...",
    "name": "김민지",
    "birthDate": "2010-05-15",
    "phoneNumber": "010-1234-5678"
  }
  ```

### 9.2 로그인 API
**위치**: 로그인 화면 (예상)

- **엔드포인트**: `POST /auth/login`
- **필요 작업**:
  - [ ] 로그인 API 구현
  - [ ] JWT 토큰 발급 및 저장
- **전송 데이터**:
  ```json
  {
    "email": "user@example.com",
    "password": "..."
  }
  ```
- **기대 응답**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "user001",
      "name": "김민지",
      "email": "user@example.com"
    }
  }
  ```

### 9.3 사용자 정보 조회 API
**파일**: `lib/widgets/profile_screen.dart`

- **엔드포인트**: `GET /users/me`
- **필요 작업**:
  - [ ] 현재 사용자 정보 조회 구현
  - [ ] 토큰 기반 인증

### 9.4 토큰 갱신 API
**위치**: 인증 서비스 (신규 생성 필요)

- **엔드포인트**: `POST /auth/refresh`
- **필요 작업**:
  - [ ] 리프레시 토큰으로 액세스 토큰 재발급
  - [ ] 자동 갱신 로직 구현

---

## 10. 인증 토큰 관리

### 10.1 AuthService 생성 필요
**위치**: `lib/services/auth_service.dart` (신규 생성)

- **필요 기능**:
  - [ ] 토큰 저장 (SecureStorage 사용)
  - [ ] 토큰 조회 메서드
  - [ ] 토큰 갱신 로직
  - [ ] 로그아웃 시 토큰 삭제
  - [ ] HTTP 요청 시 자동 헤더 추가

### 10.2 기존 서비스에 토큰 추가
**필요 파일**:
- `lib/services/seizure_prediction_service.dart`
- `lib/utils/backend_service.dart`
- 기타 모든 HTTP 요청 파일

**수정 예시**:
```dart
import 'auth_service.dart';

headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ${AuthService.getToken()}',
},
```

---

## 11. 기타 설정

### 11.1 HTTP 패키지 추가
**파일**: `pubspec.yaml`

- **현재 상태**: `http: ^1.2.0` 이미 추가됨 ✅
- **추가 패키지 고려**:
  - [ ] `flutter_secure_storage`: 토큰 암호화 저장
  - [ ] `dio`: 고급 HTTP 클라이언트 (interceptor 지원)

### 11.2 환경 변수 설정
**위치**: 신규 파일 생성

- **필요 작업**:
  - [ ] `lib/config/api_config.dart` 생성
  - [ ] 개발/프로덕션 환경별 URL 분리
  - [ ] API 버전 관리

**예시**:
```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.example.com',
  );

  static const String healthDataEndpoint = '/api/v1/health-data';
  static const String seizurePredictionEndpoint = '/api/v1/seizure-prediction';
  // ...
}
```

---

## 12. 우선순위 정리

### 🔴 최우선 (갤럭시 워치 기능 동작을 위해 필수)
1. 갤럭시 워치 헬스 데이터 전송 API (1.1)
2. 발작 예측 요청 API (1.2)
3. 인증 토큰 관리 시스템 (10.1, 10.2)
4. 백엔드 서버 URL 설정

### 🟡 중요 (핵심 기능)
5. 발작 기록 조회 API (2.3)
6. 발작 발생 확인 전송 API (2.2)
7. 예측 피드백 전송 API (2.5)
8. 약물 복용 기록 API (7.1, 7.2)
9. 식단 관리 API (6.1, 6.2, 6.3)

### 🟢 보통 (커뮤니티/부가 기능)
10. 커뮤니티 게시글 관련 API (3.1-3.6)
11. Q&A 관련 API (4.1-4.3)
12. 전문가 칼럼 API (5.1, 5.2)
13. 의료 보고서 생성 API (8.1)

### 🔵 낮음 (향후 개선)
14. 월별 발작 통계 API (2.4)
15. 추천 레시피 API (3.6)

---

## 13. 작업 순서 제안

### Phase 1: 인프라 구축
1. AuthService 생성 및 토큰 관리 시스템 구현
2. ApiConfig 생성 및 환경 변수 설정
3. HTTP 공통 인터셉터 구현 (에러 핸들링, 토큰 자동 추가)

### Phase 2: 갤럭시 워치 연동
4. 헬스 데이터 전송 API 연동
5. 발작 예측 API 연동
6. 실제 디바이스 테스트

### Phase 3: 발작 관리 기능
7. 발작 기록/통계 API 연동
8. 예측 피드백 API 연동

### Phase 4: 의료 관리 기능
9. 약물 관리 API 연동
10. 식단 관리 API 연동
11. 의료 보고서 생성 API 연동

### Phase 5: 커뮤니티 기능
12. 커뮤니티/Q&A/칼럼 API 연동

---

## 14. 백엔드 팀과 협의 필요 사항

### API 명세 확인
- [ ] 모든 엔드포인트 URL 확정
- [ ] 요청/응답 데이터 구조 확정
- [ ] 에러 코드 및 메시지 형식 확정

### 인증 방식 확인
- [ ] JWT 토큰 사용 여부
- [ ] 토큰 만료 시간 (access token, refresh token)
- [ ] 토큰 갱신 정책

### 데이터 동기화 정책
- [ ] 헬스 데이터 전송 주기 (현재 10초)
- [ ] 데이터 배치 크기 제한
- [ ] 오프라인 시 데이터 처리 방법

### 성능 요구사항
- [ ] API 응답 시간 목표
- [ ] Rate limiting 정책
- [ ] 페이지네이션 설정 (기본 limit 값)

---

## 15. 테스트 계획

### API 테스트
- [ ] Postman/Insomnia 컬렉션 생성
- [ ] 각 엔드포인트별 성공/실패 케이스 테스트
- [ ] 토큰 인증 테스트

### 통합 테스트
- [ ] 갤럭시 워치 → 앱 → 백엔드 전체 플로우 테스트
- [ ] 오프라인 → 온라인 전환 시 데이터 동기화 테스트
- [ ] 네트워크 에러 처리 테스트

---

**생성일**: 2025-11-07
**마지막 업데이트**: 2025-11-07
**버전**: 1.0
