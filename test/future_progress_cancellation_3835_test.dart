import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

void main() {
  test(
    'programmatic cancellation works before the button delay, atomic opt-out does not',
    () {
      final operation = NsgProgressOperation()..start();
      expect(operation.canCancel, isFalse);
      operation.cancel();
      expect(operation.cancelToken!.isCancelled, isTrue);
      operation.finish(NsgProgressOutcome.cancelled);
      operation.dispose();
      final atomic = NsgProgressOperation(cancellable: false)..start();
      atomic.cancel();
      expect(atomic.isCancelled, isFalse);
      atomic.finish(NsgProgressOutcome.success);
      atomic.dispose();
    },
  );
  final events = <NsgProgressEvent>[];
  setUp(() {
    events.clear();
    NsgProgressWatchdog.observer = events.add;
  });
  tearDown(() {
    NsgProgressWatchdog.observer = null;
    Get.reset();
  });
  Future<BuildContext> mount(WidgetTester tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            page = context;
            return const Scaffold(body: Text('page'));
          },
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    return page;
  }

  testWidgets('default future progress offers cancellation after ten seconds', (
    tester,
  ) async {
    late BuildContext page;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            page = context;
            return const Scaffold(body: Text('page'));
          },
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    final pending = Completer<void>();
    final finished = nsgFutureProgressAndException(
      context: page,
      func: () => pending.future,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 9));
    expect(find.text('Отменить'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    final offered = find.text('Отменить').evaluate().isNotEmpty;
    pending.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await finished;
    expect(offered, isTrue);
  });
  testWidgets(
    'slow notification is single, percent updates, close emits success',
    (tester) async {
      final page = await mount(tester);
      final operation = NsgProgressOperation(label: 'lineups');
      addTearDown(operation.dispose);
      final pending = Completer<void>();
      final done = nsgFutureProgressAndException(
        context: page,
        operation: operation,
        run: (scope) {
          expect(NsgCancelToken.current, same(scope.cancelToken));
          scope.onProgress(1, 2);
          return pending.future;
        },
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 21));
      expect(find.text('Долгий ответ сервера…'), findsOneWidget);
      expect(find.textContaining('50.0%'), findsOneWidget);
      await tester.pump(const Duration(seconds: 21));
      expect(
        events.where((event) => event.kind == NsgProgressEventKind.slow),
        hasLength(1),
      );
      pending.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await done;
      expect(events.last.outcome, NsgProgressOutcome.success);
      expect(events.last.wasSlow, isTrue);
    },
  );
  testWidgets('button cancellation does not run its success callback', (
    tester,
  ) async {
    final pending = Completer<bool>();
    var success = false;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: NsgButton(
            text: 'start',
            onTapAsync: () => pending.future,
            onAfterTapAsync: () => success = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 11));
    await tester.tap(find.text('Отменить'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    pending.complete(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(success, isFalse);
    expect(find.text('start'), findsOneWidget);
  });
  testWidgets(
    'fast error closes before first build without listening to disposed scope',
    (tester) async {
      final page = await mount(tester);
      final operation = NsgProgressOperation();
      var built = false;
      Object? failure;
      await nsgFutureProgressAndException(
        context: page,
        operation: operation,
        showError: false,
        closeDelay: Duration.zero,
        progressBuilder: (_) {
          built = true;
          return const Text('custom');
        },
        func: () async {
          throw StateError('fast');
        },
      ).then<void>(
        (_) {},
        onError: (Object error) {
          failure = error;
        },
      );
      operation.dispose();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(failure, isA<StateError>());
      expect(built, isFalse);
      expect(tester.takeException(), isNull);
      expect(find.byType(NsgProgressDialogWidget), findsNothing);
    },
  );
  for (final failLate in [false, true]) {
    testWidgets(
      'cancel stops wait and token; late ${failLate ? 'error is telemetry only' : 'success cannot apply'}',
      (tester) async {
        final page = await mount(tester);
        final token = NsgCancelToken();
        final pending = Completer<void>();
        var applied = false;
        Object? cancellation;
        final done =
            nsgFutureProgressAndException(
              context: page,
              cancelToken: token,
              cancelAfter: Duration.zero,
              run: (scope) async {
                await pending.future;
                scope.throwIfCancelled();
                applied = true;
              },
            ).then<void>(
              (_) {},
              onError: (Object error) {
                cancellation = error;
              },
            );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.text('Отменить'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await done;
        expect(cancellation, isA<NsgOperationCancelled>());
        expect(token.isCancelled, isTrue);
        expect(find.byType(NsgProgressDialogWidget), findsNothing);
        expect(find.text('page'), findsOneWidget);
        if (failLate) {
          pending.completeError(StateError('late'), StackTrace.current);
        } else {
          pending.complete();
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(applied, isFalse);
        expect(tester.takeException(), isNull);
        expect(
          events
              .where((event) => event.kind == NsgProgressEventKind.completed)
              .single
              .outcome,
          NsgProgressOutcome.cancelled,
        );
        expect(
          events.where((event) => event.kind == NsgProgressEventKind.lateError),
          hasLength(failLate ? 1 : 0),
        );
      },
    );
  }
  testWidgets(
    'atomic opt-out has watchdog but no cancel button or ambient token',
    (tester) async {
      final page = await mount(tester);
      final pending = Completer<void>();
      final done = nsgFutureProgressAndException(
        context: page,
        cancellable: false,
        run: (scope) {
          expect(NsgCancelToken.current, isNull);
          return pending.future;
        },
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Отменить'), findsNothing);
      expect(find.text('Долгий ответ сервера…'), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.byType(NsgProgressDialogWidget), findsOneWidget);
      pending.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await done;
    },
  );
  testWidgets(
    'early failure keeps existing handler behavior and records error',
    (tester) async {
      final page = await mount(tester);
      var handled = 0;
      final done = nsgFutureProgressAndException(
        context: page,
        func: () async {
          throw const FormatException('early');
        },
        exceptionHandlers: [
          ExceptionHandler<FormatException>(
            onException: (_) {
              handled++;
            },
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await done;
      expect(handled, 1);
      expect(events.single.outcome, NsgProgressOutcome.error);
      expect(find.byType(NsgProgressDialogWidget), findsNothing);
    },
  );
  testWidgets(
    'external cancel removes own progress while preserving a newer dialog',
    (tester) async {
      final page = await mount(tester);
      final pending = Completer<void>();
      final token = NsgCancelToken();
      Object? cancelled;
      final done =
          nsgFutureProgressAndException(
            context: page,
            cancelToken: token,
            func: () => pending.future,
          ).then<void>(
            (_) {},
            onError: (Object error) {
              cancelled = error;
            },
          );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      unawaited(
        showDialog<void>(
          context: page,
          builder: (_) => const AlertDialog(content: Text('newer')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      token.calcel();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await done;
      expect(cancelled, isA<NsgOperationCancelled>());
      expect(find.text('newer'), findsOneWidget);
      expect(find.byType(NsgProgressDialogWidget), findsNothing);
      pending.complete();
      await tester.pump();
      Navigator.of(page, rootNavigator: true).pop();
      await tester.pump(const Duration(milliseconds: 500));
    },
  );
}
