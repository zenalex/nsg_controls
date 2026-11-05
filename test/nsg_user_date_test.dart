import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_controls/formfields/nsg_period_time_range_controls.dart';
import 'package:nsg_controls/formfields/nsg_time_picker.dart';
import 'package:nsg_controls/formfields/nsg_user_date.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';

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

  test('неизвестная пара en+регион не становится американским месяцем', () {
    for (final country in ['RU', 'TH', 'KZ', 'AE', 'UA', 'BY']) {
      final user = NsgUserDate.resolve(
        appLanguage: const Locale('en'),
        deviceLocales: [Locale('en', country)],
        mobile: false,
        alwaysUse24Hour: false,
      );
      expect(user.fixedDayMonth, isTrue, reason: country);
      expect(user.formatDate(day(2026, 11, 3)), '03.11.2026', reason: country);
      expect(user.tryParseDate('03/11/2026'), isNull, reason: country);
      expect(user.tryParseDate('03.11.2026'), day(2026, 11, 3), reason: country);
    }
  });

  test('ru на телефоне в 12-часовом режиме читает 09:30', () {
    final ruPhone12 = NsgUserDate.resolve(
      appLanguage: const Locale('ru'),
      deviceLocales: const [Locale('ru', 'RU')],
      mobile: true,
      alwaysUse24Hour: false,
    );
    expect(ruPhone12.use24Hour, isFalse);
    expect(ruPhone12.formatTime(day(2026, 11, 5, 9, 30)), '09:30');
    expect(ruPhone12.tryParseTime('09:30'), day(1970, 1, 1, 9, 30));
  });

  test('год из текста — четыре цифры в диапазоне, короткий и буддийский отвергаются', () {
    expect(ru.tryParseDate('03.11.26'), isNull);
    expect(ru.tryParseDate('03.11.2'), isNull);
    expect(ru.tryParseDate('03.11.2026'), day(2026, 11, 3));
    expect(th.tryParseDate('3/11/2569'), isNull);
  });

  test('явный формат не подменяется локалью и пустая дата не становится 00:00', () {
    final empty = DateTime.utc(1754, 1, 1);
    final sample = day(2026, 11, 3);
    expect(empty.format('HH:mm', 'ru'), '');
    expect(empty.format('HH:mm:ss', 'en'), '');
    expect(sample.format('', 'en'), '');
    expect(sample.format(null, 'ru'), DateFormat(ControlOptions.instance.dateformat, 'ru').format(sample));
    final weekday = sample.format('dd.MM.yy, EE', 'en');
    expect(weekday.toLowerCase(), contains('tue'));
    expect(enUs.formatWithPreset(sample, 'dd.MM.yyyy', fallbackLocale: 'en'), '03.11.2026');
    expect(enUs.formatWithPreset(sample, 'HH:mm', fallbackLocale: 'en'), '00:00');
    expect(enUs.formatWithPreset(empty, 'HH:mm'), '');
  });

  testWidgets('короткий год не вызывает onChange и показывает ошибку', (tester) async {
    final got = await pumpDate(tester, ru, '03.11.26');
    expect(got?.year, isNot(26));
    expect(got?.year, isNot(2));
    expect(tester.widget<TextField>(find.byType(TextField)).decoration!.errorText, isNotNull);
  });

  testWidgets('колесо ru в 12-часовом режиме отдаёт DateTime напрямую', (tester) async {
    final ruPhone12 = NsgUserDate.resolve(
      appLanguage: const Locale('ru'),
      deviceLocales: const [Locale('ru', 'RU')],
      mobile: true,
      alwaysUse24Hour: false,
    );
    NsgUserDate.install(ruPhone12);
    DateTime? got;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimePickerContent(initialTime: DateTime(2026, 11, 5, 15, 30), onChange: (value) => got = value),
        ),
      ),
    );
    final next = DateTime(2026, 11, 5, 9, 30);
    tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker)).onDateTimeChanged(next);
    await tester.pump();
    expect(got, next);
  });

  testWidgets('25:00 показывает ошибку и не подтверждает старое время', (tester) async {
    NsgUserDate.install(ru);
    var confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NsgPopUp(
            title: 'time',
            height: 360,
            popOnConfirm: false,
            onConfirm: () => confirmed = true,
            getContent: () => [TimePickerContent(initialTime: DateTime(2026, 11, 5, 15, 30), onChange: (_) {})],
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), '25:00');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).decoration!.errorText, isNotNull);
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();
    expect(confirmed, isFalse);
  });

  testWidgets('буква P переключает период и не дописывается в текст', (tester) async {
    NsgUserDate.install(enUs);
    DateTime? got;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimePickerContent(initialTime: DateTime(2026, 11, 5, 3, 30), onChange: (value) => got = value),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), '3:30 ');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), '3:30 P');
    await tester.pump();
    final text = tester.widget<EditableText>(find.byType(EditableText)).controller.text;
    expect(text.contains('PMM'), isFalse);
    expect(text.toUpperCase(), contains('PM'));
    expect(got?.hour, 15);
  });

  testWidgets('стрелка сегмента переключает AM/PM', (tester) async {
    NsgUserDate.install(enUs);
    DateTime? got;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimePickerContent(initialTime: DateTime(2026, 11, 5, 15, 30), onChange: (value) => got = value),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    expect(got?.hour, 3);
    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(got?.hour, 15);
  });

  testWidgets('поле диапазона принимает 1530, 15.30, 15-30 и 15', (tester) async {
    NsgUserDate.install(NsgUserDate.legacy());
    TimeOfDay? got;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NsgTimeOfDayWidget(time: const TimeOfDay(hour: 0, minute: 0), onChange: (value) => got = value),
        ),
      ),
    );
    for (final sample in ['1530', '15.30', '15-30', '15']) {
      got = null;
      await tester.enterText(find.byType(TextField), sample);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(got, TimeOfDay(hour: 15, minute: sample == '15' ? 0 : 30), reason: sample);
    }
    final legacyWidth = tester.getSize(find.byType(TextField)).width;
    expect(legacyWidth, 92);

    NsgUserDate.install(enUs);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NsgTimeOfDayWidget(time: const TimeOfDay(hour: 15, minute: 30), onChange: (_) {}),
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(TextField)).width, greaterThan(92));
  });
}
