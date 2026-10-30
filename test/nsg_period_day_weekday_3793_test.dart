import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nsg_controls/formfields/nsg_period_picker.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/nsg_data.dart';

const _locales = [Locale('ru'), Locale('en'), Locale('ms'), Locale('th')];
const _dates = {
  'ru': '26.10.2026, пн',
  'en': '10/26/2026, Mon',
  'ms': '26/10/2026, Isn',
  'th': '26/10/2026, จ.',
};

Widget app(Locale locale, WidgetBuilder builder, {double textScale = 1}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: _locales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(child: Builder(builder: builder)),
      ),
    );

void main() {
  setUpAll(() async {
    ControlOptions.instance = ControlOptions();
    await initializeDateFormatting();
  });

  for (final entry in _dates.entries) {
    for (final width in [240.0, 320.0, 600.0]) {
      testWidgets(
        'actual day widget ${entry.key} is readable at width $width',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 300);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          await tester.pumpWidget(
            app(
              Locale(entry.key),
              (context) => NsgPeriodWidget(
                context: context,
                period: NsgTypedPeriod.day(DateTime(2026, 10, 26)),
                periodGranularity: NsgPeriodGranularity.day,
                selected: true,
                label: 'Day',
              ),
            ),
          );
          await tester.pumpAndSettle();
          final finder = find.text(entry.value);
          expect(finder, findsOneWidget);
          final paragraph = tester.renderObject<RenderParagraph>(finder);
          final painter = TextPainter(
            text: paragraph.text,
            textDirection: paragraph.textDirection,
            textScaler: paragraph.textScaler,
            locale: paragraph.locale,
          )..layout(maxWidth: paragraph.size.width);
          expect(
            painter.height,
            lessThanOrEqualTo(paragraph.size.height + .01),
            reason:
                'the complete date and weekday fit without vertical clipping',
          );
          final textRect = tester.getRect(finder);
          expect(
            textRect.left,
            greaterThanOrEqualTo(
              tester.getRect(find.byIcon(Icons.chevron_left_rounded)).right,
            ),
          );
          expect(
            textRect.right,
            lessThanOrEqualTo(
              tester.getRect(find.byIcon(Icons.chevron_right_rounded)).left,
            ),
          );
          expect(
            textRect.height,
            lessThanOrEqualTo(painter.height + .01),
            reason: 'wide fields must not enlarge the text',
          );
          painter.dispose();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('large text still fits the fixed-height day row', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      app(
        const Locale('ru'),
        (context) => NsgPeriodWidget(
          context: context,
          period: NsgTypedPeriod.day(DateTime(2026, 10, 26)),
          periodGranularity: NsgPeriodGranularity.day,
          selected: true,
        ),
        textScale: 1.8,
      ),
    );
    await tester.pumpAndSettle();
    final text = find.text(_dates['ru']!);
    expect(text, findsOneWidget);
    final textRect = tester.getRect(text);
    final rowRect = tester.getRect(find.byType(NsgPeriodWidget));
    expect(textRect.height, lessThanOrEqualTo(rowRect.height));
    expect(
      textRect.left,
      greaterThanOrEqualTo(
        tester.getRect(find.byIcon(Icons.chevron_left_rounded)).right,
      ),
    );
    expect(
      textRect.right,
      lessThanOrEqualTo(
        tester.getRect(find.byIcon(Icons.chevron_right_rounded)).left,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('arrows update both date and weekday', (tester) async {
    var period = NsgTypedPeriod.day(DateTime(2026, 10, 26));
    await tester.pumpWidget(
      app(
        const Locale('en'),
        (context) => StatefulBuilder(
          builder: (context, setState) => NsgPeriodWidget(
            context: context,
            period: period,
            periodGranularity: NsgPeriodGranularity.day,
            onChanged: (next, _) => setState(() => period = next),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_dates['en']!), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('10/27/2026, Tue'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text(_dates['en']!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('locale follows widget context when application locale changes', (
    tester,
  ) async {
    final locale = ValueNotifier(const Locale('ru'));
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (_, value, _) => app(
          value,
          (context) => NsgPeriodWidget(
            context: context,
            period: NsgTypedPeriod.day(DateTime(2026, 10, 26)),
            periodGranularity: NsgPeriodGranularity.day,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_dates['ru']!), findsOneWidget);
    locale.value = const Locale('en');
    await tester.pumpAndSettle();
    expect(find.text(_dates['en']!), findsOneWidget);
    expect(find.text(_dates['ru']!), findsNothing);
  });

  testWidgets('all other granularities keep the existing SDK text', (
    tester,
  ) async {
    for (final granularity in NsgPeriodGranularity.values.where(
      (type) => type != NsgPeriodGranularity.day,
    )) {
      final period = NsgTypedPeriod.day(DateTime(2026, 10, 26));
      final expected = period.changeType(granularity).dateText(false, 'en');
      await tester.pumpWidget(
        app(
          const Locale('en'),
          (context) => NsgPeriodWidget(
            context: context,
            period: period,
            periodGranularity: granularity,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget, reason: '$granularity');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('explicit text is preserved for day and week', (tester) async {
    for (final granularity in [
      NsgPeriodGranularity.day,
      NsgPeriodGranularity.week,
    ]) {
      await tester.pumpWidget(
        app(
          const Locale('en'),
          (context) => NsgPeriodWidget(
            context: context,
            period: NsgTypedPeriod.day(DateTime(2026, 10, 26)),
            periodGranularity: granularity,
            timeText: 'Application-defined period',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Application-defined period'), findsOneWidget);
      expect(find.textContaining('Mon'), findsNothing);
    }
  });
}
