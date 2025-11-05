import 'package:flutter/material.dart';
import '../models/seizure_record.dart';
import 'seizure_detail_screen.dart';
import 'seizure_record_form_screen.dart';

/// 발작 기록 화면
class SeizureRecordScreen extends StatefulWidget {
  const SeizureRecordScreen({super.key});

  @override
  State<SeizureRecordScreen> createState() => _SeizureRecordScreenState();
}

class _SeizureRecordScreenState extends State<SeizureRecordScreen> {
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  SortOrder _sortOrder = SortOrder.newest;

  // Mock 데이터
  late List<SeizureRecord> _allRecords;
  late List<MonthlySeizureStats> _monthlyStats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 데이터 로드 (Mock)
  void _loadData() {
    // TODO: 백엔드에서 데이터 가져오기
    _allRecords = SeizureRecord.mockRecords();
    _monthlyStats = MonthlySeizureStats.mockStats(_selectedYear);
  }

  /// 선택된 월의 기록 필터링 및 정렬
  List<SeizureRecord> get _filteredRecords {
    var records = _allRecords;

    // 월 필터링
    if (_selectedMonth != null) {
      records = records.where((record) {
        return record.date.year == _selectedYear &&
            record.date.month == _selectedMonth;
      }).toList();
    }

    // 정렬
    switch (_sortOrder) {
      case SortOrder.newest:
        records.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOrder.oldest:
        records.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOrder.duration:
        records.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }

    return records;
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
          '발작 기록',
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
              onPressed: () {
                // 기록하기 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SeizureRecordFormScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF5B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                '기록하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 연도 선택 및 달력
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 연도 선택
                _buildYearSelector(),
                const SizedBox(height: 24),
                // 월별 달력
                _buildMonthCalendar(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 정렬 옵션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedMonth != null
                      ? '$_selectedYear년 $_selectedMonth월'
                      : '전체 기록',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildSortDropdown(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 발작 기록 리스트
          Expanded(
            child: _buildRecordList(),
          ),
        ],
      ),
    );
  }

  /// 연도 선택 위젯
  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedYear--;
              _loadData();
            });
          },
        ),
        Text(
          '$_selectedYear',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedYear++;
              _loadData();
            });
          },
        ),
      ],
    );
  }

  /// 월별 달력 위젯
  Widget _buildMonthCalendar() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final stats = _monthlyStats.firstWhere((s) => s.month == month);
          final isSelected = _selectedMonth == month;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedMonth == month) {
                  _selectedMonth = null; // 선택 해제
                } else {
                  _selectedMonth = month;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  const Color(0xFFE3F2FD),
                  const Color(0xFF5B7FFF),
                  stats.intensity,
                ),
                border: isSelected
                    ? Border.all(color: const Color(0xFF5B7FFF), width: 3)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: stats.intensity > 0.5 ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 정렬 드롭다운
  Widget _buildSortDropdown() {
    return PopupMenuButton<SortOrder>(
      initialValue: _sortOrder,
      onSelected: (SortOrder value) {
        setState(() {
          _sortOrder = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _sortOrder.label,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return SortOrder.values.map((SortOrder order) {
          return PopupMenuItem<SortOrder>(
            value: order,
            child: Text(order.label),
          );
        }).toList();
      },
    );
  }

  /// 발작 기록 리스트
  Widget _buildRecordList() {
    final records = _filteredRecords;

    if (records.isEmpty) {
      return const Center(
        child: Text(
          '기록이 없습니다',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordItem(record);
      },
    );
  }

  /// 발작 기록 아이템
  Widget _buildRecordItem(SeizureRecord record) {
    return GestureDetector(
      onTap: () {
        // 세부정보 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeizureDetailScreen(record: record),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 날짜 표시
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.date.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.date.month.toString().padLeft(2, '0')}/${record.date.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 세로 구분선
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),

            const SizedBox(width: 16),

            // 시간 및 지속시간
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.durationDisplay,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.timeDisplay}에 기록된 발작',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  if (record.note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
