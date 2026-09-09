// Тесты ленивой подгрузки по прокрутке. Каждый закрывает свой тупик, найденный
// на списке шаблонов афиш (NSG-SOFT/futbolista-tasks#2026): организатор
// сообщил, что список не догружается, и что «прокрутка вверх-вниз» не помогает.
//
// Тупиков оказалось два, и они независимы:
//
// 1. Счётчик попыток `_attCount` обнуляла ЕДИНСТВЕННАЯ ветка — «позиция ушла
//    дальше positionBeforeLoad (200 px) от текущего низа». При
//    maxScrollExtent < positionBeforeLoad правая часть её условия отрицательна,
//    а pixels снизу ограничен minScrollExtent — ветка недостижима ни при какой
//    прокрутке, и после первой страницы список молчал навсегда.
//
// 2. У `Future.then` не было onError, а соседний try/catch видит только
//    синхронный бросок. Упавшая страница оставляла статус `loading` навсегда, а
//    он закрывает условие запуска независимо от счётчика попыток — и заодно
//    заставляет потребителей (nsg_data_controller_ui, таблицы) вечно рисовать
//    крутилку.
//
// Третий тест сторожит саму починку: сброс счётчика привязан к РОСТУ списка, а
// не к факту завершения загрузки. Иначе холостой вызов, который ничего не
// принёс, обнулял бы счётчик сам себе — сеттер статуса зовёт notifyListeners,
// то есть того же слушателя, — и получалась бы вечная карусель таймеров.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/ui/nsg_loading_scroll_controller.dart';

void main() {
  /// Список, который растёт от подгрузки — как настоящий.
  ///
  /// [viewport] — высота окна, [content] — стартовая высота содержимого,
  /// [step] — насколько содержимое вырастает за страницу, [pages] — сколько
  /// страниц вообще есть. Возвращает (сколько раз сработал триггер, сколько
  /// страниц реально приехало) и сам контроллер — статус проверяется по нему.
  Future<(int triggers, int loaded, NsgLoadingScrollController controller)> run(
    WidgetTester tester, {
    required int attemptCount,
    required double viewport,
    required double content,
    required double step,
    required int pages,
    required List<double> drags,
    bool throwOnLoad = false,
    double shrinkAfterPage = -1,
  }) async {
    var triggers = 0;
    var loaded = 0;
    final height = ValueNotifier<double>(content);
    addTearDown(height.dispose);

    final NsgLoadingScrollController controller = NsgLoadingScrollController(
      attemptCount: attemptCount,
      function: () async {
        triggers++;
        if (throwOnLoad) throw StateError('страница не приехала');
        if (loaded >= pages) return;
        loaded++;
        height.value += step;
        // Перечитывание списка: запас прокрутки схлопывается обратно. Сброс не
        // должен на этом залипнуть — следующий рост обязан снова засчитаться.
        if (loaded == shrinkAfterPage) height.value = content;
      },
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: viewport,
              child: SingleChildScrollView(
                controller: controller,
                child: ValueListenableBuilder<double>(
                  valueListenable: height,
                  builder: (_, h, __) => SizedBox(width: 400, height: h),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (final dy in drags) {
      await tester.drag(find.byType(SingleChildScrollView), Offset(0, dy));
      await tester.pumpAndSettle();
    }
    return (triggers, loaded, controller);
  }

  // Запас прокрутки 400 - 300 = 100 px, то есть меньше positionBeforeLoad (200):
  // ветка сброса по позиции недостижима математически.
  const viewport = 300.0;
  const content = 400.0;
  const nudges = [-30.0, -30.0, -30.0, -30.0, -30.0, -30.0];

  testWidgets('короткий список догружается дальше первой страницы', (tester) async {
    final (_, loaded, _) = await run(
      tester,
      attemptCount: 1,
      viewport: viewport,
      content: content,
      step: 60,
      pages: 4,
      drags: nudges,
    );

    expect(
      loaded,
      greaterThan(1),
      reason: 'при maxScrollExtent < positionBeforeLoad сброс по позиции недостижим — '
          'счётчик обязан обнуляться по факту роста списка, иначе после первой '
          'страницы прокрутка не подгружает уже ничего',
    );
  });

  testWidgets('упавшая страница не оставляет статус loading навсегда', (tester) async {
    final (triggers, _, controller) = await run(
      tester,
      attemptCount: 1,
      viewport: viewport,
      content: content,
      step: 60,
      pages: 4,
      drags: nudges,
      throwOnLoad: true,
    );

    expect(triggers, greaterThan(0), reason: 'подгрузка должна была хотя бы начаться');
    expect(
      controller.status,
      isNot(NsgLoadingScrollStatus.loading),
      reason: 'статус loading закрывает условие запуска независимо от счётчика попыток: '
          'залипнув в нём, список молчит, а потребители вечно рисуют крутилку',
    );
  });

  testWidgets('холостая подгрузка не заводит вечную карусель', (tester) async {
    // Страниц нет вовсе: каждый вызов возвращается ни с чем и список не растёт.
    // Завершение всё равно ставит success, а сеттер статуса зовёт
    // notifyListeners — то есть этого же слушателя. Единственное, что обрывает
    // эту цепочку, — счётчик попыток, поэтому обнулять его «просто по факту
    // успеха» нельзя.
    final (triggers, loaded, _) = await run(
      tester,
      attemptCount: 3,
      viewport: viewport,
      content: content,
      step: 60,
      pages: 0,
      drags: const [-30.0],
    );

    expect(loaded, 0, reason: 'грузить было нечего');
    expect(triggers, lessThanOrEqualTo(3), reason: 'холостые вызовы обязаны упереться в потолок попыток');
  });

  testWidgets('усохший после перечитывания список не мешает следующему росту', (tester) async {
    // Сравнение с ПРЕДЫДУЩИМ замером, а не с максимумом за всё время: иначе
    // после refreshData (список схлопнулся к первой странице) новая страница не
    // дотянула бы до старого максимума и ростом бы не засчиталась.
    final (_, loaded, _) = await run(
      tester,
      attemptCount: 1,
      viewport: viewport,
      content: content,
      step: 60,
      pages: 4,
      drags: nudges,
      shrinkAfterPage: 2,
    );

    expect(loaded, greaterThan(2), reason: 'после усадки списка подгрузка обязана продолжиться');
  });
}
