import '../models/column_post.dart';
import '../models/qna_post.dart';

/// Simple in-memory service for expert columns.
class ColumnService {
  static bool useLocalMode = true;
  static final List<ColumnPost> _localPosts = [];
  static int _localIdCounter = 0;

  static bool get _isSeeded => _localPosts.isNotEmpty;

  static List<ColumnPost> get localPosts => List.unmodifiable(_localPosts);

  static void seedDefaultData() {
    if (!useLocalMode || _isSeeded) return;
    _localPosts.addAll(_defaultSeedPosts());
    _localIdCounter = _localPosts.length;
  }

  static Future<List<ColumnPost>> fetchPosts({
    ColumnCategory? category,
  }) async {
    if (!useLocalMode) {
      throw UnimplementedError('Remote ColumnService is not implemented.');
    }
    seedDefaultData();
    var posts = List<ColumnPost>.from(_localPosts);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (category != null) {
      posts = posts.where((post) => post.category == category).toList();
    }
    return posts;
  }

  static Future<List<ColumnPost>> fetchFeatured({int limit = 3}) async {
    final posts = await fetchPosts();
    final featured = posts.where((post) => post.isFeatured).toList()
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return featured.take(limit).toList();
  }

  static List<ColumnPost> _defaultSeedPosts() {
    final now = DateTime.now();
    return [
      ColumnPost(
        id: 'c1',
        authorId: 'neuro001',
        authorName: '김세린 교수',
        authorType: ExpertType.pediatricNeurologist,
        authorTitle: '서울아동신경센터',
        title: '발작이 시작되었을 때 부모가 기억해야 할 5단계',
        summary:
            '발작 초기에 부모가 침착하게 대응할 수 있도록 다섯 단계 대처법과 주의사항을 정리했습니다.',
        content: '''
# 발작 대응 5단계

1. **호흡 확인**: 아이가 숨을 고르게 쉬는지 빠르게 확인합니다.
2. **주변 정리**: 머리가 부딪히지 않도록 방석이나 수건을 받칩니다.
3. **측면 자세**: 침을 삼키지 못할 수 있으므로 옆으로 눕혀 기도를 확보합니다.
4. **시간 기록**: 5분 이상 지속되면 119에 연락합니다.
5. **회복 관찰**: 발작 후 의식이 돌아오는 시간을 기록해 의료진과 공유합니다.
        ''',
        category: ColumnCategory.seizureInfo,
        tags: ['응급대응', '부모교육'],
        createdAt: now.subtract(const Duration(days: 2)),
        viewCount: 1280,
        likeCount: 92,
        bookmarkCount: 210,
        isFeatured: true,
      ),
      ColumnPost(
        id: 'c2',
        authorId: 'pharm002',
        authorName: '이서준 약사',
        authorType: ExpertType.pharmacist,
        authorTitle: '마음누리 약국',
        title: '항경련제 복용 시간을 놓쳤을 때의 체크리스트',
        summary:
            '복용 시간을 놓쳤을 때 약물 유형별로 어떻게 대응하면 되는지 정리했습니다.',
        content: '''
### 복용 시간 별 대처
* **지연 2시간 이내**: 바로 복용하고 다음 일정은 유지합니다.
* **다음 복용까지 4시간 미만**: 건너뛰고 다음 일정에 맞춥니다.
* **부작용 관찰**: 졸림이나 울렁거림이 지속되면 의료진에 바로 연락합니다.
        ''',
        category: ColumnCategory.medicationGuide,
        tags: ['복약', '부모팁'],
        createdAt: now.subtract(const Duration(days: 5)),
        viewCount: 860,
        likeCount: 64,
        bookmarkCount: 144,
        isFeatured: true,
      ),
      ColumnPost(
        id: 'c3',
        authorId: 'diet003',
        authorName: '최은별 영양사',
        authorType: ExpertType.dietitian,
        authorTitle: '새빛케토클리닉',
        title: '케토식 중 즐길 수 있는 주간 간식 플랜',
        summary:
            '학교 급식과 병행할 수 있는 3:1 비율 간식 아이디어 3가지를 제안합니다.',
        content: '''
- 치즈칩 + 코코넛 오일 5g
- 아보카도 초코 무스 (스테비아 사용)
- 코코넛 버터와 크림치즈볼
각 간식마다 **탄단지 비율**을 지켜 준비해주세요.
        ''',
        category: ColumnCategory.dietNutrition,
        tags: ['케토식', '간식', '식단'],
        createdAt: now.subtract(const Duration(days: 7)),
        viewCount: 540,
        likeCount: 48,
        bookmarkCount: 120,
        isFeatured: false,
      ),
      ColumnPost(
        id: 'c4',
        authorId: 'coach004',
        authorName: '박도연 치료사',
        authorType: ExpertType.pediatrician,
        authorTitle: '해든이 재활치료실',
        title: '체육 수업 전 담임선생님께 꼭 전달해야 할 세 가지',
        summary:
            '발작 경험이 있는 아이가 체육 수업에 참여할 때 필요한 체크리스트를 정리했습니다.',
        content: '''
1. **전조 증상 공유**: 아이가 주로 보이는 신호를 구체적으로 설명합니다.
2. **금지 동작 안내**: 머리를 거꾸로 드는 자세나 격한 회전 동작을 피하도록 요청합니다.
3. **연락 체계 준비**: 발작 시 바로 연락할 보호자/병원 정보를 카드로 전달합니다.
        ''',
        category: ColumnCategory.childcare,
        tags: ['학교생활', '체육', '안전'],
        createdAt: now.subtract(const Duration(days: 10)),
        viewCount: 610,
        likeCount: 37,
        bookmarkCount: 98,
        isFeatured: false,
      ),
      ColumnPost(
        id: 'c5',
        authorId: 'research005',
        authorName: '문하람 연구원',
        authorType: ExpertType.pediatricNeurologist,
        authorTitle: '빛샘의료 연구소',
        title: '2025년에 주목해야 할 소아 뇌전증 치료법',
        summary:
            '최근 학회에서 발표된 뇌전증 기반 치료와 웨어러블 모니터링 연구를 소개합니다.',
        content: '''
* **맞춤 약물 치료**: 유전자 분석을 통한 초기 약물 선택 연구가 확대되고 있습니다.
* **웨어러블 EEG**: 가정에서도 지표를 모니터링할 수 있는 경량 기기가 상용화 단계입니다.
* **AI 발작 예측**: 수면 패턴과 스트레스 지표를 결합한 모델이 실험 중입니다.
        ''',
        category: ColumnCategory.research,
        tags: ['연구', '기술'],
        createdAt: now.subtract(const Duration(days: 14)),
        viewCount: 420,
        likeCount: 29,
        bookmarkCount: 76,
        isFeatured: false,
      ),
      ColumnPost(
        id: 'c6',
        authorId: 'coach006',
        authorName: '박하은 상담가',
        authorType: ExpertType.psychologist,
        authorTitle: '마음결 심리센터',
        title: '발작 후 아이가 불안해할 때 위로가 되는 문장들',
        summary:
            '발작 후 불안을 호소하는 아이에게 보호자가 건넬 수 있는 문장을 정리했습니다.',
        content: '''
- "방금 상황이 무섭게 느껴졌을 거야. 나는 바로 옆에 있었어."
- "몸이 떨렸을 뿐이지 네 잘못이 아니라는 걸 알아."
- "비슷한 느낌이 오면 신호해 줄래? 바로 도와줄게."
        ''',
        category: ColumnCategory.lifestyle,
        tags: ['심리지원', '대화법'],
        createdAt: now.subtract(const Duration(days: 18)),
        viewCount: 380,
        likeCount: 52,
        bookmarkCount: 133,
        isFeatured: true,
      ),
    ];
  }
}
