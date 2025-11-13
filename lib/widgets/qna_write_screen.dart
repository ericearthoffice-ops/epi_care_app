import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/qna_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/qna_service.dart';

/// Q&A 吏덈Ц ?묒꽦 ?붾㈃
/// ?꾨Ц媛?먭쾶 吏덈Ц???묒꽦?섍퀬 ?쒖텧?섎뒗 ?붾㈃
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
  bool _isPrivate = false; // 鍮꾧났媛??щ?
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Image picker
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add photo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                  ),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

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
            content: Text('Image selection failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// ?대?吏 ??젣
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Submit question
  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imagePaths = _selectedImages.map((file) => file.path).toList();
      await QnaService.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        expertType: _selectedExpertType,
        isPrivate: _isPrivate,
        imagePaths: imagePaths,
        userName: 'Guardian',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question submitted.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
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
          '?꾨Ц媛?먭쾶 吏덈Ц?섍린',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              // ?덈궡 硫붿떆吏
              _buildGuideMessage(),

              const SizedBox(height: 16),

              // 移댄뀒怨좊━ ?좏깮
              _buildCategorySection(),

              const SizedBox(height: 16),

              // ?꾨Ц媛 遺꾩빞 ?좏깮
              _buildExpertTypeSection(),

              const SizedBox(height: 16),

              // 鍮꾧났媛??듭뀡
              _buildPrivacySection(),

              const SizedBox(height: 16),

              // ?쒕ぉ ?낅젰
              _buildTitleSection(),

              const SizedBox(height: 16),

              // ?댁슜 ?낅젰
              _buildContentSection(),

              const SizedBox(height: 16),

              // ?대?吏 泥⑤?
              _buildImageSection(),

              const SizedBox(height: 24),

              // ?쒖텧 踰꾪듉
              _buildSubmitButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// ?덈궡 硫붿떆吏
  Widget _buildGuideMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '?꾨Ц媛媛 ?곸꽭?섍퀬 ?뺥솗???듬????쒕┫ ???덈룄濡?n援ъ껜?곸쑝濡?吏덈Ц?댁＜?몄슂.',
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

  /// 移댄뀒怨좊━ ?좏깮 ?뱀뀡
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
                '移댄뀒怨좊━',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// ?꾨Ц媛 遺꾩빞 ?좏깮 ?뱀뀡
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
                '?듬? ?щ쭩 ?꾨Ц媛',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontSize: 15, color: Colors.black87),
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

  /// 鍮꾧났媛??듭뀡 ?뱀뀡
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
                  '鍮꾧났媛?吏덈Ц',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPrivate
                      ? '蹂몄씤怨??꾨Ц媛留?蹂????덉뒿?덈떎'
                      : '?ㅻⅨ ?ъ슜?먮룄 吏덈Ц怨??듬???蹂????덉뒿?덈떎',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  /// ?쒕ぉ ?낅젰 ?뱀뀡
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
                '吏덈Ц ?쒕ぉ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              hintText: '?? ?쎌쓣 源쒕묀?섍퀬 ??쾶 癒뱀쑝硫??대뼸寃??댁빞 ?섎굹??',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterText: '${_titleController.text.length}/100',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '吏덈Ц ?쒕ぉ???낅젰?댁＜?몄슂.';
              }
              if (value.trim().length < 5) {
                return '吏덈Ц ?쒕ぉ? 理쒖냼 5???댁긽 ?낅젰?댁＜?몄슂.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // 湲????移댁슫???낅뜲?댄듃
            },
          ),
        ],
      ),
    );
  }

  /// ?댁슜 ?낅젰 ?뱀뀡
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
                '吏덈Ц ?댁슜',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            '利앹긽, ?곹솴, 沅곴툑?????깆쓣 ?먯꽭???묒꽦?댁＜?몄슂.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contentController,
            maxLines: 10,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText:
                  '?덉떆:\n'
                  '???꾩씠媛 Levetiracetam???섎（ 2??蹂듭슜 以묒엯?덈떎.\n'
                  '?ㅻ뒛 ?꾩묠 8?쒖뿉 癒뱀뼱???섎뒗??源쒕묀?섍퀬 ?ㅽ썑 2?쒖뿉 ?앷컖?ъ뒿?덈떎.\n'
                  '?대윺 ??諛붾줈 癒뱀뼱???좉퉴?? ?꾨땲硫???????쒓컙??議곗젙?댁빞 ?좉퉴??\n'
                  '?덉쟾??蹂듭빟 諛⑸쾿???뚮젮二쇱꽭??',
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterText: '${_contentController.text.length}/2000',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '吏덈Ц ?댁슜???낅젰?댁＜?몄슂.';
              }
              if (value.trim().length < 20) {
                return '吏덈Ц ?댁슜? 理쒖냼 20???댁긽 ?낅젰?댁＜?몄슂.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // 湲????移댁슫???낅뜲?댄듃
            },
          ),
        ],
      ),
    );
  }

  /// Image attachment section
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
                'Attach photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Selected (${_selectedImages.length}/3)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Add prescriptions or symptom photos so experts can review more accurately.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
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
                    _selectedImages.length < 3
                        ? 'Add photo'
                        : 'Up to 3 attachments',
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

  /// Submit button
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
                '吏덈Ц ?깅줉?섍린',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
