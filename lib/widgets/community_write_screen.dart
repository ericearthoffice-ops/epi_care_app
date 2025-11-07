import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/community_post.dart';
import '../constants/app_colors.dart';
import 'common/category_chip.dart';

/// 커뮤니티 게시글 작성 화면
/// 레시피 정보 입력 및 게시
class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // 기본 정보
  CommunityCategory? _selectedCategory;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 이미지 관리
  final List<XFile> _selectedImages = [];
  int _thumbnailIndex = 0; // 썸네일로 지정된 이미지 인덱스

  // 재료 목록
  final List<_Ingredient> _ingredients = [
    _Ingredient(nameController: TextEditingController(), amountController: TextEditingController()),
  ];

  // 조리 순서
  final List<TextEditingController> _cookingSteps = [
    TextEditingController(),
  ];

  // 영양 정보
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    for (var ingredient in _ingredients) {
      ingredient.nameController.dispose();
      ingredient.amountController.dispose();
    }
    for (var controller in _cookingSteps) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 재료 추가
  void _addIngredient() {
    setState(() {
      _ingredients.add(
        _Ingredient(
          nameController: TextEditingController(),
          amountController: TextEditingController(),
        ),
      );
    });
  }

  /// 재료 삭제
  void _removeIngredient(int index) {
    if (_ingredients.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개의 재료가 필요합니다.')),
      );
      return;
    }
    setState(() {
      _ingredients[index].nameController.dispose();
      _ingredients[index].amountController.dispose();
      _ingredients.removeAt(index);
    });
  }

  /// 조리 순서 추가
  void _addCookingStep() {
    setState(() {
      _cookingSteps.add(TextEditingController());
    });
  }

  /// 조리 순서 삭제
  void _removeCookingStep(int index) {
    if (_cookingSteps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개의 조리 순서가 필요합니다.')),
      );
      return;
    }
    setState(() {
      _cookingSteps[index].dispose();
      _cookingSteps.removeAt(index);
    });
  }

  /// 이미지 선택
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최대 3장까지 첨부할 수 있습니다.')),
      );
      return;
    }

    final List<XFile> images = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isEmpty) return;

    setState(() {
      // 최대 3장까지만 추가
      final remainingSlots = 3 - _selectedImages.length;
      _selectedImages.addAll(images.take(remainingSlots));
    });
  }

  /// 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);

      // 썸네일 인덱스 조정
      if (_thumbnailIndex >= _selectedImages.length) {
        _thumbnailIndex = _selectedImages.isEmpty ? 0 : _selectedImages.length - 1;
      } else if (_thumbnailIndex > index) {
        _thumbnailIndex--;
      }
    });
  }

  /// 썸네일 지정
  void _setThumbnail(int index) {
    setState(() {
      _thumbnailIndex = index;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${index + 1}번째 사진을 썸네일로 지정했습니다.')),
    );
  }

  /// 게시하기
  void _submitPost() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 항목을 입력해주세요.')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1장의 사진을 첨부해주세요.')),
      );
      return;
    }

    // TODO: 백엔드 API 연동하여 게시글 및 이미지 저장
    // _selectedImages: 모든 이미지 파일
    // _thumbnailIndex: 썸네일 이미지 인덱스
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '레시피가 게시되었습니다!\n'
          '(이미지 ${_selectedImages.length}장, 썸네일: ${_thumbnailIndex + 1}번째)',
        ),
      ),
    );

    // 화면 닫기
    Navigator.of(context).pop(true); // true를 반환하여 목록 새로고침 트리거
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          '레시피 작성',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 선택
              _buildCategorySection(),

              const SizedBox(height: 32),

              // 기본 정보
              _buildBasicInfoSection(),

              const SizedBox(height: 32),

              // 이미지 선택
              _buildImageSection(),

              const SizedBox(height: 32),

              // 재료
              _buildIngredientsSection(),

              const SizedBox(height: 32),

              // 조리 순서
              _buildCookingStepsSection(),

              const SizedBox(height: 32),

              // 영양 정보
              _buildNutritionSection(),

              const SizedBox(height: 40),

              // 게시하기 버튼
              _buildSubmitButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 카테고리 선택 섹션
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CommunityCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return CategoryChip(
              label: category.displayName,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 기본 정보 섹션
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기본 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // 제목
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: '레시피 제목',
            hintText: '예: 키토 야채 스크램블',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 요약 설명
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: '요약 설명',
            hintText: '레시피에 대한 간단한 설명을 작성해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '설명을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 이미지 선택 섹션
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '이미지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_selectedImages.length}/3',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '최소 1장, 최대 3장까지 첨부 가능 (썸네일 지정 필수)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),

        // 이미지 선택된 경우
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length + (_selectedImages.length < 3 ? 1 : 0),
            itemBuilder: (context, index) {
              // 마지막 항목: 추가 버튼
              if (index == _selectedImages.length) {
                return _buildAddImageButton();
              }

              // 이미지 표시
              return _buildImageTile(index);
            },
          )
        else
          // 이미지 없을 때: 추가 버튼만 표시
          _buildAddImageButton(),
      ],
    );
  }

  /// 이미지 추가 버튼
  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[400]),
              const SizedBox(height: 4),
              Text(
                '사진 추가',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 이미지 타일 (미리보기 + 썸네일 지정 + 삭제)
  Widget _buildImageTile(int index) {
    final isThumbnail = index == _thumbnailIndex;

    return Stack(
      children: [
        // 이미지 미리보기
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isThumbnail ? AppColors.primary : Colors.grey[300]!,
                width: isThumbnail ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.file(
              File(_selectedImages[index].path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // 썸네일 배지
        if (isThumbnail)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '썸네일',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // 삭제 버튼
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // 썸네일 지정 버튼
        if (!isThumbnail)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: InkWell(
              onTap: () => _setThumbnail(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '썸네일 지정',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 재료 섹션
  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '재료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('재료 추가'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 재료 목록
        ...List.generate(_ingredients.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // 재료명
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _ingredients[index].nameController,
                    decoration: InputDecoration(
                      labelText: '재료명',
                      hintText: '예: 양배추',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '재료명 입력';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // 계량
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _ingredients[index].amountController,
                    decoration: InputDecoration(
                      labelText: '계량',
                      hintText: '예: 150g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '계량 입력';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // 삭제 버튼
                IconButton(
                  onPressed: () => _removeIngredient(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  iconSize: 28,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 조리 순서 섹션
  Widget _buildCookingStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '조리 순서',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addCookingStep,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('단계 추가'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 조리 순서 목록
        ...List.generate(_cookingSteps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 번호
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 설명
                Expanded(
                  child: TextFormField(
                    controller: _cookingSteps[index],
                    decoration: InputDecoration(
                      labelText: '${index + 1}단계',
                      hintText: '조리 방법을 상세히 설명해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '조리 방법을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // 삭제 버튼
                IconButton(
                  onPressed: () => _removeCookingStep(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  iconSize: 28,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 영양 정보 섹션
  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '영양 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // 지방
            Expanded(
              child: _buildNutritionInput(
                controller: _fatController,
                label: '지방',
                hint: '예: 18',
                color: AppColors.categoryDiet,
              ),
            ),
            const SizedBox(width: 12),

            // 단백질
            Expanded(
              child: _buildNutritionInput(
                controller: _proteinController,
                label: '단백질',
                hint: '예: 12',
                color: AppColors.categoryMedication,
              ),
            ),
            const SizedBox(width: 12),

            // 탄수화물
            Expanded(
              child: _buildNutritionInput(
                controller: _carbsController,
                label: '탄수화물',
                hint: '예: 8',
                color: AppColors.categorySeizure,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 영양 정보 입력 필드
  Widget _buildNutritionInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffix: const Text('g'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '입력 필요';
            }
            if (double.tryParse(value) == null) {
              return '숫자만 입력';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 게시하기 버튼
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '게시하기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 재료 모델
class _Ingredient {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _Ingredient({
    required this.nameController,
    required this.amountController,
  });
}
