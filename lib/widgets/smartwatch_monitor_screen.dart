import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/galaxy_watch_service.dart';
import '../services/seizure_prediction_service.dart';
import '../models/health_sensor_data.dart';

/// 스마트워치 데이터 모니터링 화면 (실제 Galaxy Watch 센서 데이터 사용)
class SmartwatchMonitorScreen extends StatefulWidget {
  const SmartwatchMonitorScreen({super.key});

  @override
  State<SmartwatchMonitorScreen> createState() => _SmartwatchMonitorScreenState();
}

class _SmartwatchMonitorScreenState extends State<SmartwatchMonitorScreen> {
  final List<String> _logs = [];
  final GalaxyWatchService _galaxyWatchService = GalaxyWatchService();
  final SeizurePredictionService _predictionService = SeizurePredictionService();
  StreamSubscription<HealthSensorData>? _dataSubscription;
  StreamSubscription? _wearableDataSubscription;
  bool _isConnected = false;
  bool _isTracking = false;
  bool _isLoading = true;
  DateTime? _lastDataReceived;

  // EventChannel for wearable data (seizurewatch-master)
  static const EventChannel _wearableEventChannel =
      EventChannel('com.example.epi_care_app/wearable_data_stream');

  // 최근 받은 데이터
  Map<String, dynamic> _latestData = {
    'heartRate': 0.0,
    'spo2': 0.0,
    'ecg': 0.0,
    'ppg': 0.0,
    'eda': 0.0,
    'ibi': 0.0,
    'skinTemperature': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _addLog('모니터링 시작');
    _startWearableDataListener(); // seizurewatch-master 데이터 수신 시작
    _initialize();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _wearableDataSubscription?.cancel();
    _galaxyWatchService.stopTracking();
    _galaxyWatchService.dispose();
    _predictionService.dispose();
    super.dispose();
  }

  /// seizurewatch-master에서 전송하는 wearable 데이터 수신 시작
  void _startWearableDataListener() {
    _addLog('🔵 Wearable 데이터 리스너 시작');

    _wearableDataSubscription = _wearableEventChannel
        .receiveBroadcastStream()
        .listen(
      (dynamic event) {
        if (event is Map) {
          _handleWearableData(Map<String, dynamic>.from(event));
        }
      },
      onError: (error) {
        _addLog('⚠️ Wearable 데이터 수신 오류: $error');
      },
      onDone: () {
        _addLog('🔴 Wearable 데이터 스트림 종료');
      },
    );
  }

  /// Wearable 데이터 처리 및 로그 표시
  void _handleWearableData(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    if (type == 'wearable_biometric') {
      final accelX = data['accelX'] as double? ?? 0.0;
      final accelY = data['accelY'] as double? ?? 0.0;
      final accelZ = data['accelZ'] as double? ?? 0.0;
      final bpm = data['bpm'] as int? ?? 0;
      final timestamp = data['timestamp'] as int? ?? 0;

      // 로그 추가
      setState(() {
        _lastDataReceived = DateTime.now();
        _addLog('📱 [Wearable] 가속도계: (${accelX.toStringAsFixed(2)}, ${accelY.toStringAsFixed(2)}, ${accelZ.toStringAsFixed(2)})');
        _addLog('📱 [Wearable] 심박수: $bpm bpm');
        _addLog('📱 [Wearable] 타임스탬프: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
      });

      // 최근 데이터 업데이트 (심박수만)
      if (bpm > 0) {
        _latestData['heartRate'] = bpm.toDouble();
      }
    }
  }

  /// 초기화 및 Galaxy Watch 연결
  Future<void> _initialize() async {
    try {
      // 1단계: 권한 확인
      _addLog('권한 확인 중...');
      final permissionStatuses = await _galaxyWatchService.checkPermissions();

      final allGranted = permissionStatuses.values.every(
        (status) => status == PermissionStatus.granted || status == PermissionStatus.limited,
      );

      if (!allGranted) {
        _addLog('⚠️ 필수 권한이 없습니다. 권한을 요청합니다...');

        // 권한 요청
        final granted = await _galaxyWatchService.requestPermissions();

        if (!granted) {
          _addLog('❌ 필수 권한이 거부되었습니다');
          _addLog('   설정 > 앱 > EpiCare > 권한에서');
          _addLog('   블루투스, 위치, 센서 권한을 허용해주세요');

          // 영구적으로 거부된 권한 확인
          final permanentlyDenied = await _galaxyWatchService.checkPermanentlyDenied();
          final hasPermanentlyDenied = permanentlyDenied.values.any((denied) => denied);

          if (hasPermanentlyDenied) {
            _addLog('💡 권한이 영구적으로 거부되었습니다');
            _addLog('   설정에서 수동으로 권한을 허용해야 합니다');
          }

          setState(() {
            _isConnected = false;
            _isLoading = false;
          });
          return;
        }

        _addLog('✅ 권한 승인 완료');
      } else {
        _addLog('✅ 모든 권한이 승인되어 있습니다');
      }

      // 2단계: Galaxy Watch 연결 확인
      _addLog('Galaxy Watch 연결 확인 중...');
      final connected = await _galaxyWatchService.isConnected()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _addLog('⏱️ 연결 확인 시간 초과');
            return false;
          },
        );

      if (!connected) {
        _addLog('❌ Galaxy Watch가 연결되지 않았습니다');
        _addLog('   Galaxy Watch를 페어링하고 앱을 다시 시작하세요');
        setState(() {
          _isConnected = false;
          _isLoading = false;
        });
        return;
      }

      _addLog('✅ Galaxy Watch 연결됨');

      // 3단계: Galaxy Watch SDK 초기화
      _addLog('센서 초기화 중...');
      final result = await _galaxyWatchService.initialize(
        trackers: [
          'heart_rate',
          'spo2',
          'ecg',
          'ppg',
          'eda',
          'ibi',
          'skin_temperature',
        ],
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _addLog('⏱️ 센서 초기화 시간 초과');
          throw TimeoutException('Sensor initialization timeout');
        },
      );

      _addLog('✅ 센서 초기화 완료');
      _addLog('   지원 센서: ${result['trackers']?.toString() ?? "알 수 없음"}');

      // 4단계: 스트리밍 시작
      await _startTracking();

      setState(() {
        _isConnected = true;
        _isLoading = false;
      });
    } catch (e) {
      _addLog('❌ 초기화 실패: $e');
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
    }
  }

  /// 센서 데이터 추적 시작 (실시간 스트리밍)
  Future<void> _startTracking() async {
    _addLog('실시간 데이터 스트리밍 시작...');

    try {
      // Galaxy Watch에서 데이터 추적 시작
      await _galaxyWatchService.startTracking(
        trackers: [
          'heart_rate',
          'spo2',
          'ecg',
          'ppg',
          'eda',
          'ibi',
          'skin_temperature',
        ],
        samplingInterval: const Duration(seconds: 5),
      );

      // 데이터 스트림 구독
      _dataSubscription = _galaxyWatchService.healthDataStream.listen(
        _handleSensorData,
        onError: (error) {
          _addLog('❌ 스트림 오류: $error');
        },
        onDone: () {
          _addLog('⚠️ 스트림 종료됨');
          setState(() {
            _isTracking = false;
          });
        },
      );

      setState(() {
        _isTracking = true;
      });

      _addLog('✅ 실시간 스트리밍 시작됨 (5초 간격)');
    } catch (e) {
      _addLog('❌ 추적 시작 실패: $e');
    }
  }

  /// 센서 데이터 처리 (실시간 스트림에서 수신)
  void _handleSensorData(HealthSensorData data) {
    final now = DateTime.now();

    setState(() {
      _lastDataReceived = now;

      // 센서 타입별 최신 데이터 업데이트
      switch (data.type) {
        case 'heart_rate':
          _latestData['heartRate'] = data.value ?? 0.0;
          _addLog('❤️ 심박수: ${data.value?.toStringAsFixed(1)} bpm');
          break;
        case 'spo2':
          _latestData['spo2'] = data.value ?? 0.0;
          _addLog('🫁 산소포화도: ${data.value?.toStringAsFixed(1)}%');
          break;
        case 'ecg':
          _latestData['ecg'] = data.value ?? 0.0;
          _addLog('📈 ECG: ${data.value?.toStringAsFixed(2)} mV');
          break;
        case 'ppg':
          _latestData['ppg'] = data.value ?? 0.0;
          _addLog('🩺 PPG: ${data.value?.toStringAsFixed(2)}');
          break;
        case 'eda':
          _latestData['eda'] = data.value ?? 0.0;
          _addLog('🧠 EDA: ${data.value?.toStringAsFixed(2)} μS');
          break;
        case 'ibi':
          _latestData['ibi'] = data.value ?? 0.0;
          _addLog('❤️‍🩹 IBI: ${data.value?.toStringAsFixed(0)} ms');
          break;
        case 'skin_temperature':
          _latestData['skinTemperature'] = data.value ?? 0.0;
          _addLog('🌡️ 피부온도: ${data.value?.toStringAsFixed(1)}°C');
          break;
        default:
          _addLog('📊 ${data.type}: ${data.value}');
      }
    });

    // 백엔드로 즉시 전송 (버퍼링은 SeizurePredictionService가 처리)
    _predictionService.addHealthData(data);
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
              // 스트리밍 재시작
              if (_isConnected && !_isTracking) {
                await _startTracking();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 연결 상태 카드
                    _buildConnectionCard(),

                    const SizedBox(height: 16),

                    // 연결 안됨 카드 (연결 안됐을 때만)
                    if (!_isConnected) _buildConnectionRetryCard(),

                    if (!_isConnected) const SizedBox(height: 16),

                    // 최근 데이터 카드
                    if (_isConnected) _buildLatestDataCard(),

                    if (_isConnected) const SizedBox(height: 16),

                    // 로그 카드
                    _buildLogCard(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 로딩 스크린
  Widget _buildLoadingScreen() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Galaxy Watch 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.watch,
                size: 60,
                color: Color(0xFF5B7FFF),
              ),
            ),
            const SizedBox(height: 40),

            // 로딩 인디케이터
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B7FFF)),
              ),
            ),
            const SizedBox(height: 24),

            // 로딩 메시지
            const Text(
              'Galaxy Watch 연결 중...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // 부가 설명
            Text(
              '센서를 초기화하고 있습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 60),

            // 힌트 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF5B7FFF),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      '시간이 오래 걸리면 워치 페어링을\n확인해주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                    'Galaxy Watch 연결 상태',
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
                          color: _isConnected && _isTracking ? Colors.green : (_isConnected ? Colors.orange : Colors.red),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnected
                          ? (_isTracking ? '실시간 스트리밍 중' : '연결됨 (대기 중)')
                          : '연결 안됨',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isConnected && _isTracking ? Colors.green : (_isConnected ? Colors.orange : Colors.red),
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

  /// 연결 재시도 카드
  Widget _buildConnectionRetryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.watch_off_outlined, color: Colors.orange, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Galaxy Watch 연결 필요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Galaxy Watch를 페어링하고\n앱을 다시 시작하거나 다시 연결 버튼을 눌러주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _initialize();
              setState(() {
                _isLoading = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 연결하기'),
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
              const Icon(Icons.watch, color: Color(0xFF5B7FFF), size: 24),
              const SizedBox(width: 8),
              const Text(
                '최근 수신 데이터 (Galaxy Watch)',
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
          _buildDataItem('산소포화도', '${_latestData['spo2']?.toStringAsFixed(1) ?? '0.0'}%', Icons.air),
          const SizedBox(height: 12),
          _buildDataItem('심전도 (ECG)', '${_latestData['ecg']?.toStringAsFixed(2) ?? '0.00'} mV', Icons.monitor_heart),
          const SizedBox(height: 12),
          _buildDataItem('광혈류측정 (PPG)', '${_latestData['ppg']?.toStringAsFixed(2) ?? '0.00'}', Icons.graphic_eq),
          const SizedBox(height: 12),
          _buildDataItem('피부전기활동 (EDA)', '${_latestData['eda']?.toStringAsFixed(2) ?? '0.00'} μS', Icons.electric_bolt),
          const SizedBox(height: 12),
          _buildDataItem('심박간격 (IBI)', '${_latestData['ibi']?.toStringAsFixed(0) ?? '0'} ms', Icons.timer),
          const SizedBox(height: 12),
          _buildDataItem('피부온도', '${_latestData['skinTemperature']?.toStringAsFixed(1) ?? '0.0'}°C', Icons.thermostat),
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
