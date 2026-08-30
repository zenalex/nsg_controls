// Подтверждение выбора в NsgSelection закрывает окно, даже если колбэк выбора
// синхронно открывает свой маршрут (NSG-SOFT/futbolista-tasks#1818).
//
// Организатор сообщил «галочка в диалоге „Тип турнира“ не нажимается». Кнопка
// нажималась и значение применяла — не закрывалось окно. Порядок в onConfirm был
// «сначала колбэк, потом pop», а колбэк через onEditingComplete →
// findPaymentRulesByOrg → nsgFutureProgressAndException синхронно клал на стек
// прогресс-диалог. Navigator.pop снимал ВЕРХНИЙ маршрут, то есть прогресс, и
// окно выбора оставалось висеть.
//
// Поэтому в тесте два случая на одном и том же пути: разница только в том,
// открывает колбэк свой маршрут или нет. Без второго первый нельзя отличить от
// поломки самого стенда.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class _Kind extends NsgEnum {
  _Kind(dynamic value, String name) : super(value: value, name: name);

  static _Kind get first => _Kind(0, 'Командный');
  static _Kind get second => _Kind(1, 'Индивидуальный');

  @override
  void initialize() {
    NsgEnum.listAllValues[runtimeType] = <int, _Kind>{0: first, 1: second};
  }
}

void main() {
  /// Открывает диалог выбора и возвращает контекст, по которому он открыт.
  Future<int?> tapConfirm(WidgetTester tester, {required bool callbackOpensRoute}) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ctx = context;
            _Kind(0, '').initialize();
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
    );

    int? applied;
    NsgSelection(
      inputType: NsgInputType.enumReference,
      allValues: [_Kind.first, _Kind.second],
      selectedElement: _Kind.first,
    ).selectFromArray('Тип', (item) {
      applied = (item as _Kind).value;
      if (callbackOpensRoute) {
        // Ровно то, что делает асинхронный onEditingComplete на экране настроек
        // турнира: прогресс встаёт на стек синхронно, до первого await.
        // context передаём явно: без него NsgProgressDialog ищет Get.context,
        // которого в голом MaterialApp нет, — прогресс молча не покажется и тест
        // пройдёт вхолостую, ничего не проверив.
        nsgFutureProgressAndException(
          context: ctx,
          func: () async => await Future.delayed(const Duration(milliseconds: 300)),
        );
      }
      return null;
    }, context: ctx);

    await tester.pumpAndSettle();
    expect(find.text('Тип'), findsOneWidget, reason: 'окно выбора открылось');

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();
    // Виджет прогресса заводит собственные таймеры анимации; без запаса времени
    // тест падает на «pending timers», а не на проверяемом инварианте.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    return applied;
  }

  testWidgets('галочка закрывает окно, когда колбэк открывает прогресс', (tester) async {
    final applied = await tapConfirm(tester, callbackOpensRoute: true);
    expect(applied, 0, reason: 'значение применилось');
    expect(find.text('Тип'), findsNothing, reason: 'окно выбора закрылось, а не прогресс вместо него');
  });

  testWidgets('галочка закрывает окно, когда колбэк ничего не открывает', (tester) async {
    final applied = await tapConfirm(tester, callbackOpensRoute: false);
    expect(applied, 0);
    expect(find.text('Тип'), findsNothing);
  });
}
