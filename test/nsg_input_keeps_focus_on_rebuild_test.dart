// Ввод в NsgInput переживает перестройку родителя (NSG-SOFT/futbolista-tasks#2437).
//
// Организатор: «в поле отчества при редактировании игрока, если поставить
// курсор и начать писать, клавиатура автоматически убирается через несколько
// секунд». Секунды — это живой поиск похожих игроков: debounce 500 мс и два
// запроса подряд, после которых экран перестраивается.
//
// Сама перестройка фокус ронять не должна. Роняла её форма дерева внутри поля:
// `_gestureWrap` возвращал GestureDetector у пустого поля и Stack у непустого.
// На первом же ребилде после начала ввода тип корневого виджета менялся,
// Widget.canUpdate давал false, и поддерево с TextFormField демонтировалось —
// вместе с фокусом. Android на это закрывает клавиатуру.
//
// Отсюда и форма проверки: клавиатура (соединение с текстовым вводом) обязана
// остаться живой на ребилде, случившемся ПОСЛЕ ввода первого символа. Второй
// случай — ребилд на пустом поле — нужен, чтобы отличить дефект от поломки
// самого стенда: там форма дерева не менялась и раньше.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class _Person extends NsgDataItem {
  @override
  String get typeName => 'Person';

  @override
  void initialize() {
    addField(NsgDataStringField('id'), primaryKey: true);
    addField(NsgDataStringField('name'));
  }

  @override
  NsgDataItem getNewObject() => _Person();
}

/// Родитель, который перестраивается по внешнему сигналу — как экран
/// редактирования игрока по ответу поиска похожих.
class _Rebuildable extends StatefulWidget {
  const _Rebuildable({required this.item});

  final NsgDataItem item;

  @override
  State<_Rebuildable> createState() => _RebuildableState();
}

class _RebuildableState extends State<_Rebuildable> {
  int _generation = 0;

  void rebuild() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Значение меняется на каждом ребилде: без этого Flutter может
        // переиспользовать поддерево целиком и проверка станет холостой.
        Text('поколение $_generation'),
        NsgInput(label: 'Отчество', dataItem: widget.item, fieldName: 'name'),
      ],
    );
  }
}

void main() {
  setUpAll(() {
    // Провайдер не нужен: поле читает только метаданные типа, в сеть не ходит.
    NsgDataClient.client.registerDataItem(_Person());
  });

  Future<_RebuildableState> pumpField(WidgetTester tester) async {
    final item = _Person();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: _Rebuildable(item: item))),
    );
    return tester.state<_RebuildableState>(find.byType(_Rebuildable));
  }

  testWidgets('клавиатура остаётся после ребилда родителя при начатом вводе', (
    tester,
  ) async {
    final parent = await pumpField(tester);

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'Ва');
    await tester.pump();

    expect(
      tester.testTextInput.isVisible,
      isTrue,
      reason: 'ввод начат — клавиатура должна быть открыта',
    );

    parent.rebuild();
    await tester.pump();

    expect(
      tester.testTextInput.isVisible,
      isTrue,
      reason: 'ребилд родителя не должен закрывать клавиатуру',
    );
    expect(find.text('Ва'), findsOneWidget, reason: 'введённое не потеряно');
  });

  testWidgets('на пустом поле ребилд родителя фокус тоже не роняет', (
    tester,
  ) async {
    final parent = await pumpField(tester);

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(tester.testTextInput.isVisible, isTrue);

    parent.rebuild();
    await tester.pump();

    expect(tester.testTextInput.isVisible, isTrue);
  });
}
