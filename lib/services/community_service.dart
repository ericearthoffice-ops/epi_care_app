import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../models/community_post.dart';

/// 커뮤니티 관련 API 서비스
class CommunityService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final String _communityEndpoint = AppConfig.communityPostsEndpoint;

  /// 커뮤니티 게시글 목록 조회
  ///
  /// [category]: 카테고리 필터 (null이면 전체)
  /// [sort]: 정렬 방식 (latest, popular 등)
  /// [page]: 페이지 번호 (기본값 1)
  /// [limit]: 페이지당 게시글 수 (기본값 20)
  static Future<List<CommunityPost>> fetchPosts({
    CommunityCategory? category,
    String sort = 'latest',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'sort': sort,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) {
        queryParams['category'] = category.serverValue;
      }

      final uri = Uri.parse('$_baseUrl$_communityEndpoint')
          .replace(queryParameters: queryParams);

      print('[CommunityService] Fetching posts: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // TODO: 인증 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10), // 타임아웃 10초로 단축
        onTimeout: () {
          throw TimeoutException('백엔드 서버 응답 시간 초과 (10초)');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final postsJson = data['posts'] as List<dynamic>?;

        if (postsJson == null) {
          print('[CommunityService] No posts field in response');
          return [];
        }

        final posts = postsJson
            .map((json) => CommunityPost.fromJson(json as Map<String, dynamic>))
            .toList();

        print('[CommunityService] Fetched ${posts.length} posts');
        return posts;
      } else {
        throw Exception(
          'Failed to fetch posts: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      print('[CommunityService] Timeout: $e');
      throw Exception('서버 응답 시간 초과. 네트워크 연결을 확인하거나 나중에 다시 시도해주세요.');
    } catch (e) {
      print('[CommunityService] Error fetching posts: $e');
      rethrow;
    }
  }

  /// 커뮤니티 게시글 작성 (multipart/form-data)
  ///
  /// [title]: 레시피 제목
  /// [description]: 요약 설명
  /// [category]: 카테고리
  /// [images]: 이미지 파일 목록 (최대 3장)
  /// [thumbnailIndex]: 썸네일로 사용할 이미지 인덱스
  /// [ingredients]: 재료 목록 (Map<재료명, 계량>)
  /// [cookingSteps]: 조리 순서 목록
  /// [fat]: 지방 (g)
  /// [protein]: 단백질 (g)
  /// [carbs]: 탄수화물 (g)
  static Future<CommunityPost> createPost({
    required String title,
    required String description,
    required CommunityCategory category,
    required List<XFile> images,
    required int thumbnailIndex,
    required Map<String, String> ingredients,
    required List<String> cookingSteps,
    required double fat,
    required double protein,
    required double carbs,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$_communityEndpoint');
      print('[CommunityService] Creating post: $uri');

      // Multipart 요청 생성
      final request = http.MultipartRequest('POST', uri);

      // 헤더 추가
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        // TODO: 인증 토큰 추가
        // 'Authorization': 'Bearer $token',
      });

      // JSON 데이터 필드
      request.fields['title'] = title;
      request.fields['content'] = description;
      request.fields['category'] = category.serverValue;
      request.fields['thumbnailIndex'] = thumbnailIndex.toString();
      request.fields['userId'] = AppConfig.defaultUserId.toString();

      // 재료 목록 (JSON 문자열)
      request.fields['ingredients'] = jsonEncode(ingredients);

      // 조리 순서 (JSON 배열)
      request.fields['cookingSteps'] = jsonEncode(cookingSteps);

      // 영양 정보
      request.fields['nutrition'] = jsonEncode({
        'fat': fat,
        'protein': protein,
        'carbs': carbs,
        'calories': (fat * 9 + protein * 4 + carbs * 4).round(), // 칼로리 계산
      });

      // 이미지 파일 추가
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final bytes = await image.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'images', // 백엔드에서 기대하는 필드명
          bytes,
          filename: 'image_$i.jpg',
        );
        request.files.add(multipartFile);
      }

      print('[CommunityService] Uploading ${images.length} images...');

      // 요청 전송 (이미지 업로드는 60초 타임아웃)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('이미지 업로드 시간 초과 (60초)');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('[CommunityService] Post created successfully');

        // 생성된 게시글 반환
        return CommunityPost.fromJson(data);
      } else {
        throw Exception(
          'Failed to create post: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      print('[CommunityService] Upload timeout: $e');
      throw Exception('이미지 업로드 시간 초과. 이미지 크기를 줄이거나 네트워크 연결을 확인해주세요.');
    } catch (e) {
      print('[CommunityService] Error creating post: $e');
      rethrow;
    }
  }

  /// 게시글 좋아요
  static Future<void> likePost(String postId) async {
    try {
      final uri = Uri.parse('$_baseUrl$_communityEndpoint/$postId/like');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.requestTimeout));
    } catch (e) {
      print('[CommunityService] Error liking post: $e');
      rethrow;
    }
  }

  /// 게시글 저장
  static Future<void> savePost(String postId) async {
    try {
      final uri = Uri.parse('$_baseUrl$_communityEndpoint/$postId/save');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.requestTimeout));
    } catch (e) {
      print('[CommunityService] Error saving post: $e');
      rethrow;
    }
  }
}
