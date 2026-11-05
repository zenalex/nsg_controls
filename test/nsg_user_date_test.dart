import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_controls/formfields/nsg_time_picker.dart';
import 'package:nsg_controls/formfields/nsg_user_date.dart';

void main() {
  tearDown(() => NsgUserDate.install(NsgUserDate.legacy()));

  final ru = NsgUserDate.resolve(
    appLanguage: const Locale('ru'),
    deviceLocales: const [Locale('ru', 'RU')],
    mobile: false,
    alwaysUse24Hour: true,
  );
  final ruUs = NsgUserDate.resolve(
    appLanguage: const Locale('ru'),
    deviceLocales: const [Locale('en', 'US')],
    mobile: false,
    alwaysUse24Hour: true,
  );
  final enUs = NsgUserDate.resolve(
    appLanguage: const Locale('en'),
    deviceLocales: const [Locale('en', 'US')],
    mobile: false,
    alwaysUse24Hour: false,
  );
  final enGb = NsgUserDate.resolve(
    appLanguage: const Locale('en'),
    deviceLocales: const [Locale('en', 'GB')],
    mobile: false,
    alwaysUse24Hour: true,
  );
  final th = NsgUserDate.resolve(
    appLanguage: const Locale('th'),
    deviceLocales: const [Locale('th', 'TH')],
    mobile: false,
    alwaysUse24Hour: true,
  );
  final enPhone24 = NsgUserDate.resolve(
    appLanguage: const Locale('en'),
    deviceLocales: const [Locale('en', 'US')],
    mobile: true,
    alwaysUse24Hour: true,
  );
  final enNoRegion = NsgUserDate.resolve(
    appLanguage: const Locale('en'),
    deviceLocales: const [Locale('en')],
    mobile: false,
    alwaysUse24Hour: false,
  );

  DateTime day(int year, int month, int day, [int hour = 0, int minute = 0]) => DateTime(year, month, day, hour, minute);

  test('ru остаётся день.месяц и 24 часа, ru_US не переставляет месяц', () {
    final value = day(2026, 11, 3, 15, 30);
    expect(ru.formatDate(value), '03.11.2026');
    expect(ru.formatTime(value), '15:30');
    expect(ru.formatDateTime(value), '03.11.2026 15:30');
    expect(ru.tryParseDate('03.11.2026'), day(2026, 11, 3));
    expect(ru.tryParseDate('03.11.2026'), isNot(day(2026, 3, 11)));
    expect(ruUs.formatDate(value), '03.11.2026');
    expect(ruUs.formatTime(value), '15:30');
    expect(ru.formatShortDate(value), '03.11.26');
  });

  test('en_US месяц первым, en_GB день первым, точки en_US не читает', () {
    final november = day(2026, 11, 3, 15, 30);
    final march = day(2026, 3, 11);
    expect(enUs.formatDate(november), '11/3/2026');
    expect(enUs.formatDate(day(2026, 11, 5, 15, 30)), '11/5/2026');
    expect(enUs.tryParseDate('11/3/2026'), day(2026, 11, 3));
    expect(enUs.tryParseDate('3/11/2026'), march);
    expect(enUs.tryParseDate('03.11.2026'), isNull);
    expect(enGb.formatDate(november), '03/11/2026');
    expect(enGb.formatTime(november), '15:30');
    expect(enGb.tryParseDate('03/11/2026'), day(2026, 11, 3));
    expect(enGb.tryParseDate('11/05/2026'), day(2026, 5, 11));
    expect(enGb.tryParseDate('03.11.2026'), isNull);
  });

  test('th 3/11 — 3 ноября 2026, не буддийский год и не 11 марта', () {
    final value = day(2026, 11, 3, 15, 30);
    expect(th.formatDate(value), '3/11/2026');
    expect(th.tryParseDate('3/11/2026'), day(2026, 11, 3));
    expect(th.tryParseDate('3/11/2026')!.year, 2026);
    expect(th.tryParseDate('11/3/2026'), day(2026, 3, 11));
    expect(th.tryParseTime('15:30'), day(1970, 1, 1, 15, 30));
    expect(th.tryParseTime('15:30 น.'), day(1970, 1, 1, 15, 30));
  });

  test('круг format-parse-format для четырёх локалей', () {
    final value = day(2026, 11, 5, 15, 30);
    for (final user in [ru, enUs, enGb, th]) {
      final dateText = user.formatDate(value);
      expect(user.formatDate(user.tryParseDate(dateText)!), dateText);
      final timeText = user.formatTime(value);
      expect(user.formatTime(user.tryParseTime(timeText)!), timeText);
    }
  });

  test('12 часов: обычный пробел, 15:30 и отказ на неоднозначном', () {
    expect(enUs.formatTime(day(2026, 11, 5, 15, 30)), contains('PM'));
    expect(enUs.tryParseTime('3:30 PM'), day(1970, 1, 1, 15, 30));
    expect(enUs.tryParseTime('3:30\u202fPM'), day(1970, 1, 1, 15, 30));
    expect(enUs.tryParseTime('15:30'), day(1970, 1, 1, 15, 30));
    expect(enUs.tryParseTime('3:30'), isNull);
    expect(enUs.tryParseTime('15:30 PM'), isNull);
    expect(enUs.tryParseTime('25:00'), isNull);
    expect(enUs.tryParseTime('3:30 pm'), day(1970, 1, 1, 15, 30));
  });

  test('телефонный 24-часовой флаг важнее en_US, пустой регион не месяц-день', () {
    expect(enPhone24.formatTime(day(2026, 11, 5, 15, 30)), '15:30');
    expect(enPhone24.use24Hour, isTrue);
    expect(enNoRegion.formatDate(day(2026, 11, 3)), '03.11.2026');
    expect(enNoRegion.formatTime(day(2026, 11, 3, 15, 30)), '15:30');
    expect(enNoRegion.tryParseDate('11/3/2026'), isNull);
  });

  test('служебный шаблон yyyy-MM-dd не становится локальным', () {
    final text = ru.formatWithPreset(day(2026, 11, 3), 'yyyy-MM-dd');
    expect(text, '2026-11-03');
  });

  Future<DateTime?> pumpDate(WidgetTester tester, NsgUserDate user, String typed) async {
    NsgUserDate.install(user);
    DateTime? got;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DatePickerContent(
            initialTime: DateTime(2026, 11, 1),
            textAlign: TextAlign.center,
            onChange: (value) => got = value,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), typed);
    await tester.pump();
    return got;
  }

  testWidgets('десктоп ru: 03.11.2026 это 3 ноября', (tester) async {
    final got = await pumpDate(tester, ru, '03.11.2026');
    expect(got, DateTime(2026, 11, 3));
  });

  testWidgets('десктоп en_US: 03.11.2026 не становится 11 марта', (tester) async {
    final got = await pumpDate(tester, enUs, '03.11.2026');
    expect(got, isNot(DateTime(2026, 3, 11)));
    expect(got, isNot(DateTime(2026, 11, 3)));
  });

  testWidgets('десктоп en_US читает 11/3/2026 как 3 ноября', (tester) async {
    final got = await pumpDate(tester, enUs, '11/3/2026');
    expect(got, DateTime(2026, 11, 3));
  });

  testWidgets('мобильное время не принимает набор в текстовое поле', (tester) async {
    NsgUserDate.install(enPhone24);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimePickerContent(initialTime: DateTime(2026, 11, 5, 15, 30), onChange: (_) {}),
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.readOnly, isTrue);
    expect(find.text('15:30'), findsOneWidget);
    NsgUserDate.install(NsgUserDate.legacy());
  });
}
