import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/seizure_prediction_data.dart';
import '../utils/backend_service.dart';

class ManualSensorField {
  final String key;
  final String label;
  final String unit;
  final String hint;

  const ManualSensorField(this.key, this.label, this.unit, this.hint);
}

const List<ManualSensorField> kManualSensorFields = [
  ManualSensorField('hr', 'Heart Rate (HR)', 'bpm', '82'),
  ManualSensorField('acc', 'Acceleration (ACC)', 'g', '1.2'),
  ManualSensorField('sleep', 'Sleep Duration', 'h', '6.5'),
  ManualSensorField('keto', 'Keto Diet Adherence', '%', '85'),
  ManualSensorField('medication', 'Medication Adherence', '%', '90'),
  ManualSensorField('stress', 'Stress Score', '/100', '48'),
];

class SeizureAlertScreen extends StatefulWidget {
  final SeizurePredictionData predictionData;
  final VoidCallback? onSeizureConfirmed;

  const SeizureAlertScreen({
    super.key,
    required this.predictionData,
    this.onSeizureConfirmed,
  });

  @override
  State<SeizureAlertScreen> createState() => _SeizureAlertScreenState();
}

class _SeizureAlertScreenState extends State<SeizureAlertScreen> {
  ManualSensorAnalysisResult? _manualResult;

  double get _predictionRate =>
      _manualResult?.predictionProbability ??
      widget.predictionData.predictionRate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Seizure Alert'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _requestHelp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.emergency, size: 18),
              label: const Text(
                'Emergency',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPredictionCard(),
            const SizedBox(height: 24),
            _buildSensorTable(),
            const SizedBox(height: 32),
            _buildFeedbackSection(),
            const SizedBox(height: 32),
            ManualSensorEntrySection(
              onResult: (result) {
                setState(() => _manualResult = result);
              },
            ),
            const SizedBox(height: 32),
            _buildEmergencyGuide(),
            const SizedBox(height: 32),
            _buildEmergencyContacts(),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Prediction Probability',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _predictionRate.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '%',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTable() {
    final manualValues = _manualResult?.inputValues ?? const <String, double>{};
    final insights = _manualResult?.sensorInsights ?? const {};
    final showManual = manualValues.isNotEmpty;

    final fallbackRows = <MapEntry<String, MedicalDataItem>>[
      MapEntry('ECG (Heart)', widget.predictionData.ecg),
      MapEntry('Acceleration', widget.predictionData.accelerometer),
      MapEntry('Sleep Hours', widget.predictionData.sleepTime),
      MapEntry('Keto Diet', widget.predictionData.ketoAdherence),
      MapEntry('Medication', widget.predictionData.medicationAdherence),
      MapEntry('Stress Index', widget.predictionData.stressIndex),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Sensor',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Value',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    showManual ? 'Status' : 'Change',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showManual)
            ...kManualSensorFields
                .where((field) => manualValues.containsKey(field.key))
                .map(
                  (field) => _ManualSensorRow(
                    label: field.label,
                    value:
                        '${manualValues[field.key]!.toStringAsFixed(2)} ${field.unit}',
                    status: insights[field.key]?.status ?? 'Normal',
                    color: _statusColor(insights[field.key]?.status),
                  ),
                )
          else
            ...fallbackRows.map(
              (row) => _ManualSensorRow(
                label: row.key,
                value: row.value.displayValue,
                status: row.value.displayChange,
                color: row.value.isIncrease == true ? Colors.red : Colors.blue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Did a seizure occur?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildResponseButton(
                label: 'Yes',
                onPressed: () async {
                  await BackendService.submitPredictionFeedback(
                    timestamp: DateTime.now(),
                    predictionRate: widget.predictionData.predictionRate,
                    actualSeizureOccurred: true,
                  );
                  widget.onSeizureConfirmed?.call();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback saved.')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildResponseButton(
                label: 'No',
                onPressed: () async {
                  await BackendService.submitPredictionFeedback(
                    timestamp: DateTime.now(),
                    predictionRate: widget.predictionData.predictionRate,
                    actualSeizureOccurred: false,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback saved.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponseButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9E9E9E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmergencyGuide() {
    const steps = <({String title, String description})>[
      (
        title: 'Clear the Area',
        description: 'Remove sharp or dangerous objects near the patient.',
      ),
      (
        title: 'Roll on the Side',
        description: 'Turn the head sideways to keep the airway clear.',
      ),
      (
        title: 'Do Not Restrain',
        description: 'Do not hold the patient down during a seizure.',
      ),
      (
        title: 'Nothing in the Mouth',
        description: 'Never place anything inside the mouth.',
      ),
      (
        title: 'Track the Duration',
        description: 'Call emergency services if it lasts over 5 minutes.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: const Row(
              children: [
                Icon(Icons.medical_services_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Emergency Guide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/Emergency.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < steps.length; i++)
                  _buildGuideStep(
                    number: i + 1,
                    title: steps[i].title,
                    description: steps[i].description,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF5B7FFF),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    final contacts = [
      {
        'label': 'Caregiver',
        'phone': '010-1234-5678',
        'color': Colors.deepPurple,
      },
      {
        'label': 'Primary Doctor',
        'phone': '02-123-4567',
        'color': Colors.indigo,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency contacts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final contact in contacts)
          _buildContactCard(
            label: contact['label'] as String,
            phone: contact['phone'] as String,
            color: contact['color'] as Color,
          ),
      ],
    );
  }

  Widget _buildContactCard({
    required String label,
    required String phone,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(phone, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(phone),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendAlert(label),
                  icon: const Icon(Icons.notifications, size: 16),
                  label: const Text('Send alert'),
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start the phone call.')),
      );
    }
  }

  Future<void> _sendAlert(String contactLabel) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Alert sent to $contactLabel.')));
  }

  Future<void> _requestHelp(BuildContext context) async {
    final Uri uri = Uri.parse('tel:119');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to place emergency call.')),
        );
      }
    }
  }

  Color _statusColor(String? status) {
    final normalized = status?.toLowerCase() ?? '';
    if (normalized.contains('high') || normalized.contains('abnormal')) {
      return Colors.red;
    }
    if (normalized.contains('moderate') || normalized.contains('warning')) {
      return Colors.orange;
    }
    return Colors.blue;
  }
}

class ManualSensorEntrySection extends StatefulWidget {
  final ValueChanged<ManualSensorAnalysisResult>? onResult;

  const ManualSensorEntrySection({super.key, this.onResult});

  @override
  State<ManualSensorEntrySection> createState() =>
      _ManualSensorEntrySectionState();
}

class _ManualSensorEntrySectionState extends State<ManualSensorEntrySection> {
  late final Map<String, TextEditingController> _controllers;
  ManualSensorAnalysisResult? _analysis;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in kManualSensorFields)
        field.key: TextEditingController(text: field.hint),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insights = _analysis?.sensorInsights ?? const {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.science_outlined, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Manual sensor input',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < kManualSensorFields.length; i++) ...[
            _buildField(kManualSensorFields[i]),
            if (i != kManualSensorFields.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runAnalysis,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Analyze locally'),
            ),
          ),
          if (_analysis != null) ...[
            const SizedBox(height: 16),
            _buildResultSummary(_analysis!),
          ],
          if (insights.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInsightWrap(insights),
          ],
        ],
      ),
    );
  }

  Widget _buildField(ManualSensorField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controllers[field.key],
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: InputDecoration(
            suffixText: field.unit,
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSummary(ManualSensorAnalysisResult result) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            title: 'Detection',
            value: '${result.detectionProbability.toStringAsFixed(1)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            title: 'Prediction',
            value: '${result.predictionProbability.toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildInsightWrap(Map<String, ManualSensorInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sensor insights',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: insights.entries.map((entry) {
            final status = entry.value.status ?? 'Normal';
            final bool isHigh = status.toLowerCase().contains('high');
            final Color accentColor = isHigh
                ? const Color(0xFFB71C1C)
                : const Color(0xFF1B5E20);
            final Color backgroundColor = isHigh
                ? const Color(0xFFFFCDD2)
                : const Color(0xFFC8E6C9);

            return Container(
              width: 190,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      if (entry.value.value != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          entry.value.value!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (entry.value.description != null)
                    Text(
                      entry.value.description!,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: accentColor.withValues(alpha: 0.85),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _runAnalysis() async {
    final values = <String, double>{};
    for (final field in kManualSensorFields) {
      final text = _controllers[field.key]!.text.trim();
      if (text.isEmpty) continue;
      final parsed = double.tryParse(text);
      if (parsed == null) {
        setState(
          () => _error = 'Please enter a valid number for ${field.label}.',
        );
        return;
      }
      values[field.key] = parsed;
    }

    if (values.isEmpty) {
      setState(() => _error = 'Enter at least one sensor value.');
      return;
    }

    setState(() => _error = null);

    final analysis = ManualSensorAnalyzer.analyze(values);
    setState(() => _analysis = analysis);
    widget.onResult?.call(analysis);
  }
}

class ManualSensorAnalysisResult {
  final double detectionProbability;
  final double predictionProbability;
  final Map<String, double> inputValues;
  final Map<String, ManualSensorInsight> sensorInsights;
  final String? message;

  ManualSensorAnalysisResult({
    required this.detectionProbability,
    required this.predictionProbability,
    required this.inputValues,
    required this.sensorInsights,
    this.message,
  });
}

class ManualSensorInsight {
  final String? status;
  final double? value;
  final String? description;

  const ManualSensorInsight({this.status, this.value, this.description});
}

class ManualSensorAnalyzer {
  static const Map<String, (double min, double max)> _ranges = {
    'hr': (50, 140),
    'acc': (0.1, 3.0),
    'sleep': (3, 9),
    'keto': (50, 100),
    'medication': (60, 100),
    'stress': (0, 100),
  };

  static ManualSensorAnalysisResult analyze(Map<String, double> rawValues) {
    double normalize(String key) {
      final range = _ranges[key];
      if (range == null || rawValues[key] == null) return 0.5;
      final value = rawValues[key]!.clamp(range.$1, range.$2);
      return ((value - range.$1) / (range.$2 - range.$1)).clamp(0.0, 1.0);
    }

    final hr = normalize('hr');
    final acc = normalize('acc');
    final sleep = normalize('sleep');
    final keto = normalize('keto');
    final medication = normalize('medication');
    final stress = normalize('stress');

    final detectionRisk =
        0.40 * hr + 0.25 * acc + 0.15 * (1 - sleep) + 0.20 * stress;
    final predictionRisk =
        0.30 * hr +
        0.20 * acc +
        0.20 * (1 - sleep) +
        0.15 * (1 - medication) +
        0.10 * (1 - keto) +
        0.05 * stress;

    double sigmoid(double value) => 1 / (1 + math.exp(-5.0 * (value - 0.5)));

    final detectionProb = sigmoid(detectionRisk) * 100;
    final predictionProb = sigmoid(predictionRisk) * 100;

    final insights = <String, ManualSensorInsight>{};

    void addInsight({
      required String key,
      required double? value,
      required bool Function(double) isHigh,
      required String highMessage,
      required String lowMessage,
    }) {
      if (value == null) return;
      final status = isHigh(value) ? 'High' : 'Normal';
      insights[key] = ManualSensorInsight(
        status: status,
        value: value,
        description: isHigh(value) ? highMessage : lowMessage,
      );
    }

    addInsight(
      key: 'hr',
      value: rawValues['hr'],
      isHigh: (v) => v > 110,
      highMessage: 'Heart rate is high.',
      lowMessage: 'Heart rate is stable.',
    );
    addInsight(
      key: 'acc',
      value: rawValues['acc'],
      isHigh: (v) => v > 2.0,
      highMessage: 'Acceleration is high.',
      lowMessage: 'Acceleration is within range.',
    );
    addInsight(
      key: 'sleep',
      value: rawValues['sleep'],
      isHigh: (v) => v < 5.0,
      highMessage: 'Sleep duration is short.',
      lowMessage: 'Sleep duration is adequate.',
    );
    addInsight(
      key: 'medication',
      value: rawValues['medication'],
      isHigh: (v) => v < 80,
      highMessage: 'Medication adherence is low.',
      lowMessage: 'Medication adherence is healthy.',
    );
    addInsight(
      key: 'keto',
      value: rawValues['keto'],
      isHigh: (v) => v < 70,
      highMessage: 'Diet adherence is low.',
      lowMessage: 'Diet adherence is healthy.',
    );
    addInsight(
      key: 'stress',
      value: rawValues['stress'],
      isHigh: (v) => v > 70,
      highMessage: 'Stress level is high.',
      lowMessage: 'Stress level is manageable.',
    );

    return ManualSensorAnalysisResult(
      detectionProbability: detectionProb,
      predictionProbability: predictionProb,
      inputValues: rawValues,
      sensorInsights: insights,
      message: predictionProb >= 70
          ? 'High predicted risk. Notify your caregiver.'
          : 'Predicted risk is currently manageable.',
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ManualSensorRow extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final Color color;

  const _ManualSensorRow({
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
