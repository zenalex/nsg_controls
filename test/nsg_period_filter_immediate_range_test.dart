import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/formfields/nsg_period_filter.dart';
import 'package:nsg_controls/formfields/nsg_checkbox.dart';
import 'package:nsg_controls/localization/nsg_controls_localizations.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_popup.dart';
import 'package:nsg_data/nsg_data.dart';

void main() {
  setUpAll(() => ControlOptions.instance = ControlOptions());
  tearDown(Get.reset);

  NsgPeriod initialPeriod() {
    return NsgPeriod()
      ..beginDate = DateTime(2026, 1, 1)
      ..endDate = DateTime(2026, 12, 31, 23, 59, 59, 999)
      ..selectedType = NsgPeriodType.year;
  }

  Future<void> openPopup(
    WidgetTester tester, {
    required NsgPeriod source,
    required NsgPeriodRangePicker rangePicker,
    required List<NsgPeriod> drafts,
    required VoidCallback onConfirm,
    NsgDataController<NsgDataItem>? dataController,
    bool periodTimeEnabled = false,
    ValueChanged<NsgPeriod>? onSelect,
  }) async {
    final controller = dataController ?? NsgDataController<NsgDataItem>(requestOnInit: false);
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: NsgControlsLocalizations.localizationsDelegates,
        supportedLocales: NsgControlsLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => NsgPopUp(
                  title: 'Фильтр',
                  getContent: () => [
                    NsgPeriodFilterContent(
                      controller: controller,
                      period: source,
                      periodTimeEnabled: periodTimeEnabled,
                      rangePicker: rangePicker,
                      onSelect: onSelect ?? drafts.add,
                    ),
                  ],
                  onConfirm: onConfirm,
                ),
              ),
              child: const Text('Открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.byType(NsgPopUp), findsOneWidget);
  }

  Finder periodChip() => find.byWidgetPredicate(
    (widget) => widget is NsgCheckBox && widget.label == 'Период',
  );

  NsgPeriodRangePicker routedRangePicker(
    DateTimeRange result, {
    required VoidCallback onOpen,
  }) {
    return ({
      required context,
      required initialDateRange,
      required firstDate,
      required lastDate,
      barrierDismissible = true,
    }) {
      onOpen();
      return showDialog<DateTimeRange>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => AlertDialog(
          key: const Key('inner-range-picker'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(result),
              child: const Text('Подтвердить диапазон'),
            ),
          ],
        ),
      );
    };
  }

  testWidgets('range confirm applies once and closes inner and outer routes', (
    tester,
  ) async {
    final source = initialPeriod();
    final drafts = <NsgPeriod>[];
    var confirms = 0;
    var pickerCalls = 0;
    final start = DateTime(2026, 9, 2);
    final end = DateTime(2026, 9, 3);
    await openPopup(
      tester,
      source: source,
      drafts: drafts,
      onConfirm: () => confirms++,
      rangePicker: routedRangePicker(
        DateTimeRange(start: start, end: end),
        onOpen: () => pickerCalls++,
      ),
    );

    await tester.tap(periodChip());
    await tester.pumpAndSettle();

    expect(pickerCalls, 1);
    expect(find.byType(NsgPopUp), findsOneWidget);
    expect(find.byKey(const Key('inner-range-picker')), findsOneWidget);
    expect(confirms, 0);

    await tester.tap(find.text('Подтвердить диапазон'));
    await tester.pumpAndSettle();

    expect(confirms, 1);
    expect(drafts, hasLength(1));
    expect(drafts.last.beginDate, start);
    expect(drafts.last.endDate, DateTime(2026, 9, 3, 23, 59, 59, 999, 999));
    expect(find.byType(NsgPopUp), findsNothing);
    expect(find.text('Фильтр'), findsNothing);
  });

  testWidgets('range cancel keeps outer popup and original value untouched', (
    tester,
  ) async {
    final source = initialPeriod();
    final originalBegin = source.beginDate;
    final originalEnd = source.endDate;
    final drafts = <NsgPeriod>[];
    var confirms = 0;
    var pickerCalls = 0;
    final unusedResult = DateTimeRange(
      start: DateTime(2026, 9, 2),
      end: DateTime(2026, 9, 3),
    );
    await openPopup(
      tester,
      source: source,
      drafts: drafts,
      onConfirm: () => confirms++,
      rangePicker: routedRangePicker(unusedResult, onOpen: () => pickerCalls++),
    );

    await tester.tap(periodChip());
    await tester.pumpAndSettle();

    expect(pickerCalls, 1);
    expect(find.byKey(const Key('inner-range-picker')), findsOneWidget);
    expect(find.byType(NsgPopUp), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(confirms, 0);
    expect(find.byKey(const Key('inner-range-picker')), findsNothing);
    expect(find.byType(NsgPopUp), findsOneWidget);
    expect(source.beginDate, originalBegin);
    expect(source.endDate, originalEnd);
    expect(drafts, isEmpty);
  });

  testWidgets('range confirm preserves configured begin and end time', (tester) async {
    final source = NsgPeriod()
      ..beginDate = DateTime(2026, 1, 1, 10, 30)
      ..endDate = DateTime(2026, 1, 2, 12, 45)
      ..selectedType = NsgPeriodType.periodWidthTime;
    final selected = DateTimeRange(start: DateTime(2026, 9, 2), end: DateTime(2026, 9, 3));
    await openPopup(
      tester,
      source: source,
      drafts: <NsgPeriod>[],
      periodTimeEnabled: true,
      onConfirm: () {},
      rangePicker: routedRangePicker(selected, onOpen: () {}),
    );

    await tester.tap(periodChip());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подтвердить диапазон'));
    await tester.pumpAndSettle();

    expect(source.beginDate, DateTime(2026, 9, 2, 10, 30));
    expect(source.endDate, DateTime(2026, 9, 3, 12, 45));
    expect(source.selectedType, NsgPeriodType.periodWidthTime);
  });

  testWidgets('ordinary chips keep the existing OK flow', (tester) async {
    final source = initialPeriod();
    final drafts = <NsgPeriod>[];
    var confirms = 0;
    var pickerCalls = 0;
    await openPopup(
      tester,
      source: source,
      drafts: drafts,
      onConfirm: () => confirms++,
      rangePicker:
          ({
            required context,
            required initialDateRange,
            required firstDate,
            required lastDate,
            barrierDismissible = true,
          }) async {
            pickerCalls++;
            return null;
          },
    );

    final monthChip = find.byWidgetPredicate(
      (widget) => widget is NsgCheckBox && widget.label == 'Месяц',
    );
    await tester.tap(monthChip);
    await tester.pump();

    expect(pickerCalls, 0);
    expect(confirms, 0);
    expect(find.byType(NsgPopUp), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.byType(NsgPopUp), findsNothing);
    expect(confirms, 1);
  });

  testWidgets('outer cancel does not apply or mutate its source period', (
    tester,
  ) async {
    final customEntry = NsgPeriodCustomPeriod(
      name: 'Сезон 2026',
      beginDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
    );
    final source = initialPeriod()
      ..customPeriods = [customEntry]
      ..customPeriodsTitle = 'Сезон'
      ..customPeriodsIndex = 0;
    final originalBegin = source.beginDate;
    final originalEnd = source.endDate;
    final controller = NsgDataController<NsgDataItem>(requestOnInit: false);
    controller.controllerFilter.periodSelected = NsgPeriodType.quarter;
    controller.controllerFilter.periodTimeEnabled = true;
    NsgPeriod assignedPeriod = source;
    var selectionCallbacks = 0;
    final drafts = <NsgPeriod>[];
    var confirms = 0;
    await openPopup(
      tester,
      source: source,
      drafts: drafts,
      dataController: controller,
      onSelect: (value) {
        selectionCallbacks++;
        assignedPeriod = value;
      },
      onConfirm: () => confirms++,
      rangePicker:
          ({
            required context,
            required initialDateRange,
            required firstDate,
            required lastDate,
            barrierDismissible = true,
          }) async => null,
    );

    final contentState = tester.state<NsgPeriodFilterContentState>(find.byType(NsgPeriodFilterContent));
    contentState.date.customPeriods.single.name = 'Изменённый draft';

    final monthChip = find.byWidgetPredicate(
      (widget) => widget is NsgCheckBox && widget.label == 'Месяц',
    );
    await tester.tap(monthChip);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.byType(NsgPopUp), findsNothing);
    expect(confirms, 0);
    expect(source.beginDate, originalBegin);
    expect(source.endDate, originalEnd);
    expect(source.selectedType, NsgPeriodType.year);
    expect(source.customPeriodsTitle, 'Сезон');
    expect(source.customPeriodsIndex, 0);
    expect(source.customPeriods.single, same(customEntry));
    expect(source.customPeriods.single.name, 'Сезон 2026');
    expect(selectionCallbacks, 0);
    expect(assignedPeriod, same(source));
    expect(controller.controllerFilter.periodSelected, NsgPeriodType.quarter);
    expect(controller.controllerFilter.periodTimeEnabled, isTrue);
  });

  testWidgets('direct popup OK commits all period metadata atomically', (tester) async {
    final customEntry = NsgPeriodCustomPeriod(
      name: 'Сезон 2026',
      beginDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
    );
    final source = initialPeriod()
      ..customPeriods = [customEntry]
      ..customPeriodsTitle = 'Сезон'
      ..customPeriodsIndex = 0;
    final controller = NsgDataController<NsgDataItem>(requestOnInit: false);
    controller.controllerFilter.periodSelected = NsgPeriodType.quarter;
    var confirms = 0;
    var selectionCallbacks = 0;
    var externalConfirmSawCommittedDraft = false;
    NsgPeriod assignedPeriod = source;
    await openPopup(
      tester,
      source: source,
      drafts: <NsgPeriod>[],
      dataController: controller,
      onSelect: (value) {
        selectionCallbacks++;
        assignedPeriod = value;
      },
      onConfirm: () {
        confirms++;
        externalConfirmSawCommittedDraft =
            selectionCallbacks == 1 && assignedPeriod.selectedType == NsgPeriodType.month;
      },
      rangePicker: ({required context, required initialDateRange, required firstDate, required lastDate, barrierDismissible = true}) async => null,
    );

    final monthChip = find.byWidgetPredicate((widget) => widget is NsgCheckBox && widget.label == 'Месяц');
    await tester.tap(monthChip);
    await tester.pump();
    expect(source.selectedType, NsgPeriodType.year, reason: 'selection is still a draft');
    expect(controller.controllerFilter.periodSelected, NsgPeriodType.quarter);
    expect(selectionCallbacks, 0);
    expect(assignedPeriod, same(source));

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(confirms, 1);
    expect(externalConfirmSawCommittedDraft, isTrue);
    expect(selectionCallbacks, 1);
    expect(assignedPeriod.selectedType, NsgPeriodType.month);
    expect(source.selectedType, NsgPeriodType.month);
    expect(source.customPeriodsTitle, 'Сезон');
    expect(source.customPeriodsIndex, 0);
    expect(source.customPeriods.single.name, 'Сезон 2026');
    expect(source.customPeriods.single, isNot(same(customEntry)));
    expect(controller.controllerFilter.periodSelected, NsgPeriodType.month);
  });

  testWidgets('custom draft assignment is not exposed when outer route is cancelled', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final source = initialPeriod()
      ..customPeriods = [
        NsgPeriodCustomPeriod(
          name: '',
          beginDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31, 23, 59, 59, 999),
        ),
      ]
      ..customPeriodsTitle = 'Сезон';
    final controller = NsgDataController<NsgDataItem>(requestOnInit: false);
    NsgPeriod assignedPeriod = source;
    var selectionCallbacks = 0;
    await openPopup(
      tester,
      source: source,
      drafts: <NsgPeriod>[],
      dataController: controller,
      onSelect: (value) {
        selectionCallbacks++;
        assignedPeriod = value;
      },
      onConfirm: () {},
      rangePicker: ({required context, required initialDateRange, required firstDate, required lastDate, barrierDismissible = true}) async => null,
    );

    await tester.tap(find.byWidgetPredicate((widget) => widget is NsgCheckBox && widget.label == 'Сезон'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(selectionCallbacks, 0);
    expect(assignedPeriod, same(source));
    expect(source.selectedType, NsgPeriodType.year);
    expect(controller.controllerFilter.periodSelected, NsgPeriodType.month);
  });

  testWidgets(
    'standalone filter applies confirmed range through its controller',
    (tester) async {
      final controller = _TestController();
      controller.controllerFilter.nsgPeriod
        ..beginDate = DateTime(2026, 1, 1)
        ..endDate = DateTime(2026, 12, 31, 23, 59, 59, 999)
        ..selectedType = NsgPeriodType.year;
      final expected = DateTimeRange(
        start: DateTime(2026, 9, 2),
        end: DateTime(2026, 9, 3),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates:
              NsgControlsLocalizations.localizationsDelegates,
          supportedLocales: NsgControlsLocalizations.supportedLocales,
          home: Scaffold(
            body: NsgPeriodFilter(
              label: 'Фильтр периода',
              controller: controller,
              rangePicker: routedRangePicker(expected, onOpen: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Фильтр периода'));
      await tester.pumpAndSettle();
      await tester.tap(periodChip());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Подтвердить диапазон'));
      await tester.pumpAndSettle();

      expect(controller.refreshCalls, 1);
      expect(controller.controllerFilter.nsgPeriod.beginDate, expected.start);
      expect(
        controller.controllerFilter.nsgPeriod.endDate,
        DateTime(2026, 9, 3, 23, 59, 59, 999, 999),
      );
      expect(find.byType(NsgPopUp), findsNothing);
    },
  );
}

class _TestController extends NsgDataController<NsgDataItem> {
  _TestController() : super(requestOnInit: false);

  int refreshCalls = 0;

  @override
  Future refreshData({
    List<NsgUpdateKey>? keys,
    NsgDataRequestParams? filter,
  }) async {
    refreshCalls++;
  }
}
