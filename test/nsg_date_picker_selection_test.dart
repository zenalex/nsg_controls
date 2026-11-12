// NSG-SOFT/futbolista-tasks#4498.
//
// Тап по дню обновлял текст, а сетка после setState родителя
// снова подсвечивала день открытия: CalendarDatePicker получал
// новый GlobalKey и старый initialDateTime.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_controls/nsg_control_options.dart';

void main() {
  setUpAll(() {
    ControlOptions.instance = ControlOptions(
      colorMainBack: const Color(0xFF1C1B1F),
      colorText: const Color(0xFFFFFFFF),
      colorTertiary: const Color(0xFF7D8D99),
    );
  });

  testWidgets('выбранный день остаётся подсвечен после перестроения', (tester) async {
    final initial = DateTime(2026, 11, 1);
    DateTime? reported;
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: Scaffold(
          body: DatePickerContent(
            initialTime: initial,
            textAlign: TextAlign.center,
            onChange: (value) => reported = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_daySelected(tester, 1), isTrue);
    expect(_dayFill(tester, 1), isNotNull);

    await tester.tap(find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label?.startsWith('8,') == true));
    await tester.pump();
    await tester.pump();

    expect(reported?.year, 2026);
    expect(reported?.month, 11);
    expect(reported?.day, 8);
    expect(_daySelected(tester, 8), isTrue);
    expect(_daySelected(tester, 1), isFalse);
    final fill = _dayFill(tester, 8);
    expect(fill, isNotNull);
    expect(fill!.a, greaterThan(0.5));
  });
}

bool _daySelected(WidgetTester tester, int day) {
  final semantics = tester.widget<Semantics>(_daySemantics(day));
  return semantics.properties.selected == true;
}

Color? _dayFill(WidgetTester tester, int day) {
  final ink = find.descendant(of: _daySemantics(day), matching: find.byType(Ink));
  final decoration = tester.widget<Ink>(ink).decoration;
  if (decoration is ShapeDecoration) return decoration.color;
  return null;
}

Finder _daySemantics(int day) {
  return find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label?.startsWith('$day,') == true);
}
