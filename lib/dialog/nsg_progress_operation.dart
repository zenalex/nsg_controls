import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nsg_data/nsg_data.dart';

enum NsgProgressEventKind { slow, completed, lateError }

enum NsgProgressOutcome { success, error, cancelled }

class NsgProgressEvent {
  const NsgProgressEvent({
    required this.kind,
    required this.label,
    required this.elapsed,
    required this.wasSlow,
    this.outcome,
    this.error,
    this.stackTrace,
    this.diagnostics = const {},
  });
  final NsgProgressEventKind kind;
  final String label;
  final Duration elapsed;
  final bool wasSlow;
  final NsgProgressOutcome? outcome;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, String> diagnostics;
}

/// Host telemetry and translated messages; no dependency on a telemetry vendor.
class NsgProgressWatchdog {
  static void Function(NsgProgressEvent event)? observer;
  static String Function() cancelText = () => 'Отменить';
  static String Function() slowText = () => 'Долгий ответ сервера…';

  static void emit(NsgProgressEvent event) {
    try {
      observer?.call(event);
    } catch (_) {
      /* Diagnostics cannot hold the UI. */
    }
  }
}

/// Cooperative scope: inherited network calls receive its token. Arbitrary
/// Futures cannot be killed; check throwIfCancelled before applying their result.
class NsgProgressOperation extends ChangeNotifier {
  static final Object _scopeKey = Object();
  static NsgProgressOperation? get current =>
      Zone.current[_scopeKey] as NsgProgressOperation?;
  T execute<T>(T Function() body) => runZoned(
    () => NsgCancelToken.runScoped(cancelToken, body),
    zoneValues: {_scopeKey: this},
  );
  NsgProgressOperation({
    this.cancelLabel,
    this.label = 'operation',
    this.cancellable = true,
    NsgCancelToken? cancelToken,
    this.cancelAfter = const Duration(seconds: 10),
    this.slowAfter = const Duration(seconds: 20),
  }) : cancelToken = cancellable
           ? cancelToken ?? NsgCancelToken.current ?? NsgCancelToken()
           : null;

  final String label;
  final String? cancelLabel;
  final bool cancellable;
  final NsgCancelToken? cancelToken;
  final Duration cancelAfter;
  final Duration slowAfter;
  final Stopwatch _clock = Stopwatch();
  final Completer<void> _cancelled = Completer<void>();
  Timer? _cancelTimer, _slowTimer;
  bool _started = false, _finished = false, _disposed = false;
  bool canCancel = false, isSlow = false, isCancelled = false;
  double? percent;
  final Map<String, String> diagnostics = {};
  Future<void> get whenCancelled => _cancelled.future;

  void start() {
    if (_started) throw StateError('Progress operation cannot be reused');
    _started = true;
    _clock.start();
    if (cancellable) {
      canCancel = cancelAfter <= Duration.zero;
      if (!canCancel) {
        _cancelTimer = Timer(cancelAfter, () {
          canCancel = true;
          _notify();
        });
      }
      unawaited(
        cancelToken!.dioCancelToken.whenCancel.then((_) => _markCancelled()),
      );
      if (cancelToken!.isCancelled) _markCancelled();
    }
    _slowTimer = Timer(slowAfter, () {
      if (_finished) return;
      isSlow = true;
      _emit(NsgProgressEventKind.slow);
      _notify();
    });
  }

  void cancel() {
    if (!canCancel || _finished || isCancelled) return;
    _markCancelled();
    cancelToken?.calcel();
  }

  void _markCancelled() {
    if (_finished || isCancelled) return;
    isCancelled = true;
    canCancel = false;
    _cancelled.complete();
    _notify();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const NsgOperationCancelled();
    cancelToken?.throwIfCancelled();
  }

  void onProgress(int sent, int total) {
    if (_finished || isCancelled || total <= 0) return;
    percent = (100 * sent / total).clamp(0, 100).toDouble();
    _notify();
  }

  void finish(
    NsgProgressOutcome outcome, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_finished) return;
    _finished = true;
    canCancel = false;
    _clock.stop();
    _cancelTimer?.cancel();
    _slowTimer?.cancel();
    _emit(
      NsgProgressEventKind.completed,
      outcome: outcome,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void lateError(Object error, StackTrace stackTrace) => _emit(
    NsgProgressEventKind.lateError,
    outcome: NsgProgressOutcome.cancelled,
    error: error,
    stackTrace: stackTrace,
  );

  void _emit(
    NsgProgressEventKind kind, {
    NsgProgressOutcome? outcome,
    Object? error,
    StackTrace? stackTrace,
  }) {
    NsgProgressWatchdog.emit(
      NsgProgressEvent(
        kind: kind,
        label: label,
        elapsed: _clock.elapsed,
        wasSlow: isSlow,
        outcome: outcome,
        error: error,
        stackTrace: stackTrace,
        diagnostics: Map.unmodifiable(diagnostics),
      ),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    _slowTimer?.cancel();
    _disposed = true;
    super.dispose();
  }
}
