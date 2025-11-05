import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'medication_schedule_screen.dart';

/// 복용 약 설정 화면 (처음 설정하는 사람용)
class MedicationSetupScreen extends StatefulWidget {
  const MedicationSetupScreen({super.key});

  @override
  State<MedicationSetupScreen> createState() => _MedicationSetupScreenState();
}

class _MedicationSetupScreenState extends State<MedicationSetupScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Medication> _allMedications = [];
  List<Medication> _filteredMedications = [];

  @override
  void initState() {
    super.initState();
    _allMedications = Medication.getAllMedications();
    _filteredMedications = _allMedications;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 검색 필터링
  void _filterMedications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedications = _allMedications;
      } else {
        _filteredMedications = _allMedications.where((medication) {
          final lowerQuery = query.toLowerCase();
          return medication.englishName.toLowerCase().contains(lowerQuery) ||
                 medication.koreanName.contains(query);
        }).toList();
      }
    });
  }

  /// 선택된 약품 개수
  int get _selectedCount {
    return _allMedications.where((m) => m.isSelected).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '정보 입력',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '복용하시는 약을 체크하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 검색 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMedications,
              decoration: InputDecoration(
                hintText: '약품 검색',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterMedications('');
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 선택 개수 표시
          if (_selectedCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$_selectedCount개 선택됨',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF5B7FFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // 약품 리스트
          Expanded(
            child: _filteredMedications.isEmpty
              ? Center(
                  child: Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = _filteredMedications[index];
                    return _buildMedicationItem(medication);
                  },
                ),
          ),

          // 다음 버튼
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedCount > 0
                  ? () {
                      // 선택된 약품들
                      final selectedMeds = _allMedications
                        .where((m) => m.isSelected)
                        .toList();

                      // 복용 스케줄 설정 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationScheduleScreen(
                            selectedMedications: selectedMeds,
                          ),
                        ),
                      );
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7FFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 약품 아이템
  Widget _buildMedicationItem(Medication medication) {
    return CheckboxListTile(
      value: medication.isSelected,
      onChanged: (bool? value) {
        setState(() {
          medication.isSelected = value ?? false;
        });
      },
      title: Text(
        medication.englishName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        medication.koreanName,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF5B7FFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
