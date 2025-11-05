import 'nutrition_info.dart';

/// 커뮤니티 카테고리 (식단 분류)
enum CommunityCategory {
  korean('한식', '한국 전통 음식 및 반찬'),
  chinese('중식', '중국 요리'),
  western('양식', '서양 요리'),
  japanese('일식', '일본 요리'),
  other('기타', '기타 음식');

  final String displayName;
  final String description;

  const CommunityCategory(this.displayName, this.description);
}

/// 커뮤니티 게시글 모델
/// 케톤 식이 레시피 및 팁 공유
class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String content;
  final CommunityCategory category;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final NutritionInfo? nutrition; // 영양 성분 정보

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.nutrition,
  });

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'content': content,
      'category': category.name,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
    };
  }

  /// JSON에서 객체 생성
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: CommunityCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => CommunityCategory.other,
      ),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
    );
  }
}
