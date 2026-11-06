import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/formfields/nsg_field_type.dart';
import 'package:nsg_data/nsg_data.dart';

class _Record extends NsgDataItem {
  @override
  String get typeName => 'InputThemeRecord';
  @override
  void initialize() {
    addField(NsgDataStringField('id'), primaryKey: true);
    addField(NsgDataStringField('name'));
  }

  @override
  NsgDataItem getNewObject() => _Record();
}

void main() {
  setUpAll(() => NsgDataClient.client.registerDataItem(_Record()));

  Future<_Record> mount(
    WidgetTester tester, {
    NsgInputTheme? theme,
    TextFormFieldType border = TextFormFieldType.outlineInputBorder,
    TextStyle? textStyle,
    TextStyle? labelStyle,
    Color? labelColor,
    Color? borderColor,
    bool disabled = false,
    String? hint,
    Widget? labelWidget,
    void Function(NsgDataItem)? changed,
    Key? inputKey,
  }) async {
    final row = _Record()..newRecord();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [if (theme != null) theme]),
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: NsgInput(
              key: inputKey,
              dataItem: row,
              fieldName: 'name',
              label: 'Имя',
              showLabel: true,
              textFormFieldType: border,
              textStyle: textStyle,
              labelTextStyle: labelStyle,
              labelColor: labelColor,
              borderColor: borderColor,
              disabled: disabled,
              hint: hint,
              labelWidget: labelWidget,
              onChanged: changed,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return row;
  }

  TextField field(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));
  TextStyle label(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(of: find.byType(NsgInput), matching: find.byType(Text)),
      )
      .first
      .style!;

  for (final border in [
    TextFormFieldType.outlineInputBorder,
    TextFormFieldType.underlineInputBorder,
  ]) {
    testWidgets('legacy colors and geometry without extension $border', (
      tester,
    ) async {
      await mount(tester, border: border);
      final f = field(tester);
      expect(f.style!.color, nsgtheme.nsgInputTextColor);
      expect(label(tester).color, nsgtheme.nsgInputColorLabel);
      expect(
        tester.widget<Text>(find.text('Имя').last).style!.color,
        nsgtheme.nsgInputHintColor,
      );
      expect(
        f.decoration!.enabledBorder!.borderSide.color,
        nsgtheme.nsgInputBorderColor,
      );
      expect(
        f.decoration!.focusedBorder!.borderSide.color,
        ControlOptions.instance.colorMain,
      );
      expect(
        f.decoration!.errorBorder!.borderSide.color,
        ControlOptions.instance.colorError,
      );
      expect(f.decoration!.focusedBorder!.borderSide.width, 1);
    });
    for (final dark in [false, true]) {
      testWidgets('opt-in colors, input binding and focus $border dark=$dark', (
        tester,
      ) async {
        final ink = dark ? Colors.white : Colors.black;
        final muted = dark ? Colors.white70 : Colors.black54;
        final focus = dark ? Colors.purpleAccent : Colors.deepPurple;
        final t = NsgInputTheme(
          textColor: ink,
          labelColor: ink,
          hintColor: muted,
          borderColor: muted,
          focusedBorderColor: focus,
        );
        var changes = 0;
        final row = await mount(
          tester,
          theme: t,
          border: border,
          changed: (_) => changes++,
        );
        final f = field(tester);
        final rect = tester.getRect(find.byType(TextFormField));
        expect(f.style!.color, ink);
        expect(label(tester).color, ink);
        expect(tester.widget<Text>(find.text('Имя').last).style!.color, muted);
        expect(f.decoration!.enabledBorder!.borderSide.color, muted);
        expect(f.decoration!.disabledBorder!.borderSide.color, muted);
        expect(f.decoration!.focusedBorder!.borderSide.color, focus);
        expect(
          f.decoration!.errorBorder!.borderSide.color,
          ControlOptions.instance.colorError,
        );
        expect(
          f.decoration!.focusedErrorBorder!.borderSide.color,
          ControlOptions.instance.colorError,
        );
        await tester.enterText(find.byType(TextFormField), 'Иван');
        await tester.pump();
        expect(row.getFieldValue('name'), 'Иван');
        expect(changes, 1);
        final state = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(state.renderEditable.text!.style!.color, ink);
        expect(state.widget.focusNode.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        expect(tester.getSize(find.byType(TextFormField)), rect.size);
      });
    }
  }
  testWidgets(
    'partial extension falls back per slot; disabled field stays readonly',
    (tester) async {
      await mount(
        tester,
        theme: const NsgInputTheme(hintColor: Colors.orange),
        disabled: true,
      );
      final f = field(tester);
      expect(f.readOnly, isTrue);
      expect(f.style!.color, nsgtheme.nsgInputTextColor);
      expect(label(tester).color, nsgtheme.nsgInputColorLabel);
      expect(
        tester.widget<Text>(find.text('Имя').last).style!.color,
        Colors.orange,
      );
      expect(
        f.decoration!.enabledBorder!.borderSide.color,
        nsgtheme.nsgInputBorderColor,
      );
      expect(
        f.decoration!.focusedBorder!.borderSide.color,
        ControlOptions.instance.colorMain,
      );
    },
  );
  testWidgets('explicit widget colors and whole styles retain priority', (
    tester,
  ) async {
    const style = TextStyle(
      color: Colors.red,
      fontSize: 23,
      fontWeight: FontWeight.bold,
    );
    const labelStyle = TextStyle(color: Colors.green, fontSize: 19);
    await mount(
      tester,
      theme: const NsgInputTheme(
        textColor: Colors.blue,
        labelColor: Colors.blue,
        hintColor: Colors.blue,
        borderColor: Colors.blue,
      ),
      textStyle: style,
      labelStyle: labelStyle,
      labelColor: Colors.yellow,
      borderColor: Colors.pink,
    );
    expect(field(tester).style, style);
    expect(label(tester), labelStyle);
    expect(tester.widget<Text>(find.text('Имя').last).style, labelStyle);
    expect(
      field(tester).decoration!.enabledBorder!.borderSide.color,
      Colors.pink,
    );
  });
  testWidgets('foreground Paint and custom label remain exact', (tester) async {
    final paint = Paint()..color = Colors.red;
    final style = TextStyle(foreground: paint, fontSize: 22);
    const custom = Text(
      'Собственная подпись',
      style: TextStyle(color: Colors.green),
    );
    await mount(
      tester,
      theme: const NsgInputTheme(
        textColor: Colors.blue,
        labelColor: Colors.blue,
      ),
      textStyle: style,
      labelWidget: custom,
    );
    expect(identical(field(tester).style!.foreground, paint), isTrue);
    expect(find.byWidget(custom), findsWidgets);
  });
  testWidgets(
    'labelColor override and explicit hint use separate semantic slots',
    (tester) async {
      await mount(
        tester,
        theme: const NsgInputTheme(
          labelColor: Colors.blue,
          hintColor: Colors.green,
        ),
        labelColor: Colors.red,
        hint: 'Введите имя',
      );
      expect(label(tester).color, Colors.red);
      expect(
        tester.widget<Text>(find.text('Введите имя')).style!.color,
        Colors.green,
      );
    },
  );
  testWidgets(
    'opt-in preserves geometry and typography in empty and typed states',
    (tester) async {
      Future<List<Object?>> measure(NsgInputTheme? theme) async {
        await tester.pumpWidget(const SizedBox());
        await mount(tester, theme: theme);
        final empty = tester.getRect(find.byType(TextFormField));
        final style = field(tester).style!;
        final decoration = field(tester).decoration!;
        await tester.enterText(find.byType(TextFormField), 'Иван');
        await tester.pump();
        return [
          empty,
          tester.getRect(find.byType(TextFormField)),
          style.fontSize,
          style.fontWeight,
          style.height,
          decoration.contentPadding,
          (decoration.enabledBorder! as OutlineInputBorder).borderRadius,
        ];
      }

      final legacy = await measure(null);
      final themed = await measure(
        const NsgInputTheme(
          textColor: Colors.white,
          labelColor: Colors.white,
          hintColor: Colors.white70,
          borderColor: Colors.white70,
          focusedBorderColor: Colors.purpleAccent,
        ),
      );
      expect(themed, legacy);
    },
  );
  test('extension copy and interpolation retain nullable slots', () {
    const t = NsgInputTheme(
      textColor: Colors.black,
      focusedBorderColor: Colors.red,
    );
    final copy = t.copyWith(hintColor: Colors.green);
    expect(copy.textColor, Colors.black);
    expect(copy.hintColor, Colors.green);
    expect(copy.borderColor, isNull);
    expect(t.lerp(null, .5), same(t));
    expect(
      t.lerp(const NsgInputTheme(textColor: Colors.white), .5).textColor,
      Color.lerp(Colors.black, Colors.white, .5),
    );
  });
}
