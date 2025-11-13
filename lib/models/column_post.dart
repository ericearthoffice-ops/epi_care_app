import 'qna_post.dart'; // ExpertType을 재사용

/// 칼럼 카테고리
enum ColumnCategory {
  seizureInfo('발작 정보', '발작 종류, 증상, 대처법 등 전문가 정보'),
  medicationGuide('복약 가이드', '항경련제 복용과 부작용, 주의사항'),
  dietNutrition('식단·영양', '케토제닉 식단, 영양 관리 팁'),
  childcare('양육·교육', '학교생활, 재활, 부모 가이드'),
  research('최신 연구', '뇌전증 연구 동향, 새로운 치료'),
  lifestyle('생활 관리', '운동, 수면, 스트레스 관리'),
  success('치료 사례', '성공적인 치료 경험과 희망 사례');

  final String displayName;
  final String description;
  const ColumnCategory(this.displayName, this.description);
}

/// 전문가 칼럼 게시글
class ColumnPost {
  final String id;
  final String authorId; // 작성 전문가 ID
  final String authorName; // 작성자 이름
  final ExpertType authorType; // 전문가 분야
  final String authorTitle; // 직함 (예: 서울의료원 소아신경과 교수)
  final String title; // 칼럼 제목
  final String summary; // 요약 (2-3줄)
  final String content; // 본문 (마크다운 가능)
  final ColumnCategory category; // 카테고리
  final String thumbnailUrl; // 대표 이미지 URL
  final List<String> tags; // 태그 목록
  final DateTime createdAt; // 작성 일시
  final DateTime? updatedAt; // 수정 일시
  final int viewCount; // 조회수
  final int likeCount; // 좋아요
  final int bookmarkCount; // 북마크
  final bool isFeatured; // 추천 여부

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

  /// JSON으로 변환 (백엔드 전송)
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

  /// JSON에서 생성 (백엔드 수신)
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
