import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
import 'package:nsg_data/nsg_data.dart';

/// Вызов Future функции с прогресс индикатором и проверкой на ошибки
Future nsgFutureProgressAndException({
  Future<void> Function()? func,
  Future<void> Function(NsgProgressOperation operation)? run,
  String? text,
  BuildContext? context,
  bool showProgress = true,
  int? delay,
  List<ExceptionHandler>? exceptionHandlers,
  bool? showFullError,
  bool showError = true,
  Duration closeDelay = const Duration(milliseconds: 100),
  WidgetBuilder? progressBuilder,
  String? label,
  bool cancellable = true,
  bool? canStopped,
  NsgCancelToken? cancelToken,
  VoidCallback? requestStop,
  Duration cancelAfter = const Duration(seconds: 10),
  Duration slowAfter = const Duration(seconds: 20),
  NsgProgressOperation? operation,
}) async {
  if ((func == null) == (run == null)) {
    throw ArgumentError('Provide exactly one of func or run');
  }
  final scope =
      operation ??
      NsgProgressOperation(
        label: label ?? text ?? 'operation',
        cancellable: cancellable && canStopped != false,
        cancelToken: cancelToken,
        cancelAfter: cancelAfter,
        slowAfter: slowAfter,
      );
  scope.start();
  var progress = NsgProgressDialog(
    textDialog: text ?? '',
    context: context,
    delay: delay,
    operation: scope,
    contentBuilder: progressBuilder,
    requestStop: () {
      if (!scope.canCancel) return;
      scope.cancel();
      try {
        requestStop?.call();
      } catch (error, stack) {
        scope.lateError(error, stack);
      }
    },
  );
  // Обработчик исключения может намеренно оставить прогресс на экране
  // (hideProgress: false) — тогда финальная страховка его не трогает.
  var keepProgress = false;
  try {
    if (showProgress) {
      progress.show();
    }
    scope.throwIfCancelled();
    final work = Future<void>.sync(
      () => scope.execute(() => run != null ? run(scope) : func!()),
    );
    final observed = work.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        if (scope.isCancelled) {
          if (error is! NsgOperationCancelled) scope.lateError(error, stack);
          return;
        }
        Error.throwWithStackTrace(error, stack);
      },
    );
    await Future.any<void>([
      observed,
      scope.whenCancelled.then<void>(
        (_) => throw const NsgOperationCancelled(),
      ),
    ]);
    scope.throwIfCancelled();
    scope.finish(NsgProgressOutcome.success);
    if (showProgress) {
      progress.hide();
      if (closeDelay > Duration.zero) await Future.delayed(closeDelay);
    }
  } catch (ex, stack) {
    if (ex is NsgOperationCancelled) {
      scope.finish(NsgProgressOutcome.cancelled);
      rethrow;
    }
    scope.finish(NsgProgressOutcome.error, error: ex, stackTrace: stack);
    if (!showError) rethrow;
    if (exceptionHandlers != null) {
      for (var handler in exceptionHandlers) {
        if (handler.match(ex)) {
          keepProgress = !handler.hideProgress;
          await handler.onEx(ex as Exception);
          if (handler.hideProgress && showProgress) {
            progress.hide();
            if (closeDelay > Duration.zero) await Future.delayed(closeDelay);
          }
          return;
        }
      }
    }
    if (showProgress) {
      progress.hide();
      if (closeDelay > Duration.zero) await Future.delayed(closeDelay);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ошибка внутри показа диалога об ошибке — это уже необработанное
      // исключение в колбэке кадра, т.е. fatal-событие вместо сообщения
      // пользователю (titan-112, GlitchTip #3635). Гасим здесь.
      try {
        if (ex is Exception) {
          showFullError ??= kDebugMode ? true : false;
          await NsgErrorWidget.showError(ex, showFullError: showFullError!);
        } else {
          await NsgErrorWidget.showErrorByString(ex.toString());
        }
      } catch (e) {
        debugPrint(
          'nsgFutureProgressAndException: не удалось показать диалог ошибки: $e',
        );
      }
    });
    rethrow;
  } finally {
    // Страховка на все пути выхода (упал обработчик, прилетел неожиданный
    // Error): модальный прогресс не должен пережить операцию, иначе экран
    // остаётся под барьером и выглядит зависшим. hide() идемпотентен.
    if (showProgress && !keepProgress) {
      progress.hide();
    }
    if (operation == null && !keepProgress) scope.dispose();
  }
}

class ExceptionHandler<T extends Exception> {
  ExceptionHandler({required this.onException, this.hideProgress = true});
  final FutureOr<void> Function(T exception) onException;

  FutureOr<void> onEx(Exception exception) {
    exception as T;
    return onException(exception);
  }

  final bool hideProgress;

  Type get exeptionType => T;
  bool match(e) => e is T;
}
