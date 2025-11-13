import '../models/qna_post.dart';

/// Simple in-memory service that mimics a backend for Q&A posts.
class QnaService {
  static bool useLocalMode = true;
  static final List<QnaPost> _localPosts = [];
  static int _localIdCounter = 0;

  static bool get _isSeeded => _localPosts.isNotEmpty;

  static List<QnaPost> get localPosts => List.unmodifiable(_localPosts);

  /// Ensures the local store has default mock data.
  static void seedDefaultData() {
    if (!useLocalMode || _isSeeded) return;
    _localPosts.addAll(_defaultSeedPosts());
    _localIdCounter = _localPosts.length;
  }

  static Future<List<QnaPost>> fetchPosts({QnaCategory? category}) async {
    if (!useLocalMode) {
      throw UnimplementedError('Remote QnaService is not implemented.');
    }
    seedDefaultData();
    var posts = List<QnaPost>.from(_localPosts);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (category != null) {
      posts = posts.where((post) => post.category == category).toList();
    }
    return posts;
  }

  static Future<List<QnaPost>> fetchPopular({int limit = 3}) async {
    final posts = await fetchPosts();
    posts.sort((a, b) {
      final scoreA =
          a.viewCount + (a.answerCount * 3) + (a.hasAcceptedAnswer ? 10 : 0);
      final scoreB =
          b.viewCount + (b.answerCount * 3) + (b.hasAcceptedAnswer ? 10 : 0);
      return scoreB.compareTo(scoreA);
    });
    return posts.take(limit).toList();
  }

  static Future<QnaPost> createPost({
    required String title,
    required String content,
    required QnaCategory category,
    required ExpertType expertType,
    required bool isPrivate,
    List<String> imagePaths = const [],
    String? userName,
  }) async {
    if (!useLocalMode) {
      throw UnimplementedError('Remote QnaService is not implemented.');
    }
    seedDefaultData();

    final now = DateTime.now();
    final post = QnaPost(
      id: 'local_${++_localIdCounter}',
      userId: 'guardian_local',
      userName: userName ?? '보호자',
      title: title,
      content: content,
      category: category,
      expertType: expertType,
      imageUrls: imagePaths,
      isPrivate: isPrivate,
      createdAt: now,
      viewCount: 0,
      answerCount: 0,
      hasAcceptedAnswer: false,
      answers: const [],
    );

    _localPosts.insert(0, post);
    return post;
  }

  static List<QnaPost> _defaultSeedPosts() {
    final now = DateTime.now();
    return [
      QnaPost(
        id: 'q1',
        userId: 'mom001',
        userName: '지윤맘',
        title: '새벽 약 복용 시간을 넘겼는데 지금 먹여도 될까요?',
        content:
            '기모리진을 새벽 3시에 먹이는데 아이가 오늘은 뒤척이다가 5시에 일어났어요. 지금 먹이고 다음 복용 시간을 조금씩 조정해도 되는지 궁금합니다.',
        category: QnaCategory.medication,
        expertType: ExpertType.pharmacist,
        isPrivate: false,
        createdAt: now.subtract(const Duration(hours: 4)),
        viewCount: 72,
        answerCount: 3,
        hasAcceptedAnswer: true,
        answers: const [],
      ),
      QnaPost(
        id: 'q2',
        userId: 'dad003',
        userName: '하준아빠',
        title: '학교에서 발작이 시작되면 담임선생님께 무엇을 부탁해야 하나요?',
        content:
            '초등학교 2학년이고 체육 시간에 갑자기 발작한 적이 있습니다. 담임선생님께 어떤 체크리스트를 드리면 도움이 될지, 119는 언제 불러야 하는지 알고 싶어요.',
        category: QnaCategory.seizure,
        expertType: ExpertType.pediatricNeurologist,
        isPrivate: false,
        createdAt: now.subtract(const Duration(hours: 9)),
        viewCount: 131,
        answerCount: 4,
        hasAcceptedAnswer: true,
        answers: const [],
      ),
      QnaPost(
        id: 'q3',
        userId: 'mom007',
        userName: '민솔보호자',
        title: '케토식 하는 중인데 급식 반찬을 조금 맛봐도 괜찮나요?',
        content:
            '3:1 비율로 식단을 유지 중입니다. 아이가 급식 반찬을 너무 먹고 싶어 하는데, 일정 주기로 소량 허용해도 되는지, 가능하다면 비교적 안전한 반찬이 있을지 궁금합니다.',
        category: QnaCategory.diet,
        expertType: ExpertType.dietitian,
        isPrivate: false,
        createdAt: now.subtract(const Duration(hours: 20)),
        viewCount: 56,
        answerCount: 2,
        hasAcceptedAnswer: false,
        answers: const [],
      ),
      QnaPost(
        id: 'q4',
        userId: 'mom010',
        userName: '소담이엄마',
        title: '발작이 멈춘 뒤 깊이 잘 때 꼭 깨워야 할까요?',
        content:
            '발작이 끝나면 아이가 1시간 이상 깊게 잠들어 버리는데, 바로 깨우지 않고 호흡과 맥박만 체크해도 되는지 모르겠습니다. 지켜보는 주기와 기준이 궁금합니다.',
        category: QnaCategory.lifestyle,
        expertType: ExpertType.pediatrician,
        isPrivate: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        viewCount: 84,
        answerCount: 1,
        hasAcceptedAnswer: false,
        answers: const [],
      ),
      QnaPost(
        id: 'q5',
        userId: 'guardian011',
        userName: '민재보호자',
        title: 'EEG 검사는 얼마나 자주 받아야 하나요?',
        content:
            '6개월 전에 비정상 파형이 나왔는데 최근에는 발작 빈도가 줄었습니다. 이런 경우에도 1년에 한 번씩 검사를 받는 게 맞는지 다른 보호자분들 경험이 궁금합니다.',
        category: QnaCategory.medical,
        expertType: ExpertType.pediatricNeurologist,
        isPrivate: true,
        createdAt: now.subtract(const Duration(days: 2)),
        viewCount: 33,
        answerCount: 1,
        hasAcceptedAnswer: false,
        answers: const [],
      ),
      QnaPost(
        id: 'q6',
        userId: 'mom014',
        userName: '하은맘',
        title: '약을 먹고 30분 뒤 바로 뛰어놀아도 괜찮나요?',
        content:
            '약 먹은 뒤 집중력이 급격히 떨어지는 것 같아 복용 직후에는 조용한 활동으로 유도해야 할지 고민입니다. 집에서 실천하는 안전한 놀이 방법이 있으면 알려주세요.',
        category: QnaCategory.other,
        expertType: ExpertType.any,
        isPrivate: false,
        createdAt: now.subtract(const Duration(days: 3)),
        viewCount: 41,
        answerCount: 2,
        hasAcceptedAnswer: true,
        answers: const [],
      ),
    ];
  }
}
