import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/health_sensor_data.dart';
import '../services/galaxy_watch_service.dart';
import '../services/seizure_prediction_service.dart';

/// 실시간 헬스 모니터링 화면
/// 갤럭시 워치에서 실시간으로 심박수, SpO2 데이터를 받아 표시
class HealthMonitorScreen extends StatefulWidget {
  const HealthMonitorScreen({super.key});

  @override
  State<HealthMonitorScreen> createState() => _HealthMonitorScreenState();
}

class _HealthMonitorScreenState extends State<HealthMonitorScreen> {
  final GalaxyWatchService _galaxyWatchService = GalaxyWatchService();
  final SeizurePredictionService _predictionService =
      SeizurePredictionService();

  StreamSubscription<HealthSensorData>? _dataSubscription;

  bool _isConnected = false;
  bool _isTracking = false;
  bool _isInitializing = false;

  HealthSensorData? _latestHeartRateData;
  HealthSensorData? _latestSpo2Data;
  final List<String> _requestedTrackers = List<String>.from(
    GalaxyWatchService.defaultTrackers,
  );
  final Map<String, HealthSensorData> _latestSensorReadings = {};

  bool get _hasAdditionalSensorData {
    return _latestSensorReadings.keys.any(
      (type) => type != 'heart_rate' && type != 'spo2',
    );
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _galaxyWatchService.dispose();
    _predictionService.dispose();
    super.dispose();
  }

  /// 연결 상태 확인
  Future<void> _checkConnection() async {
    final connected = await _galaxyWatchService.isConnected();
    setState(() {
      _isConnected = connected;
    });
  }

  /// 갤럭시 워치 연결 초기화
  Future<void> _initialize() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      final result = await _galaxyWatchService.initialize(
        trackers: _requestedTrackers,
      );

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isInitializing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '갤럭시 워치 연결 성공'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('연결 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 센서 추적 시작
  Future<void> _startTracking() async {
    try {
      await _galaxyWatchService.startTracking(trackers: _requestedTrackers);

      // 실시간 데이터 스트림 구독
      _dataSubscription = _galaxyWatchService.healthDataStream.listen(
        (data) {
          setState(() {
            _latestSensorReadings[data.type] = data;

            if (data.type == 'heart_rate') {
              _latestHeartRateData = data;
            } else if (data.type == 'spo2') {
              _latestSpo2Data = data;
            }
          });

          // 백엔드로 데이터 전송
          _predictionService.addHealthData(data);
        },
        onError: (error) {
          // ignore: avoid_print
          print('Health data stream error: $error');
        },
      );

      setState(() {
        _isTracking = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('실시간 모니터링 시작'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추적 시작 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 센서 추적 중지
  Future<void> _stopTracking() async {
    try {
      await _galaxyWatchService.stopTracking();
      await _predictionService.flushBufferedData();
      _dataSubscription?.cancel();
      _dataSubscription = null;

      setState(() {
        _isTracking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('실시간 모니터링 중지'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추적 중지 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          '실시간 헬스 모니터링',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 연결 상태 카드
            _buildConnectionStatusCard(),

            const SizedBox(height: 20),

            // 심박수 카드
            _buildHeartRateCard(),

            const SizedBox(height: 16),

            // SpO2 카드
            _buildSpo2Card(),

            const SizedBox(height: 16),

            if (_hasAdditionalSensorData) ...[
              _buildAdditionalSensorsCard(),
              const SizedBox(height: 32),
            ] else
              const SizedBox(height: 32),

            // 제어 버튼
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  /// 연결 상태 카드
  Widget _buildConnectionStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isConnected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isConnected ? AppColors.primary : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.watch : Icons.watch_off_outlined,
            color: _isConnected ? AppColors.primary : Colors.grey[600],
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? '갤럭시 워치 연결됨' : '갤럭시 워치 연결 안됨',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isConnected ? AppColors.primary : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isTracking ? '실시간 모니터링 중' : '모니터링 대기 중',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (_isTracking)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 심박수 카드
  Widget _buildHeartRateCard() {
    return _buildVitalSignCard(
      title: '심박수',
      icon: Icons.favorite,
      color: Colors.red,
      value: _formatPrimaryValue(_latestHeartRateData),
      unit: 'bpm',
      status: _latestHeartRateData?.statusDescription,
      isNormal: _latestHeartRateData?.isHeartRateNormal ?? true,
      lastUpdate: _latestHeartRateData?.timestamp,
    );
  }

  /// SpO2 카드
  Widget _buildSpo2Card() {
    return _buildVitalSignCard(
      title: '산소포화도',
      icon: Icons.air,
      color: Colors.blue,
      value: _formatPrimaryValue(_latestSpo2Data),
      unit: '%',
      status: _latestSpo2Data?.statusDescription,
      isNormal: _latestSpo2Data?.isSpo2Normal ?? true,
      lastUpdate: _latestSpo2Data?.timestamp,
    );
  }

  /// 기타 센서 데이터를 보여주는 카드
  Widget _buildAdditionalSensorsCard() {
    final additionalEntries =
        _latestSensorReadings.entries
            .where((entry) => entry.key != 'heart_rate' && entry.key != 'spo2')
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추가 센서 데이터',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < additionalEntries.length; index++) ...[
            _buildSensorDetails(additionalEntries[index].value),
            if (index != additionalEntries.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorDetails(HealthSensorData data) {
    final Map<String, dynamic> metrics = data.metrics.isNotEmpty
        ? data.metrics
        : (data.value != null ? {'value': data.value!} : <String, dynamic>{});
    final entries = metrics.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sensorDisplayName(data.type),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const Text(
            '최근 측정값이 없습니다.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _humanizeKey(entry.key),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                Text(
                  _composeMetricValue(data, entry),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            if (data.status != null)
              Text(
                '상태: ${data.statusDescription}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Text(
              '업데이트: ${_formatTime(data.timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (data.location != null)
              Text(
                '착용 위치: ${data.location}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (data.source != null)
              Text(
                '소스 기기: ${data.source}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ],
    );
  }

  String _composeMetricValue(
    HealthSensorData data,
    MapEntry<String, dynamic> metric,
  ) {
    final value = _formatMetricValue(metric.value);
    final unit = _resolveMetricUnit(data, metric.key);
    return unit != null && unit.isNotEmpty ? '$value $unit' : value;
  }

  String? _resolveMetricUnit(HealthSensorData data, String key) {
    if (data.units != null && data.units!.containsKey(key)) {
      return data.units![key];
    }
    if (key == 'value' && data.unit != null) {
      return data.unit;
    }
    return null;
  }

  String _sensorDisplayName(String type) {
    switch (type) {
      case 'bia':
        return '체성분 (BIA)';
      case 'mf_bia':
        return '다주파수 BIA';
      case 'bio_active_sensor':
        return 'BioActive Sensor';
      case 'ecg':
        return '심전도 (ECG)';
      case 'eda':
        return '피부전도 (EDA)';
      case 'ibi':
        return '심박 간격 (IBI)';
      case 'ppg':
        return '광용적맥파 (PPG)';
      case 'sleep_stage':
        return '수면 단계';
      case 'skin_temperature':
        return '피부 온도';
      default:
        return _humanizeKey(type);
    }
  }

  String _humanizeKey(String key) {
    final segments = key.split(RegExp(r'[_-]'));
    return segments
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              segment.substring(0, 1).toUpperCase() + segment.substring(1),
        )
        .join(' ');
  }

  String _formatMetricValue(dynamic value) {
    if (value == null) return '--';
    if (value is num) {
      final double doubleValue = value.toDouble();
      return doubleValue % 1 == 0
          ? doubleValue.toStringAsFixed(0)
          : doubleValue.toStringAsFixed(2);
    }
    if (value is bool) {
      return value ? 'YES' : 'NO';
    }
    if (value is List) {
      return value.map(_formatMetricValue).join(', ');
    }
    return value.toString();
  }

  String _formatPrimaryValue(HealthSensorData? data, {int precision = 0}) {
    final double? rawValue = data?.value;
    if (rawValue == null) {
      return '--';
    }

    if (precision == 0) {
      return rawValue.round().toString();
    }
    return rawValue.toStringAsFixed(precision);
  }

  /// 바이탈 사인 카드 공통 위젯
  Widget _buildVitalSignCard({
    required String title,
    required IconData icon,
    required Color color,
    required String value,
    required String unit,
    String? status,
    required bool isNormal,
    DateTime? lastUpdate,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNormal ? color.withValues(alpha: 0.3) : Colors.orange,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isNormal ? color : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isNormal
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: isNormal ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (lastUpdate != null) ...[
            const SizedBox(height: 8),
            Text(
              '마지막 업데이트: ${_formatTime(lastUpdate)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  /// 제어 버튼
  Widget _buildControlButtons() {
    return Column(
      children: [
        if (!_isConnected)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isInitializing ? null : _initialize,
              icon: _isInitializing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.link),
              label: Text(_isInitializing ? '연결 중...' : '갤럭시 워치 연결'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else if (!_isTracking)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _startTracking,
              icon: const Icon(Icons.play_arrow),
              label: const Text('모니터링 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _stopTracking,
              icon: const Icon(Icons.stop),
              label: const Text('모니터링 중지'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
