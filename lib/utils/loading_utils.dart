import 'package:flutter/material.dart';
import '../widgets/loading_screen.dart';

/// 로딩 유틸리티 클래스
/// 백엔드 요청 시 지연이 발생하면 자동으로 로딩 화면을 표시합니다
class LoadingUtils {
  /// 로딩 화면 표시 임계값 (밀리초)
  /// 요청이 이 시간보다 오래 걸리면 로딩 화면을 표시합니다
  static const int loadingThreshold = 500; // 500ms

  /// 로딩 오버레이 표시
  static void showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.9),
      builder: (context) => const LoadingScreen(),
    );
  }

  /// 로딩 오버레이 숨기기
  static void hideLoadingOverlay(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// 비동기 작업 실행 with 자동 로딩 표시
  ///
  /// [context]: BuildContext
  /// [future]: 실행할 비동기 작업
  /// [threshold]: 로딩 화면을 표시할 임계값 (기본: 500ms)
  ///
  /// 사용 예:
  /// ```dart
  /// final result = await LoadingUtils.runWithLoading(
  ///   context,
  ///   () => fetchDataFromBackend(),
  /// );
  /// ```
  static Future<T> runWithLoading<T>(
    BuildContext context,
    Future<T> Function() future, {
    int threshold = loadingThreshold,
  }) async {
    bool isLoading = false;
    bool isCompleted = false;

    // threshold 시간 후 로딩 화면 표시
    Future.delayed(Duration(milliseconds: threshold), () {
      if (!isCompleted && context.mounted) {
        isLoading = true;
        showLoadingOverlay(context);
      }
    });

    try {
      // 실제 작업 실행
      final result = await future();
      isCompleted = true;

      // 로딩 화면이 표시되었다면 숨김
      if (isLoading && context.mounted) {
        hideLoadingOverlay(context);
      }

      return result;
    } catch (e) {
      isCompleted = true;

      // 에러 발생 시에도 로딩 화면 숨김
      if (isLoading && context.mounted) {
        hideLoadingOverlay(context);
      }

      rethrow;
    }
  }
}

/// 로딩 가능한 Future를 관리하는 위젯
/// FutureBuilder 대신 사용하여 자동으로 로딩 화면을 표시합니다
class LoadingFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function() future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final int threshold;

  const LoadingFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.threshold = LoadingUtils.loadingThreshold,
  });

  @override
  State<LoadingFutureBuilder<T>> createState() => _LoadingFutureBuilderState<T>();
}

class _LoadingFutureBuilderState<T> extends State<LoadingFutureBuilder<T>> {
  late Future<T> _future;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFuture();
  }

  void _initializeFuture() {
    // threshold 후 로딩 표시
    Future.delayed(Duration(milliseconds: widget.threshold), () {
      if (mounted) {
        setState(() {
          _showLoading = true;
        });
      }
    });

    _future = widget.future();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중
          if (_showLoading) {
            return const LoadingScreen();
          } else {
            // threshold 전에는 빈 화면
            return const SizedBox.shrink();
          }
        } else if (snapshot.hasError) {
          // 에러 발생
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!);
          } else {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          }
        } else if (snapshot.hasData) {
          // 데이터 로드 완료
          return widget.builder(context, snapshot.data as T);
        } else {
          // 데이터 없음
          return const Center(
            child: Text('데이터가 없습니다'),
          );
        }
      },
    );
  }
}
