import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/qna_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Q&A 질문 작성 화면
/// 전문가에게 질문을 작성하고 제출하는 화면
class QnaWriteScreen extends StatefulWidget {
  const QnaWriteScreen({super.key});

  @override
  State<QnaWriteScreen> createState() => _QnaWriteScreenState();
}

class _QnaWriteScreenState extends State<QnaWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  QnaCategory _selectedCategory = QnaCategory.medication;
  ExpertType _selectedExpertType = ExpertType.any;
  final List<File> _selectedImages = [];
  bool _isPrivate = false; // 비공개 여부
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 이미지 선택
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // 이미지 소스 선택 다이얼로그 표시
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('이미지 선택'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('갤러리에서 선택'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                  title: const Text('카메라로 촬영'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // 이미지 선택
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 질문 제출
  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: 백엔드 API 연동
      // 현재는 Mock 데이터로 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      // TODO: 실제로는 백엔드 API에 데이터를 전송하고 응답을 받아야 함
      // final response = await api.createQnaPost({...});

      if (mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 질문이 등록되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 이전 화면으로 돌아가기
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 질문 등록 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '전문가에게 질문하기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              _buildGuideMessage(),

              const SizedBox(height: 16),

              // 카테고리 선택
              _buildCategorySection(),

              const SizedBox(height: 16),

              // 전문가 분야 선택
              _buildExpertTypeSection(),

              const SizedBox(height: 16),

              // 비공개 옵션
              _buildPrivacySection(),

              const SizedBox(height: 16),

              // 제목 입력
              _buildTitleSection(),

              const SizedBox(height: 16),

              // 내용 입력
              _buildContentSection(),

              const SizedBox(height: 16),

              // 이미지 첨부
              _buildImageSection(),

              const SizedBox(height: 24),

              // 제출 버튼
              _buildSubmitButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 안내 메시지
  Widget _buildGuideMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '전문가가 상세하고 정확한 답변을 드릴 수 있도록\n구체적으로 질문해주세요.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 선택 섹션
  Widget _buildCategorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: QnaCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 전문가 분야 선택 섹션
  Widget _buildExpertTypeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '답변 희망 전문가',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExpertType>(
                value: _selectedExpertType,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                items: ExpertType.values.map((expertType) {
                  return DropdownMenuItem(
                    value: expertType,
                    child: Text(expertType.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedExpertType = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 비공개 옵션 섹션
  Widget _buildPrivacySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            _isPrivate ? Icons.lock : Icons.lock_open,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '비공개 질문',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPrivate
                      ? '본인과 전문가만 볼 수 있습니다'
                      : '다른 사용자도 질문과 답변을 볼 수 있습니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrivate,
            onChanged: (value) {
              setState(() {
                _isPrivate = value;
              });
            },
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// 제목 입력 섹션
  Widget _buildTitleSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '질문 제목',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: '예: 약을 깜빡하고 늦게 먹으면 어떻게 해야 하나요?',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterText: '${_titleController.text.length}/100',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '질문 제목을 입력해주세요.';
              }
              if (value.trim().length < 5) {
                return '질문 제목은 최소 5자 이상 입력해주세요.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // 글자 수 카운터 업데이트
            },
          ),
        ],
      ),
    );
  }

  /// 내용 입력 섹션
  Widget _buildContentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '질문 내용',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '증상, 상황, 궁금한 점 등을 자세히 작성해주세요.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contentController,
            maxLines: 10,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: '예시:\n'
                  '제 아이가 Levetiracetam을 하루 2회 복용 중입니다.\n'
                  '오늘 아침 8시에 먹어야 하는데 깜빡하고 오후 2시에 생각났습니다.\n'
                  '이럴 때 바로 먹어야 할까요, 아니면 저녁 약 시간을 조정해야 할까요?\n'
                  '안전한 복약 방법을 알려주세요.',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterText: '${_contentController.text.length}/2000',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '질문 내용을 입력해주세요.';
              }
              if (value.trim().length < 20) {
                return '질문 내용은 최소 20자 이상 입력해주세요.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // 글자 수 카운터 업데이트
            },
          ),
        ],
      ),
    );
  }

  /// 이미지 첨부 섹션
  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이미지 첨부',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '선택사항 (${_selectedImages.length}/3)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '처방전, 약 사진, 증상 사진 등을 첨부하면 더 정확한 답변을 받을 수 있습니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          // 이미지 선택 버튼
          InkWell(
            onTap: _selectedImages.length < 3 ? _pickImage : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedImages.length < 3
                      ? AppColors.primary
                      : Colors.grey[300]!,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _selectedImages.length < 3
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Colors.grey[100],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: _selectedImages.length < 3
                        ? AppColors.primary
                        : Colors.grey[400],
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedImages.length < 3 ? '사진 추가' : '최대 3장까지 가능',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedImages.length < 3
                          ? AppColors.primary
                          : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 선택된 이미지 목록
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 제출 버튼
  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '질문 등록하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
