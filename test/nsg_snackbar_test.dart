// Тесты снекбара. Каждый закрывает свою из четырёх реализаций, а не «покрытие
// ради покрытия» — история в шапке nsg_snackbar.dart.
//
// Самый важный — «показ снекбара не трогает Navigator»: именно pageless-маршрут
// Flushbar'а давал ре-энтрантную пересборку навигатора внутри его же pop()
// (NSG-SOFT/futbolista-tasks#1449). Вторым по важности — «виден поверх диалога»:
// на этом сломался ScaffoldMessenger.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/widgets/nsg_snackbar.dart';

/// Считает push/pop корневого навигатора. Ноль за весь показ снекбара —
/// это и есть инвариант #1449.
class _RouteCounter extends NavigatorObserver {
  int pushed = 0;
  int popped = 0;
  int removed = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => pushed++;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => popped++;

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => removed++;
}

/// Приложение без единой строчки проводки под снекбар: он обязан работать
/// «из коробки», иначе в чужом приложении молча ничего не покажет.
Widget _app({required Widget child, NavigatorObserver? observer}) {
  return MaterialApp(
    navigatorObservers: observer == null ? const [] : [observer],
    home: Scaffold(body: child),
  );
}

/// Кнопка, из onPressed которой зовём снекбар — то есть ровно так, как его
/// зовут из реального кода: без BuildContext в аргументах.
Widget _trigger(VoidCallback onPressed, {String label = 'показать'}) {
  return Builder(
    builder: (context) => ElevatedButton(onPressed: onPressed, child: Text(label)),
  );
}

void main() {
  tearDown(NsgSnackbarOverlay.dismiss);

  testWidgets('показывает текст и заголовок', (tester) async {
    await tester.pumpWidget(_app(
      child: _trigger(() => nsgSnackbar(title: 'Заголовок', text: 'Сообщение')),
    ));

    await tester.tap(find.text('показать'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Заголовок'), findsOneWidget);
    expect(find.text('Сообщение'), findsOneWidget);
  });

  testWidgets('ПОКАЗ НЕ ТРОГАЕТ NAVIGATOR (инвариант #1449)', (tester) async {
    final observer = _RouteCounter();
    await tester.pumpWidget(_app(
      observer: observer,
      child: _trigger(() => nsgSnackbar(text: 'Сообщение')),
    ));

    // Начальный маршрут '/' — его push уже посчитан, дальше ноль движения.
    final pushedBefore = observer.pushed;

    await tester.tap(find.text('показать'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Сообщение'), findsOneWidget);

    // Дожидаемся автозакрытия — Flushbar снимал свой маршрут именно здесь,
    // по таймеру, и попадал в build-фазу.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Сообщение'), findsNothing);

    expect(observer.pushed - pushedBefore, 0,
        reason: 'Снекбар положил маршрут на Navigator. Так делал Flushbar, и его снятие по '
            'таймеру давало ре-энтрантную пересборку навигатора внутри pop() — #1449. '
            'Показ обязан идти через OverlayEntry, а не через маршрут.');
    expect(observer.popped, 0, reason: 'Снекбар снял маршрут с Navigator — см. #1449.');
    expect(observer.removed, 0, reason: 'Снекбар удалил маршрут из Navigator — см. #1449.');
  });

  testWidgets('виден поверх диалога (на этом сломался ScaffoldMessenger)', (tester) async {
    await tester.pumpWidget(_app(
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const AlertDialog(content: Text('Диалог')),
          ),
          child: const Text('открыть диалог'),
        ),
      ),
    ));

    await tester.tap(find.text('открыть диалог'));
    await tester.pumpAndSettle();
    expect(find.text('Диалог'), findsOneWidget);

    nsgSnackbar(text: 'Поверх диалога');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Поверх диалога'), findsOneWidget,
        reason: 'Снекбар не отрисовался при открытом диалоге.');

    // Мало «найтись» — надо оказаться ВЫШЕ. ScaffoldMessenger рисовал внутри
    // Scaffold под диалогом: виджет находился, а пользователь его не видел.
    final all = tester.allWidgets.toList();
    final dialogIndex = all.indexWhere((w) => w is Text && w.data == 'Диалог');
    final snackIndex = all.indexWhere((w) => w is Text && w.data == 'Поверх диалога');
    expect(dialogIndex, isNot(-1));
    expect(snackIndex, isNot(-1));
    expect(snackIndex, greaterThan(dialogIndex),
        reason: 'Снекбар оказался в дереве РАНЬШЕ диалога, то есть под ним. Ровно этим был '
            'плох ScaffoldMessenger: он рисует внутри текущего Scaffold, а диалог — '
            'отдельный маршрут поверх.');
  });

  testWidgets('закрывается сам по истечении duration', (tester) async {
    await tester.pumpWidget(_app(
      child: _trigger(() => nsgSnackbar(text: 'Исчезну', duration: const Duration(milliseconds: 500))),
    ));

    await tester.tap(find.text('показать'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Исчезну'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Исчезну'), findsNothing);
    expect(NsgSnackbarOverlay.activeCount, 0, reason: 'Запись Overlay осталась висеть после закрытия.');
  });

  testWidgets('второй снекбар заменяет первый, а не копится стопкой', (tester) async {
    await tester.pumpWidget(_app(child: _trigger(() {})));

    nsgSnackbar(text: 'Первый');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Первый'), findsOneWidget);

    nsgSnackbar(text: 'Второй');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Первый'), findsNothing);
    expect(find.text('Второй'), findsOneWidget);
    expect(NsgSnackbarOverlay.activeCount, 1,
        reason: 'Одновременно должен быть виден один снекбар: очередь (GetQueue) и была причиной '
            'падений в #1324.');
  });

  testWidgets('тап закрывает и вызывает onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(_app(
      child: _trigger(() => nsgSnackbar(text: 'Нажми меня', onTap: () => tapped++)),
    ));

    await tester.tap(find.text('показать'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('Нажми меня'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(tapped, 1);
    expect(find.text('Нажми меня'), findsNothing, reason: 'После тапа плашка должна уходить.');
  });

  testWidgets('переживает смену маршрута: не привязан к экрану', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () {
              nsgSnackbar(text: 'Живу дальше', duration: const Duration(seconds: 5));
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('Второй экран'))),
              );
            },
            child: const Text('показать'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('показать'));
    await tester.pumpAndSettle();

    expect(find.text('Второй экран'), findsOneWidget);
    expect(find.text('Живу дальше'), findsOneWidget,
        reason: 'Снекбар в корневом Overlay не должен исчезать при переходе на другой экран.');
  });

  testWidgets('без смонтированного приложения не падает, а молча пропускает', (tester) async {
    // Ни Overlay, ни GetRoot: так бывает на холодном старте и в фоновых Future.
    // Прежние реализации падали здесь; требование — не уронить вызывающего.
    expect(() => nsgSnackbar(text: 'Некуда показывать'), returnsNormally);
    expect(NsgSnackbarOverlay.activeCount, 0);
  });
}
