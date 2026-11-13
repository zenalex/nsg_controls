import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class _Phone extends NsgDataItem {
  @override
  String get typeName => 'Phone4584';
  @override
  void initialize() {
    addField(NsgDataStringField('id'), primaryKey: true);
    addField(NsgDataStringField('code'));
  }

  @override
  NsgDataItem getNewObject() => _Phone();
}

void main() {
  setUpAll(() => NsgDataClient.client.registerDataItem(_Phone()));
  late _Phone item;
  late StateSetter rebuild;
  String? initial;
  List<String>? allowed;
  bool disabled = false;
  var changes = 0;
  setUp(() {
    item = _Phone()..newRecord();
    initial = null;
    allowed = ['RU', 'KZ', 'IN', 'TH', 'MY', 'KG'];
    disabled = false;
    changes = 0;
  });
  String code() => item.getFieldValue('code').toString();
  TextFormField field(WidgetTester tester) =>
      tester.widget(find.byType(TextFormField));
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, state) {
              rebuild = state;
              return Center(
                child: SizedBox(
                  width: 140,
                  child: NsgInput(
                    label: 'Код страны',
                    dataItem: item,
                    fieldName: 'code',
                    inputType: NsgInputType.phoneCode,
                    countryCodeInitial: initial,
                    countryCodes: allowed,
                    disabled: disabled,
                    onChanged: (_) => changes++,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final entry in {
    'RU': '7',
    'IN': '91',
    'TH': '66',
    'MY': '60',
    'KG': '996',
  }.entries) {
    testWidgets(
      'initial ${entry.key} displays ${entry.value} and writes ISO once',
      (tester) async {
        initial = entry.key;
        await mount(tester);
        expect(code(), entry.key);
        expect(field(tester).controller!.text, entry.value);
        expect(changes, 1);
        rebuild(() {});
        await tester.pump();
        expect(changes, 1);
      },
    );
  }

  testWidgets(
    'digits, filtering, incomplete input and rebuild keep ISO contract',
    (tester) async {
      await mount(tester);
      final input = find.byType(TextFormField);
      await tester.enterText(input, '+9a1');
      await tester.pump();
      expect(field(tester).controller!.text, '91');
      expect(code(), 'IN');
      await tester.enterText(input, '9');
      await tester.pump();
      expect(code(), '');
      rebuild(() {});
      await tester.pump();
      expect(field(tester).controller!.text, '9');
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      await tester.enterText(input, '996');
      await tester.pump();
      expect(code(), 'KG');
    },
  );

  testWidgets('clear stays cleared across initial-country updates', (
    tester,
  ) async {
    initial = 'IN';
    await mount(tester);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(code(), '');
    rebuild(() => initial = 'TH');
    await tester.pump();
    expect(code(), '');
    expect(field(tester).controller!.text, '');
  });

  testWidgets('late initial country initializes once', (tester) async {
    await mount(tester);
    expect(code(), '');
    rebuild(() => initial = 'IN');
    await tester.pumpAndSettle();
    expect(code(), 'IN');
    expect(changes, 1);
  });

  testWidgets(
    'enabling an initially disabled empty field applies the hint once',
    (tester) async {
      initial = 'IN';
      disabled = true;
      await mount(tester);
      expect(code(), '');
      rebuild(() => disabled = false);
      await tester.pumpAndSettle();
      expect(code(), 'IN');
      expect(changes, 1);
    },
  );

  testWidgets(
    'replacing the data item does not carry clear intent to another user',
    (tester) async {
      initial = 'IN';
      await mount(tester);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      final previous = item;
      rebuild(() {
        item = _Phone()..newRecord();
        initial = 'TH';
      });
      await tester.pumpAndSettle();
      expect(previous.getFieldValue('code'), '');
      expect(code(), 'TH');
      expect(field(tester).controller!.text, '66');
    },
  );

  testWidgets(
    'shared +7 preserves KZ and external ISO changes refresh display',
    (tester) async {
      item.setFieldValue('code', 'KZ');
      initial = 'RU';
      await mount(tester);
      expect(code(), 'KZ');
      await tester.enterText(find.byType(TextFormField), '7');
      await tester.pump();
      expect(code(), 'KZ');
      rebuild(() => item.setFieldValue('code', 'MY'));
      await tester.pump();
      expect(field(tester).controller!.text, '60');
    },
  );

  testWidgets('picker filters countries, selection and clear update model', (
    tester,
  ) async {
    allowed = ['IN', 'TH'];
    await mount(tester);
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('nsg-phone-country-RU')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('nsg-phone-country-TH')));
    await tester.pumpAndSettle();
    expect(code(), 'TH');
    expect(field(tester).controller!.text, '66');
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), '7');
    await tester.pump();
    expect(
      code(),
      '',
      reason: 'excluded countries cannot be entered by dial code',
    );
  });

  testWidgets('country list scrolls down and back up', (tester) async {
    allowed = null;
    await mount(tester);
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    final scrolling = find
        .descendant(of: list, matching: find.byType(Scrollable))
        .first;
    final position = tester.state<ScrollableState>(scrolling).position;
    await tester.drag(list, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(0));
    await tester.drag(list, const Offset(0, 1500));
    await tester.pumpAndSettle();
    expect(position.pixels, 0);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
  });

  testWidgets('disabled field does not write or open the picker', (
    tester,
  ) async {
    item.setFieldValue('code', 'IN');
    disabled = true;
    await mount(tester);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
    expect(find.byIcon(Icons.clear), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    expect(code(), 'IN');
    expect(changes, 0);
  });
}
