import 'package:flutter/material.dart';
import 'dart:async';
import '../services/health_data_service.dart';
import '../services/seizure_prediction_service.dart';

/// 스마트워치 데이터 모니터링 화면 (실제 Health Connect 데이터 사용)
class SmartwatchMonitorScreen extends StatefulWidget {
  const SmartwatchMonitorScreen({super.key});

  @override
  State<SmartwatchMonitorScreen> createState() => _SmartwatchMonitorScreenState();
}

class _SmartwatchMonitorScreenState extends State<SmartwatchMonitorScreen> {
  final List<String> _logs = [];
  final HealthDataService _healthService = HealthDataService();
  final SeizurePredictionService _predictionService = SeizurePredictionService();
  Timer? _dataTimer;
  bool _isConnected = false;
  bool _hasPermission = false;
  bool _isLoading = true;
  DateTime? _lastDataReceived;

  // 최근 받은 데이터
  Map<String, dynamic> _latestData = {
    'heartRate': 0.0,
    'steps': 0,
    'sleepMinutes': 0,
    'sleepQuality': 0.0,
    'activeCalories': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _addLog('모니터링 시작');
    _initialize();
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    _predictionService.dispose();
    super.dispose();
  }

  /// 초기화 및 권한 요청
  Future<void> _initialize() async {
    _addLog('Health Connect 확인 중...');

    // Health Connect 사용 가능 여부 확인
    final available = await _healthService.isHealthConnectAvailable();
    if (!available) {
      _addLog('❌ Health Connect를 사용할 수 없습니다');
      _addLog('   Android 14 이상이거나 Health Connect 앱이 필요합니다');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _addLog('✅ Health Connect 사용 가능');

    // 권한 요청
    _addLog('권한 요청 중...');
    final authorized = await _healthService.requestAuthorization();

    setState(() {
      _hasPermission = authorized;
      _isConnected = authorized;
      _isLoading = false;
    });

    if (authorized) {
      _addLog('✅ 권한 승인됨');
      _addLog('갤럭시 워치 데이터 연결 완료');
      _startDataMonitoring();
      // 즉시 첫 데이터 로드
      _fetchHealthData();
    } else {
      _addLog('❌ 권한 거부됨');
      _addLog('   설정에서 권한을 허용해주세요');
    }
  }

  /// 데이터 수신 모니터링 시작
  void _startDataMonitoring() {
    // 30초마다 Health Connect에서 데이터 가져오기
    _dataTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isConnected) {
        _fetchHealthData();
      }
    });
  }

  /// Health Connect에서 실제 데이터 가져오기
  Future<void> _fetchHealthData() async {
    final now = DateTime.now();
    _addLog('📊 데이터 수신: ${_formatTime(now)}');

    try {
      // Health Connect에서 데이터 가져오기
      final data = await _healthService.getHealthDataForPrediction();

      setState(() {
        _lastDataReceived = now;
        _latestData = data;
      });

      _addLog('  ❤️ 심박수: ${data['heartRate']?.toStringAsFixed(1)} bpm');
      _addLog('  👣 걸음 수: ${data['steps']}');
      _addLog('  😴 수면: ${data['sleepMinutes']}분');
      _addLog('  🔥 칼로리: ${data['activeCalories']?.toStringAsFixed(1)} kcal');

      // 백엔드로 실제 전송
      _sendToBackend(data);
    } catch (e) {
      _addLog('❌ 데이터 가져오기 오류: $e');
    }
  }

  /// 백엔드로 실제 데이터 전송 (SeizurePredictionService 사용)
  Future<void> _sendToBackend(Map<String, dynamic> data) async {
    try {
      _addLog('📤 백엔드 전송 시작...');

      // Health Connect 데이터를 HealthSensorData 형식으로 변환
      final sensorDataList = _healthService.convertToSensorData(data);

      if (sensorDataList.isEmpty) {
        _addLog('⚠️ 전송할 데이터가 없습니다');
        _addLog('---');
        return;
      }

      _addLog('   변환된 데이터: ${sensorDataList.length}개 센서');

      // SeizurePredictionService를 통해 백엔드로 전송
      final result = await _predictionService.sendHealthDataToBackend(sensorDataList);

      if (result['status'] == 'skipped') {
        _addLog('⚠️ 전송 건너뜀 (데이터 없음)');
      } else {
        _addLog('✅ 백엔드 전송 완료');

        // 발작 예측 결과가 있으면 표시
        if (result['predictionProbability'] != null) {
          final probability = result['predictionProbability'] as double;
          _addLog('   📊 발작 예측 확률: ${probability.toStringAsFixed(1)}%');

          if (probability >= 70.0) {
            _addLog('   ⚠️ 높은 발작 위험 감지!');
          }
        }
      }

      _addLog('---');
    } catch (e) {
      _addLog('❌ 백엔드 전송 오류: $e');
      _addLog('   (백엔드 서버가 설정되지 않았거나 연결할 수 없음)');
      _addLog('---');
    }
  }

  /// 로그 추가
  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add(message);
        // 최대 100개 로그만 유지
        if (_logs.length > 100) {
          _logs.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '스마트워치 모니터링',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              setState(() {
                _logs.clear();
              });
              _addLog('로그 초기화됨');
              if (_hasPermission) {
                await _fetchHealthData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 연결 상태 카드
                    _buildConnectionCard(),

                    const SizedBox(height: 16),

                    // 권한 요청 버튼 (권한 없을 때만)
                    if (!_hasPermission) _buildPermissionRequestCard(),

                    if (!_hasPermission) const SizedBox(height: 16),

                    // 최근 데이터 카드
                    if (_hasPermission) _buildLatestDataCard(),

                    if (_hasPermission) const SizedBox(height: 16),

                    // 로그 카드
                    _buildLogCard(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 연결 상태 카드
  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: _isConnected ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Connect 연결 상태',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnected ? '연결됨 (갤럭시 워치)' : '연결 안됨',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_lastDataReceived != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  '마지막 데이터 수신: ${_formatTime(_lastDataReceived!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 권한 요청 카드
  Widget _buildPermissionRequestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Health Connect 권한 필요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '갤럭시 워치의 건강 데이터를 읽으려면\nHealth Connect 권한이 필요합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await _initialize();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.shield),
            label: const Text('권한 요청하기'),
          ),
        ],
      ),
    );
  }

  /// 최근 데이터 카드
  Widget _buildLatestDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFF5B7FFF), size: 24),
              const SizedBox(width: 8),
              const Text(
                '최근 수신 데이터 (Health Connect)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataItem('심박수', '${_latestData['heartRate']?.toStringAsFixed(1) ?? '0.0'} bpm', Icons.favorite),
          const SizedBox(height: 12),
          _buildDataItem('걸음 수', '${_latestData['steps'] ?? 0} 걸음', Icons.directions_walk),
          const SizedBox(height: 12),
          _buildDataItem('수면 시간', '${_latestData['sleepMinutes'] ?? 0} 분', Icons.bedtime),
          const SizedBox(height: 12),
          _buildDataItem('수면 품질', '${_latestData['sleepQuality']?.toStringAsFixed(1) ?? '0.0'}%', Icons.psychology),
          const SizedBox(height: 12),
          _buildDataItem('소모 칼로리', '${_latestData['activeCalories']?.toStringAsFixed(1) ?? '0.0'} kcal', Icons.local_fire_department),
        ],
      ),
    );
  }

  /// 데이터 항목
  Widget _buildDataItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B7FFF),
          ),
        ),
      ],
    );
  }

  /// 로그 카드
  Widget _buildLogCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.black87, size: 24),
              const SizedBox(width: 8),
              const Text(
                '전송 로그',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${_logs.length}개',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 400,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ListView.builder(
              reverse: true, // 최신 로그가 아래에 표시
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[_logs.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    log,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: log.contains('✅')
                          ? Colors.green
                          : log.contains('📤')
                              ? Colors.blue
                              : log.contains('📊') || log.contains('❤️') || log.contains('👣')
                                  ? Colors.orange
                                  : log.contains('❌')
                                      ? Colors.red
                                      : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 포맷
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
