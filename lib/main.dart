import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'widgets/main_navigation.dart';
import 'widgets/seizure_alert_screen.dart';
import 'utils/notification_service.dart';
import 'utils/backend_service.dart';
import 'services/medication_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone 초기화
  tz.initializeTimeZones();

  // 발작 예측 알림 서비스 초기화
  await NotificationService.initialize(
    onNotificationTapped: (payload) {
      if (payload == 'seizure_prediction') {
        // 알림 클릭 시 발작 예측 화면으로 이동
        // GlobalKey를 통해 네비게이션 처리
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => FutureBuilder(
              future: BackendService.fetchSeizurePrediction(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SeizureAlertScreen(
                    predictionData: snapshot.data!,
                    onSeizureConfirmed: () async {
                      await BackendService.confirmSeizureOccurred(
                        timestamp: DateTime.now(),
                        predictionRate: snapshot.data!.predictionRate,
                      );
                    },
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
        );
      }
    },
  );

  // 복용 알림 서비스 초기화
  await MedicationNotificationService().initialize();

  runApp(const EpiCareApp());
}

// 전역 네비게이터 키 (알림 클릭 시 화면 이동용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class EpiCareApp extends StatelessWidget {
  const EpiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 알림 클릭 핸들링용
      title: 'Seizure시계',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B7FFF)),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
