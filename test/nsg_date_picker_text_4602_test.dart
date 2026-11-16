import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_controls/formfields/nsg_user_date.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';

void main() {
  setUpAll(() {
    ControlOptions.instance = ControlOptions(
      colorMainBack: Colors.white,
      colorText: Colors.black,
      colorTertiary: Colors.blue,
    );
  });
  tearDown(() => NsgUserDate.install(NsgUserDate.legacy()));

  for (final legacy in [true, false]) {
    for (final sample in [
      (0, 2, '25.11.2026', DateTime(2026, 11, 25)),
      (3, 5, '13.12.2026', DateTime(2026, 12, 13)),
      (6, 10, '13.11.2027', DateTime(2027, 11, 13)),
    ]) {
      testWidgets('текст даты: legacy=$legacy замена сегмента ${sample.$1}', (
        tester,
      ) async {
        NsgUserDate.install(
          legacy
              ? NsgUserDate.legacy()
              : NsgUserDate.resolve(
                  appLanguage: const Locale('ru'),
                  deviceLocales: const [Locale('ru', 'RU')],
                  mobile: false,
                  alwaysUse24Hour: true,
                ),
        );
        var selected = DateTime(2026, 11, 13);
        DateTime? confirmed;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NsgPopUp(
                title: 'Дата окончания',
                height: 520,
                popOnConfirm: false,
                onConfirm: () => confirmed = selected,
                getContent: () => [
                  DatePickerContent(
                    initialTime: DateTime(2026, 11, 13),
                    firstDateTime: DateTime(2020),
                    lastDateTime: DateTime(2030),
                    textAlign: TextAlign.center,
                    onChange: (date) => selected = date,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.showKeyboard(find.byType(TextFormField));
        // Передаём реальное выделение и замену через TextInput, а не enterText,
        // который всегда оставляет курсор в конце и скрывал старый дефект.
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: '13.11.2026',
            selection: TextSelection(
              baseOffset: sample.$1,
              extentOffset: sample.$2,
            ),
          ),
        );
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: sample.$3,
            selection: TextSelection.collapsed(offset: sample.$2),
          ),
        );
        await tester.pump();
        await tester.pump();

        final edit = tester.widget<EditableText>(find.byType(EditableText));
        expect(edit.controller.text, sample.$3);
        expect(selected, sample.$4);
        await tester.tap(find.byIcon(Icons.check));
        await tester.pump();
        expect(confirmed, sample.$4);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'после календаря маска сохраняет выбранный день при наборе месяца',
    (tester) async {
      NsgUserDate.install(NsgUserDate.legacy());
      DateTime? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerContent(
              initialTime: DateTime(2026, 11, 13),
              textAlign: TextAlign.center,
              onChange: (date) => selected = date,
            ),
          ),
        ),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label?.startsWith('8,') == true,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(selected, DateTime(2026, 11, 8));
      await tester.showKeyboard(find.byType(TextFormField));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '08.11.2026',
          selection: TextSelection(baseOffset: 3, extentOffset: 5),
        ),
      );
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '08.12.2026',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '08.12.2026',
      );
      expect(selected, DateTime(2026, 12, 8));
      expect(tester.takeException(), isNull);
    },
  );
}
