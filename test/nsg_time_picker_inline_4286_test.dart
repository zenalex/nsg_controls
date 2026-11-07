import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/formfields/nsg_time_picker.dart';
import 'package:nsg_controls/formfields/nsg_user_date.dart';

void main() {
  tearDown(() => NsgUserDate.install(NsgUserDate.legacy()));
  testWidgets('desktop edits inline: 0950 Backspace 5 then 0', (tester) async {
    final saved = <Duration>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NsgTimePicker(
      initialTime: const Duration(hours: 9, minutes: 50), onClose: saved.add,
    ))));
    expect(find.byType(TextFormField), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '0950');
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    var field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, '095');
    expect(field.controller!.selection.baseOffset, 3);
    expect(saved, isEmpty);
    await tester.enterText(find.byType(TextFormField), '0955');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(saved.last, const Duration(hours: 9, minutes: 55));
    await tester.enterText(find.byType(TextFormField), '0950');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(saved.last, const Duration(hours: 9, minutes: 50));
    expect(find.byType(Dialog), findsNothing);
  });
  testWidgets('invalid boundary and incomplete time never save on blur', (tester) async {
    final saved = <Duration>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: [
      NsgTimePicker(initialTime: const Duration(hours: 9), onClose: saved.add),
      const TextField(key: ValueKey('other')),
    ]))));
    for (final text in ['24:00', '12:60', '095']) {
      await tester.enterText(find.byType(TextFormField), text);
      await tester.tap(find.byKey(const ValueKey('other')));
      await tester.pump();
      expect(saved, isEmpty);
    }
    await tester.enterText(find.byType(TextFormField), '0950');
    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pump();
    expect(saved, [const Duration(hours: 9, minutes: 50)]);
  });

  testWidgets('validator rejection keeps input and accepts once through onValidTime', (tester) async {
    final closed = <Duration>[];
    final valid = <Duration>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NsgTimePicker(
      initialTime: const Duration(hours: 9), onClose: closed.add,
      validator: (time) => time.inMinutes >= 600, onValidTime: valid.add,
    ))));
    await tester.enterText(find.byType(TextFormField), '0950');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(valid, isEmpty);
    await tester.enterText(find.byType(TextFormField), '1050');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(valid, [const Duration(hours: 10, minutes: 50)]);
    expect(closed, isEmpty);
  });

  testWidgets('localized 12 hour input preserves period', (tester) async {
    NsgUserDate.install(NsgUserDate.resolve(appLanguage: const Locale('en'),
      deviceLocales: const [Locale('en', 'US')], mobile: false, alwaysUse24Hour: false));
    final saved = <Duration>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NsgTimePicker(
      initialTime: const Duration(hours: 9), onClose: saved.add,
    ))));
    await tester.enterText(find.byType(TextFormField), '3:50 PM');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(saved, [const Duration(hours: 15, minutes: 50)]);
  });

}
