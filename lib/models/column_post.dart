import 'qna_post.dart'; // ExpertType 재사용

/// 칼럼 카테고리
enum ColumnCategory {
  seizureInfo('발작 정보', '발작의 종류, 증상, 대처법에 대한 전문 정보'),
  medicationGuide('복약 가이드', '항발작제 복용법, 부작용, 주의사항'),
  dietNutrition('식단과 영양', '케토제닉 식단, 영양 관리, 건강 레시피'),
  childcare('육아와 교육', '학교생활, 또래 관계, 부모 가이드'),
  research('최신 연구', '뇌전증 연구 동향, 새로운 치료법'),
  lifestyle('생활 관리', '운동, 수면, 스트레스 관리'),
  success('치료 사례', '성공적인 치료 경험, 희망의 이야기');

  final String displayName;
  final String description;
  const ColumnCategory(this.displayName, this.description);
}

/// 칼럼 게시글
/// 전문가가 작성한 의료 정보 칼럼
class ColumnPost {
  final String id;
  final String authorId; // 작성자(전문가) ID
  final String authorName; // 작성자 이름
  final ExpertType authorType; // 작성자 전문 분야
  final String authorTitle; // 작성자 직함 (예: "서울대병원 소아신경과 교수")
  final String title; // 칼럼 제목
  final String summary; // 칼럼 요약 (2-3줄)
  final String content; // 칼럼 본문 (마크다운 형식)
  final ColumnCategory category; // 카테고리
  final String thumbnailUrl; // 썸네일 이미지 URL
  final List<String> tags; // 태그 목록 (예: ["레베티라세탐", "복약지도"])
  final DateTime createdAt; // 작성일시
  final DateTime? updatedAt; // 수정일시
  final int viewCount; // 조회수
  final int likeCount; // 좋아요 수
  final int bookmarkCount; // 북마크 수
  final bool isFeatured; // 추천 칼럼 여부

  ColumnPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    required this.authorTitle,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.thumbnailUrl = '',
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.isFeatured = false,
  });

  /// JSON으로 변환 (백엔드 전송용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorType': authorType.name,
      'authorTitle': authorTitle,
      'title': title,
      'summary': summary,
      'content': content,
      'category': category.name,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'bookmarkCount': bookmarkCount,
      'isFeatured': isFeatured,
    };
  }

  /// JSON에서 생성 (백엔드 수신용)
  factory ColumnPost.fromJson(Map<String, dynamic> json) {
    return ColumnPost(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorType: ExpertType.values.firstWhere(
        (e) => e.name == json['authorType'],
        orElse: () => ExpertType.any,
      ),
      authorTitle: json['authorTitle'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      category: ColumnCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ColumnCategory.lifestyle,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      bookmarkCount: json['bookmarkCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}
