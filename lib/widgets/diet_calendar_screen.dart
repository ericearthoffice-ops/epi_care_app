import 'package:flutter/material.dart';
import 'medication_setup_screen.dart';
import 'medication_list_screen.dart';
import 'meal_time_selection_screen.dart';
import '../models/diet_entry.dart';
import '../models/nutrition_info.dart';
import '../services/diet_service.dart';
import 'community_detail_screen.dart';
import 'direct_diet_entry_screen.dart';

/// 케톤식이 및 약 복용 달력 화면
class DietCalendarScreen extends StatefulWidget {
  const DietCalendarScreen({super.key});

  @override
  State<DietCalendarScreen> createState() => _DietCalendarScreenState();
}

class _DietCalendarScreenState extends State<DietCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _weekStartDate = DateTime.now(); // 현재 주의 시작 날짜
  final ScrollController _scrollController = ScrollController();
  late DietService _dietService;

  // 펼쳐진 식사 시간대
  MealTimeType? _expandedMealTime;

  // 복용 약 설정 완료 여부
  bool _hasMedicationSetup = true;

  @override
  void initState() {
    super.initState();
    _dietService = DietService();
  }

  // 식단 데이터 유무 확인
  bool get _hasDietData {
    final entries = _dietService.getDietEntriesForDate(_selectedDay);
    return entries.isNotEmpty;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 식단 항목 삭제
  void _deleteDietEntry(String entryId) async {
    await _dietService.deleteDietEntry(entryId, _selectedDay);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('식단이 삭제되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 직접 입력한 식단 정보 표시
  void _showDirectEntryInfo(DietEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Color(0xFF5B7FFF)),
            const SizedBox(width: 8),
            const Text('식단 정보'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.recipe.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '직접 입력으로 추가된 식단입니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '식이/복용',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () async {
                if (_hasMedicationSetup) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicationListScreen(),
                    ),
                  );
                } else {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicationSetupScreen(),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _hasMedicationSetup = true;
                    });
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF5B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _hasMedicationSetup ? '복용 약 확인하기' : '복용 약 설정하기',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 달력
            _buildCalendar(),

            // 식단 내용
            SizedBox(
              height: MediaQuery.of(context).size.height - 250,
              child: _hasDietData ? _buildDietContent() : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  /// 달력 위젯 (일주일 형태)
  Widget _buildCalendar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // 월 선택 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이전 주 버튼
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20, color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
                    // 선택된 날짜도 이전 주로 이동
                    _selectedDay = _selectedDay.subtract(const Duration(days: 7));
                  });
                },
              ),
              // 월 표시 (클릭 가능)
              InkWell(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B7FFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_selectedDay.year}년 ${_selectedDay.month}월',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B7FFF),
                    ),
                  ),
                ),
              ),
              // 다음 주 버튼
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _weekStartDate = _weekStartDate.add(const Duration(days: 7));
                    // 선택된 날짜도 다음 주로 이동
                    _selectedDay = _selectedDay.add(const Duration(days: 7));
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 일주일 날짜
          _buildWeekDays(),
        ],
      ),
    );
  }

  /// 월 선택 다이얼로그
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '월 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // 연도 선택
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedDay = DateTime(_selectedDay.year - 1, _selectedDay.month, 1);
                        });
                        Navigator.pop(context);
                        _showMonthPicker();
                      },
                    ),
                    Text(
                      '${_selectedDay.year}년',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDay = DateTime(_selectedDay.year + 1, _selectedDay.month, 1);
                        });
                        Navigator.pop(context);
                        _showMonthPicker();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 월 그리드
                SizedBox(
                  height: 200,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = _selectedDay.month == month;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDay = DateTime(_selectedDay.year, month, _selectedDay.day);
                            _weekStartDate = _selectedDay;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF5B7FFF)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$month월',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 일주일 날짜 표시
  Widget _buildWeekDays() {
    final today = DateTime.now();
    List<DateTime> weekDays = [];

    // 선택된 날짜 기준으로 앞뒤 3일씩 (총 7일)
    for (int i = -3; i <= 3; i++) {
      weekDays.add(_selectedDay.add(Duration(days: i)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((date) {
        final isToday = _isSameDay(date, today);
        final isSelected = _isSameDay(date, _selectedDay);
        final weekdayName = ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
            });
          },
          child: Column(
            children: [
              Text(
                weekdayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: weekdayName == '일'
                      ? Colors.red
                      : weekdayName == '토'
                          ? Colors.blue
                          : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF5B7FFF)
                      : isSelected
                          ? const Color(0xFF5B7FFF).withValues(alpha: 0.3)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      color: isToday ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 비어있는 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF5B7FFF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/Fork and spoon.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '오늘 식단이 비워져 있어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MealTimeSelectionScreen(
                    selectedDate: _selectedDay,
                  ),
                ),
              );
              if (mounted) {
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B7FFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text(
              '채우러가기',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 식단 내용
  Widget _buildDietContent() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMealTimeSection(MealTimeType.breakfast),
            const SizedBox(height: 12),
            _buildMealTimeSection(MealTimeType.lunch),
            const SizedBox(height: 12),
            _buildMealTimeSection(MealTimeType.dinner),
            const SizedBox(height: 20),
            _buildDailySummary(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// 식사 시간대 섹션
  Widget _buildMealTimeSection(MealTimeType mealTime) {
    final isExpanded = _expandedMealTime == mealTime;
    final entries = _dietService.getDietEntriesForMealTime(_selectedDay, mealTime);
    final hasEntries = entries.isNotEmpty;
    final nutrition = _sumNutrition(entries);
    final hasNutrition = hasEntries && _hasNutritionValues(nutrition);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedMealTime = isExpanded ? null : mealTime;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _getMealTimeIcon(mealTime),
                    color: _getMealTimeColor(mealTime),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    mealTime.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (hasEntries)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getMealTimeColor(mealTime).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entries.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getMealTimeColor(mealTime),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            if (hasEntries)
              Column(
                children: entries.map((entry) => _buildDietEntryItem(entry)).toList(),
              ),

            if (!hasEntries)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${mealTime.displayName} 식단이 비어있습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),

            // 영양성분 표
            if (hasNutrition) _buildNutritionTable(nutrition, mealTime),

            // 직접 추가 버튼
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  if (hasEntries) Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DirectDietEntryScreen(
                              mealTime: mealTime,
                              date: _selectedDay,
                            ),
                          ),
                        );
                        if (result == true && mounted) {
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: _getMealTimeColor(mealTime),
                      ),
                      label: const Text('직접 추가'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _getMealTimeColor(mealTime),
                        side: BorderSide(color: _getMealTimeColor(mealTime)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 식단 항목 아이템
  Widget _buildDietEntryItem(DietEntry entry) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, size: 24, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.recipe.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (entry.recipe.userName == '직접 입력') {
                                _showDirectEntryInfo(entry);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommunityDetailScreen(post: entry.recipe),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.info_outline, size: 20),
                            label: const Text('정보'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B7FFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteDietEntry(entry.id);
                            },
                            icon: const Icon(Icons.delete_outline, size: 20),
                            label: const Text('삭제'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.restaurant, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.recipe.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 영양성분 표
  Widget _buildNutritionTable(NutritionInfo nutrition, MealTimeType mealTime) {
    final ketoneRatio = _calculateKetoneRatio(nutrition);
    final ketoStatus = _getKetoStatus(nutrition);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMealTimeColor(mealTime).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMealTimeColor(mealTime).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영양성분',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildNutrientRow('지방', nutrition.fat, nutrition.calories),
          const SizedBox(height: 8),
          _buildNutrientRow('단백질', nutrition.protein, nutrition.calories),
          const SizedBox(height: 8),
          _buildNutrientRow('탄수화물', nutrition.carbs, nutrition.calories),
          const Divider(height: 24),

          // 케톤 비율 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '케톤 비율',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    ketoneRatio,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ketoStatus['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    ketoStatus['icon'] as IconData,
                    size: 18,
                    color: ketoStatus['color'] as Color,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 칼로리',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '${nutrition.calories.toStringAsFixed(0)} Kcal',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B7FFF),
                ),
              ),
            ],
          ),

          // 케톤 식이 가이드라인 경고
          if (ketoStatus['warning'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (ketoStatus['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (ketoStatus['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    ketoStatus['icon'] as IconData,
                    size: 16,
                    color: ketoStatus['color'] as Color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ketoStatus['warning'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 영양소 행
  Widget _buildNutrientRow(String label, double grams, double totalCalories) {
    final calories = _calculateNutrientCalories(label, grams);
    final percentage = totalCalories > 0 ? (calories / totalCalories * 100) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${grams.toStringAsFixed(0)}g',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '${calories.toStringAsFixed(0)} Kcal',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '약 ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 하루 영양성분 총합
  Widget _buildDailySummary() {
    final allEntries = MealTimeType.values
        .expand((m) => _dietService.getDietEntriesForMealTime(_selectedDay, m))
        .toList();

    final nutrition = _sumNutrition(allEntries);
    final hasNutrition = allEntries.isNotEmpty && _hasNutritionValues(nutrition);

    if (!hasNutrition) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '하루 영양성분 총합',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '식단을 추가하면 영양 요약을 확인할 수 있어요.',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final ketoneRatio = _calculateKetoneRatio(nutrition);
    final ketoStatus = _getKetoStatus(nutrition);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '하루 영양성분 총합',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (ketoStatus['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      ketoStatus['icon'] as IconData,
                      size: 14,
                      color: ketoStatus['color'] as Color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ketoStatus['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ketoStatus['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNutrientRow('지방', nutrition.fat, nutrition.calories),
          const SizedBox(height: 8),
          _buildNutrientRow('단백질', nutrition.protein, nutrition.calories),
          const SizedBox(height: 8),
          _buildNutrientRow('탄수화물', nutrition.carbs, nutrition.calories),
          const Divider(height: 24),

          // 케톤 비율
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '케톤 비율',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                ketoneRatio,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ketoStatus['color'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 칼로리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${nutrition.calories.toStringAsFixed(0)} Kcal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B7FFF),
                ),
              ),
            ],
          ),

          // 케톤 식이 가이드라인
          if (ketoStatus['warning'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (ketoStatus['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (ketoStatus['color'] as Color).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ketoStatus['icon'] as IconData,
                    size: 18,
                    color: ketoStatus['color'] as Color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ketoStatus['warning'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getMealTimeIcon(MealTimeType mealTime) {
    switch (mealTime) {
      case MealTimeType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealTimeType.lunch:
        return Icons.wb_sunny;
      case MealTimeType.dinner:
        return Icons.nightlight_round;
    }
  }

  Color _getMealTimeColor(MealTimeType mealTime) {
    switch (mealTime) {
      case MealTimeType.breakfast:
        return const Color(0xFFFFB74D);
      case MealTimeType.lunch:
        return const Color(0xFFFDD835);
      case MealTimeType.dinner:
        return const Color(0xFF5C6BC0);
    }
  }

  NutritionInfo _sumNutrition(List<DietEntry> entries) {
    var total = NutritionInfo.zero;
    for (final entry in entries) {
      final info = _deriveNutrition(entry);
      if (info != null) {
        total = total + info;
      }
    }
    return total;
  }

  NutritionInfo? _deriveNutrition(DietEntry entry) {
    if (entry.recipe.nutrition != null) {
      return entry.recipe.nutrition;
    }
    return _parseNutritionFromText(entry.recipe.content);
  }

  bool _hasNutritionValues(NutritionInfo info) {
    return info.carbs > 0 || info.protein > 0 || info.fat > 0;
  }

  NutritionInfo? _parseNutritionFromText(String text) {
    final double? fat = _extractGrams(text, const ['fat', '지방']);
    final double? protein = _extractGrams(text, const ['protein', '단백질']);
    final double? carbs = _extractGrams(text, const ['carb', 'carbs', '탄수화물']);
    final double? fiber = _extractGrams(text, const ['fiber', '식이섬유']);

    if (fat == null && protein == null && carbs == null) {
      return null;
    }

    final double calories = _estimateCalories(fat ?? 0, protein ?? 0, carbs ?? 0);

    return NutritionInfo(
      calories: calories,
      fat: fat ?? 0,
      protein: protein ?? 0,
      carbs: carbs ?? 0,
      fiber: fiber,
    );
  }

  double? _extractGrams(String text, List<String> keywords) {
    final pattern = keywords.map(RegExp.escape).join('|');
    final regex = RegExp(
      '(?:$pattern)[^\\d]*([0-9]+(?:[\\.,][0-9]+)?)\\s*(?:g|grams)?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  double _estimateCalories(double fat, double protein, double carbs) {
    return (fat * 9) + (protein * 4) + (carbs * 4);
  }

  double _calculateNutrientCalories(String nutrient, double grams) {
    switch (nutrient) {
      case '지방':
        return grams * 9;
      case '단백질':
      case '탄수화물':
        return grams * 4;
      default:
        return 0;
    }
  }

  /// 케톤 비율 계산
  /// 케톤 식이에서 중요한 지표: 지방 / (단백질 + 탄수화물)
  String _calculateKetoneRatio(NutritionInfo nutrition) {
    final denominator = nutrition.protein + nutrition.carbs;
    if (nutrition.fat <= 0 || denominator <= 0) {
      return '-';
    }
    final ratio = nutrition.fat / denominator;
    return '${ratio.toStringAsFixed(2)}:1';
  }

  /// 케토 상태 판단
  /// 의학적 근거 기반 케톤 식이 가이드라인 (2024 NCBI 기준)
  Map<String, dynamic> _getKetoStatus(NutritionInfo nutrition) {
    final totalCal = nutrition.calories;
    if (totalCal == 0) {
      return {
        'label': '데이터 없음',
        'color': Colors.grey,
        'icon': Icons.help_outline,
        'warning': null,
      };
    }

    // 각 영양소의 칼로리 비율 계산
    final fatCal = nutrition.fat * 9;
    final proteinCal = nutrition.protein * 4;
    final carbsCal = nutrition.carbs * 4;

    final fatPercent = (fatCal / totalCal) * 100;
    final proteinPercent = (proteinCal / totalCal) * 100;
    final carbsPercent = (carbsCal / totalCal) * 100;

    // 케톤 비율 계산
    final denominator = nutrition.protein + nutrition.carbs;
    final ketoneRatio = denominator > 0 ? nutrition.fat / denominator : 0.0;

    // 의학적 근거 기반 케톤 식이 기준 (NCBI 2024):
    // 일반 케토제닉: 지방 70-80%, 단백질 15-25%, 탄수화물 5-10%, 비율 2.5:1 ~ 4:1
    // 치료용 케톤식이: 3:1 또는 4:1 (간질 치료)
    // 주의: 4:1 이상은 영양 불균형 위험, 의료 감독 필요

    // 케톤 비율이 너무 높음 (5:1 초과) - 영양 불균형 위험
    if (ketoneRatio > 5.0) {
      return {
        'label': '경고',
        'color': const Color(0xFFF44336),
        'icon': Icons.error,
        'warning': '케톤 비율이 너무 높습니다 (${ketoneRatio.toStringAsFixed(2)}:1). 5:1을 초과하면 영양 불균형 위험이 있습니다. 단백질과 탄수화물 섭취를 늘려 균형을 맞추세요.',
      };
    }

    // 케톤 비율이 높음 (4:1 ~ 5:1) - 치료용 수준, 주의 필요
    if (ketoneRatio > 4.0) {
      return {
        'label': '주의',
        'color': const Color(0xFFFF9800),
        'icon': Icons.warning,
        'warning': '케톤 비율이 치료용 수준입니다 (${ketoneRatio.toStringAsFixed(2)}:1). 이 비율은 의료 감독하에서만 권장됩니다. 일반적인 케톤 식이는 2.5:1 ~ 4:1이 적절합니다.',
      };
    }

    // 완벽한 케토 상태 (2.5:1 ~ 4:1)
    if (fatPercent >= 70 && fatPercent <= 80 &&
        proteinPercent >= 15 && proteinPercent <= 25 &&
        carbsPercent >= 5 && carbsPercent <= 10 &&
        ketoneRatio >= 2.5 && ketoneRatio <= 4.0) {
      return {
        'label': '완벽',
        'color': const Color(0xFF4CAF50),
        'icon': Icons.check_circle,
        'warning': '완벽한 케톤 식이 비율입니다! (${ketoneRatio.toStringAsFixed(2)}:1) 현재 식단을 유지하세요.',
      };
    }

    // 양호한 케토 상태 (2:1 ~ 2.5:1 또는 비율이 좋지만 영양소 비율 약간 벗어남)
    if (ketoneRatio >= 2.0 && ketoneRatio <= 4.0 &&
        fatPercent >= 60 && carbsPercent <= 15) {
      String detail = '';
      if (carbsPercent > 10) {
        detail = ' 탄수화물을 5-10%로 조금 더 줄이면 완벽합니다.';
      } else if (fatPercent < 70) {
        detail = ' 지방 비율을 70-80%로 늘리면 더 좋습니다.';
      } else if (proteinPercent > 25) {
        detail = ' 단백질을 15-25%로 조절하면 더 좋습니다.';
      }
      return {
        'label': '양호',
        'color': const Color(0xFF8BC34A),
        'icon': Icons.check_circle_outline,
        'warning': '양호한 케톤 식이 비율입니다 (${ketoneRatio.toStringAsFixed(2)}:1).$detail',
      };
    }

    // 탄수화물이 너무 높음 (15% 초과)
    if (carbsPercent > 15) {
      return {
        'label': '주의',
        'color': const Color(0xFFFF9800),
        'icon': Icons.warning,
        'warning': '탄수화물 비율이 높습니다 (${carbsPercent.toStringAsFixed(1)}%). 케톤 식이에서는 5-10%가 권장됩니다. 탄수화물을 줄이고 지방 섭취를 늘리세요.',
      };
    }

    // 지방이 너무 낮음 (60% 미만)
    if (fatPercent < 60) {
      return {
        'label': '주의',
        'color': const Color(0xFFFF9800),
        'icon': Icons.warning,
        'warning': '지방 비율이 낮습니다 (${fatPercent.toStringAsFixed(1)}%). 케톤 식이에서는 70-80%가 권장됩니다. 건강한 지방 섭취를 늘리세요.',
      };
    }

    // 단백질이 너무 높음 (30% 초과)
    if (proteinPercent > 30) {
      return {
        'label': '주의',
        'color': const Color(0xFFFF9800),
        'icon': Icons.warning,
        'warning': '단백질 비율이 높습니다 (${proteinPercent.toStringAsFixed(1)}%). 과도한 단백질은 케토시스를 방해할 수 있습니다. 15-25%가 적정합니다.',
      };
    }

    // 케톤 비율이 너무 낮음 (2:1 미만)
    if (ketoneRatio < 2.0) {
      return {
        'label': '경고',
        'color': const Color(0xFFF44336),
        'icon': Icons.error,
        'warning': '케톤 비율이 낮습니다 (${ketoneRatio.toStringAsFixed(2)}:1). 케톤 식이를 위해서는 최소 2.5:1 이상이 필요합니다. 지방을 늘리고 탄수화물/단백질을 줄이세요.',
      };
    }

    // 기본 (비율은 괜찮지만 완벽하진 않음)
    return {
      'label': '보통',
      'color': const Color(0xFF2196F3),
      'icon': Icons.info,
      'warning': '케톤 식이 비율이 적절한 범위에 있습니다 (${ketoneRatio.toStringAsFixed(2)}:1). 지방 ${fatPercent.toStringAsFixed(0)}%, 단백질 ${proteinPercent.toStringAsFixed(0)}%, 탄수화물 ${carbsPercent.toStringAsFixed(0)}%',
    };
  }
}
