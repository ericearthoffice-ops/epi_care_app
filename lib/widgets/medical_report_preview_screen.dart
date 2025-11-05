import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/medical_report.dart';
import '../services/medical_report_service.dart';
import '../services/pdf_generator_service.dart';

/// 의료 보고서 PDF 미리보기 화면
class MedicalReportPreviewScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const MedicalReportPreviewScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<MedicalReportPreviewScreen> createState() =>
      _MedicalReportPreviewScreenState();
}

class _MedicalReportPreviewScreenState
    extends State<MedicalReportPreviewScreen> {
  final MedicalReportService _reportService = MedicalReportService();
  final PdfGeneratorService _pdfService = PdfGeneratorService();

  bool _isLoading = true;
  MedicalReport? _report;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  /// 보고서 데이터 로드
  Future<void> _loadReportData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final report = await _reportService.generateReport(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '보고서 데이터를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
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
        title: const Text(
          '의료 보고서 미리보기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B7FFF)),
            ),
            const SizedBox(height: 20),
            Text(
              '보고서를 생성하고 있습니다...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시만 기다려주세요.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadReportData,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7FFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_report == null) {
      return const Center(
        child: Text('보고서 데이터가 없습니다.'),
      );
    }

    return PdfPreview(
      build: (format) => _pdfService.generateMedicalReportPdf(_report!),
      initialPageFormat: PdfPageFormat.a4,
      pdfFileName:
          '의료보고서_${widget.startDate.year}${widget.startDate.month.toString().padLeft(2, '0')}${widget.startDate.day.toString().padLeft(2, '0')}_${widget.endDate.year}${widget.endDate.month.toString().padLeft(2, '0')}${widget.endDate.day.toString().padLeft(2, '0')}.pdf',
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      actions: [
        // 추가 액션 버튼들은 PdfPreview가 기본 제공
      ],
      loadingWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B7FFF)),
            ),
            const SizedBox(height: 20),
            Text(
              'PDF를 생성하고 있습니다...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      onError: (context, error) {
        return Center(
          child: Text(
            'PDF 생성 중 오류가 발생했습니다:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
}
