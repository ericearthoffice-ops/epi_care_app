import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/medical_report.dart';

/// PDF 생성 서비스
class PdfGeneratorService {
  /// 의료 보고서 PDF 생성
  Future<Uint8List> generateMedicalReportPdf(MedicalReport report) async {
    final pdf = pw.Document();

    // 첫 페이지: 표지 및 기본 정보
    pdf.addPage(_buildCoverPage(report));

    // 두 번째 페이지: 발작 통계
    pdf.addPage(_buildSeizureStatisticsPage(report));

    // 세 번째 페이지: 약 복용 순응도
    pdf.addPage(_buildMedicationAdherencePage(report));

    // 네 번째 페이지: 식이 요약
    pdf.addPage(_buildDietSummaryPage(report));

    // 다섯 번째 페이지: 종합 요약 및 권장사항
    pdf.addPage(_buildSummaryPage(report));

    return pdf.save();
  }

  /// 표지 페이지
  pw.Page _buildCoverPage(MedicalReport report) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 100),
            pw.Center(
              child: pw.Text(
                '간질 환자 의료 보고서',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 60),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 40),
            _buildInfoRow('보고서 기간',
                '${dateFormat.format(report.startDate)} ~ ${dateFormat.format(report.endDate)}'),
            pw.SizedBox(height: 16),
            _buildInfoRow('총 기간', '${report.periodDays}일'),
            pw.SizedBox(height: 16),
            _buildInfoRow('생성일', dateFormat.format(DateTime.now())),
            pw.Spacer(),
            pw.Center(
              child: pw.Text(
                '본 보고서는 환자의 건강 기록을 요약한 자료입니다.',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        );
      },
    );
  }

  /// 발작 통계 페이지
  pw.Page _buildSeizureStatisticsPage(MedicalReport report) {
    final stats = report.seizureStats;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 발작 통계'),
            pw.SizedBox(height: 20),

            // 요약 통계
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('총 발작 횟수', '${stats.totalSeizures}회'),
                      _buildStatCard('주당 평균', '${stats.averagePerWeek.toStringAsFixed(1)}회'),
                    ],
                  ),
                  if (stats.averageDuration != null) ...[
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('평균 지속시간',
                          '${stats.averageDuration!.inMinutes}분 ${stats.averageDuration!.inSeconds % 60}초'),
                        _buildStatCard('발작 발생일', '${stats.seizureDates.length}일'),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 발작 패턴 분석
            pw.Text(
              '발작 패턴 분석',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                stats.totalSeizures > 0
                    ? '보고 기간 동안 총 ${stats.totalSeizures}회의 발작이 기록되었습니다. '
                        '주당 평균 ${stats.averagePerWeek.toStringAsFixed(1)}회의 발작이 발생하고 있습니다.'
                    : '보고 기간 동안 기록된 발작이 없습니다.',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),

            pw.SizedBox(height: 24),

            // 일별 발작 그래프 (간단한 텍스트 형태)
            pw.Text(
              '최근 발작 기록',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            if (stats.seizureDates.isEmpty)
              pw.Text(
                '기록된 발작이 없습니다.',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              )
            else
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: stats.seizureDates.take(10).map((date) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        '• ${DateFormat('yyyy-MM-dd HH:mm').format(date)}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 약 복용 순응도 페이지
  pw.Page _buildMedicationAdherencePage(MedicalReport report) {
    final adherence = report.medicationAdherence;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('2. 약 복용 순응도'),
            pw.SizedBox(height: 20),

            // 순응도 요약
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.green300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('순응도', '${adherence.adherenceRate.toStringAsFixed(1)}%'),
                      _buildStatCard('평가', adherence.adherenceLevel),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('복용 일수', '${adherence.takenDays}일'),
                      _buildStatCard('미복용 일수', '${adherence.missedDays}일'),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 복용 중인 약물 목록
            pw.Text(
              '복용 중인 약물',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: adherence.medications.map((medication) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('• $medication',
                      style: const pw.TextStyle(fontSize: 12)),
                  );
                }).toList(),
              ),
            ),

            pw.SizedBox(height: 24),

            // 복용 패턴 분석
            pw.Text(
              '복용 패턴 분석',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _getMedicationAnalysis(adherence),
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 식이 요약 페이지
  pw.Page _buildDietSummaryPage(MedicalReport report) {
    final diet = report.dietSummary;
    final nutrition = diet.nutritionAverages;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('3. 케톤 식이 요약'),
            pw.SizedBox(height: 20),

            // 식이 기록 완성도
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('기록 완성도', '${diet.completionRate.toStringAsFixed(1)}%'),
                      _buildStatCard('기록 일수', '${diet.recordedDays}일'),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('평균 케톤 비율',
                        '${diet.averageKetoneRatio.toStringAsFixed(2)}:1'),
                      _buildStatCard('주요 케토 상태', diet.mostFrequentStatus),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 평균 영양 성분
            pw.Text(
              '평균 영양 성분 (일일)',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  _buildNutrientRow('칼로리', '${nutrition.avgCalories.toStringAsFixed(0)} Kcal', null),
                  pw.SizedBox(height: 8),
                  _buildNutrientRow('지방', '${nutrition.avgFat.toStringAsFixed(1)}g',
                    '${nutrition.fatPercentage.toStringAsFixed(1)}%'),
                  pw.SizedBox(height: 8),
                  _buildNutrientRow('단백질', '${nutrition.avgProtein.toStringAsFixed(1)}g',
                    '${nutrition.proteinPercentage.toStringAsFixed(1)}%'),
                  pw.SizedBox(height: 8),
                  _buildNutrientRow('탄수화물', '${nutrition.avgCarbs.toStringAsFixed(1)}g',
                    '${nutrition.carbsPercentage.toStringAsFixed(1)}%'),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 케토 상태 분포
            if (diet.ketoStatusCount.isNotEmpty) ...[
              pw.Text(
                '케토 상태 분포',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: diet.ketoStatusCount.entries.map((entry) {
                    final percentage = (entry.value / diet.recordedDays * 100);
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${entry.key}:',
                            style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('${entry.value}일 (${percentage.toStringAsFixed(1)}%)',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// 종합 요약 페이지
  pw.Page _buildSummaryPage(MedicalReport report) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('4. 종합 요약 및 권장사항'),
            pw.SizedBox(height: 20),

            // 전체 평가
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '종합 평가',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    _generateOverallAssessment(report),
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 권장사항
            pw.Text(
              '의료진 권장사항',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _generateRecommendations(report).map((recommendation) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('• $recommendation',
                      style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.4)),
                  );
                }).toList(),
              ),
            ),

            pw.Spacer(),

            // 주의사항
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                '본 보고서는 참고 자료이며, 정확한 진단과 치료는 반드시 의료진과 상담하시기 바랍니다.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 섹션 제목
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue500, width: 2),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  /// 정보 행
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Container(
          width: 150,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// 통계 카드
  pw.Widget _buildStatCard(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
      ],
    );
  }

  /// 영양소 행
  pw.Widget _buildNutrientRow(String label, String value, String? percentage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Row(
          children: [
            pw.Text(value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              )),
            if (percentage != null) ...[
              pw.SizedBox(width: 8),
              pw.Text('($percentage)',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey600,
                )),
            ],
          ],
        ),
      ],
    );
  }

  /// 약 복용 분석 텍스트
  String _getMedicationAnalysis(MedicationAdherence adherence) {
    if (adherence.adherenceRate >= 95) {
      return '환자는 매우 우수한 약 복용 순응도를 보이고 있습니다. 꾸준한 복용이 발작 조절에 긍정적인 영향을 미치고 있습니다.';
    } else if (adherence.adherenceRate >= 85) {
      return '환자는 양호한 약 복용 순응도를 보이고 있습니다. 미복용 일수를 줄이면 더 나은 발작 조절이 가능할 것으로 예상됩니다.';
    } else if (adherence.adherenceRate >= 75) {
      return '환자의 약 복용 순응도가 보통 수준입니다. 규칙적인 복용을 위한 알림 설정 등의 보조 수단이 필요할 수 있습니다.';
    } else {
      return '환자의 약 복용 순응도가 미흡합니다. 발작 조절을 위해 규칙적인 약 복용이 매우 중요하므로, 복용을 놓치는 원인을 파악하고 개선 방안을 모색해야 합니다.';
    }
  }

  /// 전체 평가 생성
  String _generateOverallAssessment(MedicalReport report) {
    final seizureRate = report.seizureStats.averagePerWeek;
    final adherenceRate = report.medicationAdherence.adherenceRate;
    final ketoneRatio = report.dietSummary.averageKetoneRatio;

    String assessment = '${report.periodDays}일간의 건강 기록을 분석한 결과:\n\n';

    // 발작 평가
    if (seizureRate < 1) {
      assessment += '발작 빈도가 매우 낮게 유지되고 있어 우수한 조절 상태입니다. ';
    } else if (seizureRate < 3) {
      assessment += '발작 빈도가 양호한 수준으로 관리되고 있습니다. ';
    } else {
      assessment += '발작 빈도가 다소 높은 편이며, 치료 계획 재검토가 필요할 수 있습니다. ';
    }

    // 약 복용 평가
    if (adherenceRate >= 90) {
      assessment += '약 복용 순응도가 우수합니다. ';
    } else if (adherenceRate >= 80) {
      assessment += '약 복용 순응도가 양호하나 개선의 여지가 있습니다. ';
    } else {
      assessment += '약 복용 순응도 향상이 필요합니다. ';
    }

    // 식이 평가
    if (ketoneRatio >= 2.5 && ketoneRatio <= 4.0) {
      assessment += '케톤 식이가 적절히 유지되고 있습니다.';
    } else if (ketoneRatio >= 2.0) {
      assessment += '케톤 식이가 비교적 잘 유지되고 있으나 미세 조정이 필요합니다.';
    } else {
      assessment += '케톤 식이 개선이 필요합니다.';
    }

    return assessment;
  }

  /// 권장사항 생성
  List<String> _generateRecommendations(MedicalReport report) {
    final recommendations = <String>[];

    // 발작 관련
    if (report.seizureStats.averagePerWeek > 2) {
      recommendations.add('발작 빈도가 높으므로 약물 용량 조정이나 추가 치료를 고려하시기 바랍니다.');
    }

    // 약 복용 관련
    if (report.medicationAdherence.adherenceRate < 90) {
      recommendations.add('약 복용 순응도 향상을 위해 알림 설정이나 가족 지원을 활용하시기 바랍니다.');
    }

    // 식이 관련
    final ketoneRatio = report.dietSummary.averageKetoneRatio;
    if (ketoneRatio < 2.5) {
      recommendations.add('케톤 비율이 낮으므로 지방 섭취를 늘리고 탄수화물을 줄이시기 바랍니다.');
    } else if (ketoneRatio > 4.0) {
      recommendations.add('케톤 비율이 높으므로 영양 균형을 위해 단백질과 탄수화물 섭취를 약간 늘리시기 바랍니다.');
    }

    // 기록 완성도
    if (report.dietSummary.completionRate < 80) {
      recommendations.add('식단 기록을 더 꾸준히 작성하여 정확한 영양 관리를 하시기 바랍니다.');
    }

    // 일반 권장사항
    recommendations.add('규칙적인 생활 리듬과 충분한 수면을 유지하시기 바랍니다.');
    recommendations.add('스트레스 관리와 적절한 운동을 병행하시기 바랍니다.');
    recommendations.add('정기적인 진료를 통해 건강 상태를 점검하시기 바랍니다.');

    return recommendations;
  }
}
