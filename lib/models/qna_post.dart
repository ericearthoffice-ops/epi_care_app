/// Q&A 카테고리
enum QnaCategory {
  medication('복약 관리', '약 복용, 약물 부작용, 복약 일정 관련'),
  seizure('발작 관리', '발작 대처법, 증상, 예방 관련'),
  diet('식단 관리', '케토제닉 식단, 영양 관리 관련'),
  lifestyle('일상생활', '학교생활, 운동, 여가 활동 관련'),
  medical('의료 정보', '진단, 검사, 치료 관련'),
  other('기타', '기타 일반 질문');

  final String displayName;
  final String description;
  const QnaCategory(this.displayName, this.description);
}

/// 전문가 분야
enum ExpertType {
  pediatricNeurologist('소아 신경과 전문의'),
  pediatrician('소아청소년과 전문의'),
  pharmacist('약사'),
  dietitian('영양사'),
  psychologist('심리상담가'),
  any('분야 무관');

  final String displayName;
  const ExpertType(this.displayName);
}

/// Q&A 게시글
class QnaPost {
  final String id;
  final String userId; // 작성자 ID
  final String userName; // 작성자 이름
  final String title; // 질문 제목
  final String content; // 질문 내용
  final QnaCategory category; // 카테고리
  final ExpertType expertType; // 희망 전문가 분야
  final List<String> imageUrls; // 첨부 이미지 URL 목록
  final bool isPrivate; // 비공개 여부 (true: 본인과 전문가만 조회 가능)
  final DateTime createdAt; // 작성 일시
  final DateTime? updatedAt; // 수정 일시
  final int viewCount; // 조회수
  final int answerCount; // 답변 수
  final bool hasAcceptedAnswer; // 채택된 답변 존재 여부
  final List<QnaAnswer> answers; // 답변 목록

  QnaPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    required this.category,
    required this.expertType,
    this.imageUrls = const [],
    this.isPrivate = false,
    required this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.answerCount = 0,
    this.hasAcceptedAnswer = false,
    this.answers = const [],
  });

  /// JSON으로 변환 (백엔드 전송)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'content': content,
      'category': category.name,
      'expertType': expertType.name,
      'imageUrls': imageUrls,
      'isPrivate': isPrivate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'viewCount': viewCount,
      'answerCount': answerCount,
      'hasAcceptedAnswer': hasAcceptedAnswer,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }

  /// JSON에서 생성 (백엔드 수신)
  factory QnaPost.fromJson(Map<String, dynamic> json) {
    return QnaPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: QnaCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QnaCategory.other,
      ),
      expertType: ExpertType.values.firstWhere(
        (e) => e.name == json['expertType'],
        orElse: () => ExpertType.any,
      ),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPrivate: json['isPrivate'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
      answerCount: json['answerCount'] as int? ?? 0,
      hasAcceptedAnswer: json['hasAcceptedAnswer'] as bool? ?? false,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => QnaAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Q&A 답변
class QnaAnswer {
  final String id;
  final String qnaPostId; // 질문 게시글 ID
  final String expertId; // 전문가 ID
  final String expertName; // 전문가 이름
  final ExpertType expertType; // 전문가 분야
  final String content; // 답변 내용
  final DateTime createdAt; // 작성 일시
  final DateTime? updatedAt; // 수정 일시
  final bool isAccepted; // 질문자가 채택했는지 여부
  final int likeCount; // 좋아요 수

  QnaAnswer({
    required this.id,
    required this.qnaPostId,
    required this.expertId,
    required this.expertName,
    required this.expertType,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isAccepted = false,
    this.likeCount = 0,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qnaPostId': qnaPostId,
      'expertId': expertId,
      'expertName': expertName,
      'expertType': expertType.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isAccepted': isAccepted,
      'likeCount': likeCount,
    };
  }

  /// JSON에서 생성
  factory QnaAnswer.fromJson(Map<String, dynamic> json) {
    return QnaAnswer(
      id: json['id'] as String,
      qnaPostId: json['qnaPostId'] as String,
      expertId: json['expertId'] as String,
      expertName: json['expertName'] as String,
      expertType: ExpertType.values.firstWhere(
        (e) => e.name == json['expertType'],
        orElse: () => ExpertType.any,
      ),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isAccepted: json['isAccepted'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }
}
