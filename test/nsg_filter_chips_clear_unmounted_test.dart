// Очистка фильтра в NsgFilterChips обращалась к context уже удалённой State
// (NSG-SOFT/futbolista-tasks#3685, GlitchTip GT-83).
//
// Стек из 1.9.536: тап по «Отмена» в шторке фильтра →
// _NsgFilterChipsState.getClearButton → State.context →
// NoSuchMethodError: Null check operator used on a null value (_element!).
// Колбэк кнопки делал resetFilter(); setState(() {}); Navigator.pop(context).
// setState при !mounted в этой State уже игнорировался, а чтение State.context —
// нет.
//
// State чипса демонтируется, пока шторка открыта: шторка — отдельный маршрут
// и переживает перестройку страницы, а чипс при этом может исчезнуть из дерева
// (сброс всех фильтров из NsgFilterChipsRow, догрузка списка и т.п.). Тап по
// кнопке очистки в ещё открытой шторке падал на _element!.
//
// Три случая: (1) State демонтирована — своя шторка закрывается без исключения;
// (2) State жива — обычный путь: фильтр сброшен, шторка закрыта (контроль,
// чтобы отличить дефект от поломки стенда); (3) поверх шторки открыт чужой
// маршрут — очистка не снимает его.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_style_button.dart';
import 'package:nsg_controls/widgets/nsg_filter_chips_row.dart';
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

class _Person extends NsgDataItem {
  @override
  String get typeName => 'Person';

  @override
  void initialize() {
    addField(NsgDataStringField('id'), primaryKey: true);
    addField(NsgDataEnumReferenceField<_Kind>('kind'));
  }

  @override
  NsgDataItem getNewObject() => _Person();
}

/// Родитель, который может убрать чипс из дерева, пока шторка фильтра открыта.
class _Harness extends StatefulWidget {
  const _Harness({required this.item});

  final NsgDataItem item;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _showChip = true;

  void hideChip() => setState(() => _showChip = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_showChip)
            NsgFilterChips(
              title: 'Тип',
              filterItem: widget.item,
              fieldName: 'kind',
              defaultValue: _Kind.first,
              builder: (context, item, isSelected) => Text(item.toString()),
            ),
          const Text('страница'),
        ],
      ),
    );
  }
}

void main() {
  late _Person item;

  setUpAll(() {
    // Провайдер не нужен: enum-чипс не ходит ни в сеть, ни в контроллер.
    _Kind(0, '').initialize();
    NsgDataClient.client.registerDataItem(_Person());
  });

  setUp(() {
    item = _Person();
    // Фильтр заведомо НЕ по умолчанию: иначе сброс нечего проверять.
    item['kind'] = _Kind.second.value;
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: _Harness(item: item)));
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byType(NsgMainChips));
    await tester.pumpAndSettle();
    expect(find.text('Тип'), findsOneWidget, reason: 'шторка фильтра открылась');
    expect(find.byType(NsgTextButton), findsOneWidget, reason: 'кнопка очистки видна');
  }

  testWidgets('очистка в шторке не падает, когда State чипса уже удалена', (tester) async {
    await pumpPage(tester);
    await openSheet(tester);

    // Шторка — отдельный маршрут и переживает демонтаж чипса.
    tester.state<_HarnessState>(find.byType(_Harness)).hideChip();
    await tester.pumpAndSettle();
    expect(find.byType(NsgMainChips), findsNothing);
    expect(find.text('Тип'), findsOneWidget, reason: 'шторка осталась открытой');

    await tester.tap(find.byType(NsgTextButton));
    await tester.pump();
    final exception = tester.takeException();
    await tester.pumpAndSettle();

    expect(exception, isNull);
    expect(find.text('Тип'), findsNothing, reason: 'своя шторка безопасно закрылась');
    expect(item['kind'], _Kind.first.value, reason: 'фильтр сброшен к значению по умолчанию');
  });

  testWidgets('очистка в шторке с живой State сбрасывает фильтр и закрывает шторку', (tester) async {
    await pumpPage(tester);
    await openSheet(tester);

    await tester.tap(find.byType(NsgTextButton));
    await tester.pump();
    final exception = tester.takeException();
    await tester.pumpAndSettle();

    expect(exception, isNull);
    expect(find.text('Тип'), findsNothing);
    expect(item['kind'], _Kind.first.value);
  });

  testWidgets('очистка не снимает чужой маршрут поверх шторки', (tester) async {
    await pumpPage(tester);
    await openSheet(tester);

    // Поверх шторки — чужой маршрут (например, прогресс из onEditingComplete).
    final pageContext = tester.element(find.text('страница'));
    Navigator.of(pageContext).push(MaterialPageRoute(builder: (_) => const Scaffold(body: Text('чужой маршрут'))));
    await tester.pumpAndSettle();
    expect(find.text('чужой маршрут'), findsOneWidget);

    // Кнопка шторки перекрыта маршрутом и недоступна хит-тесту — дёргаем её
    // колбэк напрямую: падение GT-83 в самом колбэке, а не в доставке жеста.
    tester.widget<NsgTextButton>(find.byType(NsgTextButton, skipOffstage: false)).onTap!();
    await tester.pump();
    final exception = tester.takeException();
    await tester.pumpAndSettle();

    expect(exception, isNull);
    expect(find.text('чужой маршрут'), findsOneWidget, reason: 'чужой маршрут не закрыт');
    expect(find.byType(NsgTextButton, skipOffstage: false), findsOneWidget, reason: 'шторка под ним осталась открытой');
    expect(item['kind'], _Kind.first.value, reason: 'сброс фильтра всё равно отработал');

    // Уборка, чтобы teardown не оставлял висящие маршруты: снимаем чужой
    // маршрут, затем той же кнопкой закрываем уже текущую шторку.
    Navigator.of(pageContext).pop();
    await tester.pumpAndSettle();
    tester.widget<NsgTextButton>(find.byType(NsgTextButton)).onTap!();
    await tester.pumpAndSettle();
    expect(find.text('Тип'), findsNothing);
  });
}
