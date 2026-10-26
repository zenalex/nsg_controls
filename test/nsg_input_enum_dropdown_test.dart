import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class _Choice extends NsgEnum {
  _Choice(dynamic value, String name) : super(value: value, name: name);
  @override
  void initialize() {
    NsgEnum.listAllValues[runtimeType] = {0: _Choice(0, 'Normal'), 1: _Choice(1, 'Bold'), 2: _Choice(2, 'Heavy')};
  }
}

class _Record extends NsgDataItem {
  @override
  String get typeName => 'DropdownTestRecord';
  @override
  void initialize() {
    addField(NsgDataStringField('id'), primaryKey: true);
    addField(NsgDataEnumReferenceField<_Choice>('weight'));
  }
  @override
  NsgDataItem getNewObject() => _Record();
}

void main() {
  Future<_Record> pumpInput(WidgetTester tester, {bool disabled = false, List<NsgDataItem>? choices,
    void Function(NsgDataItem)? changed, void Function(NsgDataItem, String)? complete}) async {
    _Choice(0, '').initialize();
    NsgDataClient.client.registerDataItem(_Record());
    final row = _Record()..newRecord();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Align(alignment: Alignment.topLeft,
      child: SizedBox(width: 240, child: NsgInput(dataItem: row, fieldName: 'weight', enumDropdown: true,
        disabled: disabled, label: 'Weight', showDeleteIcon: false, itemsToSelect: choices,
        onChanged: changed, onEditingComplete: complete)),
    ))));
    return row;
  }

  testWidgets('enum dropdown applies choice immediately and calls callbacks once', (tester) async {
    var changes = 0;
    var completions = 0;
    final row = await pumpInput(tester, changed: (_) => changes++, complete: (_, _) => completions++);
    final bottom = tester.getBottomLeft(find.byType(TextFormField)).dy;
    final inputRect = tester.getRect(find.byType(TextFormField));
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<NsgDataItem>), findsNWidgets(3));
    expect(tester.getRect(find.byType(TextFormField)), inputRect);
    expect(tester.getTopLeft(find.byType(PopupMenuItem<NsgDataItem>).first).dy, closeTo(bottom - 1, 0.01));
    expect(find.byIcon(Icons.check), findsNothing);
    expect(tester.widget<Text>(find.text('Normal').last).style?.color, nsgtheme.nsgInputDynamicListTextSelectedColor);
    expect(tester.widget<Text>(find.text('Bold')).style?.color, nsgtheme.nsgInputDynamicListTextColor);
    await tester.tap(find.text('Bold'));
    await tester.pumpAndSettle();
    expect(row.getFieldValue('weight'), 1);
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text, 'Bold');
    expect(changes, 1);
    expect(completions, 1);
  });

  testWidgets('restricted enum choices and cancellation preserve value', (tester) async {
    final row = await pumpInput(tester, choices: [_Choice(1, 'Bold')]);
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<NsgDataItem>), findsOneWidget);
    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(row.getFieldValue('weight'), 0);
  });

  testWidgets('arrow keys navigate dropdown and Enter confirms', (tester) async {
    final row = await pumpInput(tester);
    await tester.tap(find.byType(TextFormField), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(row.getFieldValue('weight'), 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<NsgDataItem>), findsNothing);
    expect(row.getFieldValue('weight'), 2);
  });

  testWidgets('popup survives anchor replacement before its first layout', (tester) async {
    final row = await pumpInput(tester);
    await tester.tap(find.byType(TextFormField), warnIfMissed: false);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(PopupMenuItem<NsgDataItem>), findsNWidgets(3));
    await tester.tap(find.text('Bold'));
    await tester.pumpAndSettle();
    expect(row.getFieldValue('weight'), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled enum does not open dropdown', (tester) async {
    await pumpInput(tester, disabled: true);
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<NsgDataItem>), findsNothing);
  });
}
