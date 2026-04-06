import 'package:flutter/material.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/dialog/show_nsg_period_picker.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_grid.dart';
import 'package:nsg_data/nsg_data.dart';

/// Примечание к errorMessage: мы не сохраняем errorMessage, так как он временный и исчезает при изменении периода. Он используется только для отображения ошибки при выборе времени. Мы не сохраняем неверный формат периода, поэтому при ошибке мы получаем то же состояние, просто с ошибкой.
class NsgPeriodPickerState implements NsgState {
  final bool disabled;
  final NsgTypedPeriod period;
  final NsgPeriodGranularity? granularity;
  final String? optionLabel;
  final String? errorMessage;
  final DateTime minimumDate;
  final DateTime maximumDate;
  NsgPeriodPickerState({
    this.disabled = false,
    required this.period,
    this.granularity,
    this.optionLabel,
    this.errorMessage,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) : minimumDate = minimumDate ?? DateTime.now().subtract(Duration(days: 365 * 20)),
       maximumDate = maximumDate ?? DateTime.now().add(Duration(days: 365 * 20));

  @override
  NsgPeriodPickerState copyWith({
    bool? disabled,
    NsgTypedPeriod? period,
    NsgPeriodGranularity? granularity,
    String? optionLabel,
    String? errorMessage,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) {
    return NsgPeriodPickerState(
      disabled: disabled ?? this.disabled,
      period: period ?? this.period,
      granularity: granularity ?? this.granularity,
      optionLabel: optionLabel ?? this.optionLabel,
      errorMessage: errorMessage, // Мы не созраняем errorMessage, так как он временный и исчезает при изменении периода
      minimumDate: minimumDate ?? this.minimumDate,
      maximumDate: maximumDate ?? this.maximumDate,
    );
  }
}

class NsgPeriodPickerEvent<S extends NsgPeriodPickerState> extends NsgEvent<S> with NsgEventMixin<S> {
  final NsgEventActionVoid<S>? onChangedAction;
  final NsgEventActionVoid<S>? onSelectedAction;
  final NsgEventActionVoid<S>? onCheckedBelongAction;
  final NsgEventActionVoid<S>? onErrorAction;
  final Function(NsgTypedPeriod period)? checkBelongAction;
  NsgPeriodPickerEvent({
    required super.state,
    this.onChangedAction,
    this.onSelectedAction,
    this.onCheckedBelongAction,
    this.onErrorAction,
    this.checkBelongAction,
  }) : super() {
    if (state.optionLabel == null) {
      changeOptionLabel(checkBelong(state.period) ?? tranControls.quick_selection);
    }
  }

  void onChanged(S newState) {
    updateState(newState);
    onChangedAction?.call(state);
  }

  void onSelected(S newState) {
    updateState(newState);
    onSelectedAction?.call(state);
  }

  void onCheckedBelong(S newState) {
    updateState(newState);
    onCheckedBelongAction?.call(state);
  }

  void onError(S newState) {
    updateState(newState);
    onErrorAction?.call(state);
  }

  void changeOptionLabel(String optionLabel, {bool selected = false}) {
    onChanged(state.copyWith(optionLabel: optionLabel) as S);
    if (selected) {
      onSelected(state.copyWith(optionLabel: optionLabel) as S);
    }
  }

  void changePeriod(NsgTypedPeriod period, {bool selected = false}) {
    onChanged(state.copyWith(period: period) as S);
    if (selected) {
      onSelected(state.copyWith(period: period) as S);
    }
  }

  void showError(String errorMessage) {
    onError(state.copyWith(errorMessage: errorMessage) as S);
  }

  /// Определяет, к какой опции принадлежит период
  String? checkBelong(NsgTypedPeriod period) {
    String? label = checkBelongAction?.call(period);
    if (label != null) {
    } else {
      label = switch (period.type) {
        NsgPeriodGranularity.year => tranControls.quick_selection,
        NsgPeriodGranularity.quarter => tranControls.quick_selection,
        NsgPeriodGranularity.month => tranControls.quick_selection,
        NsgPeriodGranularity.week => tranControls.quick_selection,
        NsgPeriodGranularity.day => tranControls.quick_selection,
        NsgPeriodGranularity.days => tranControls.period_with_time,
        NsgPeriodGranularity.custom => tranControls.period_with_time,
      };
    }
    return label;
  }

  String granularityName(NsgPeriodGranularity granularity) {
    return switch (granularity) {
      NsgPeriodGranularity.year => tranControls.year,
      NsgPeriodGranularity.quarter => tranControls.quarter,
      NsgPeriodGranularity.month => tranControls.month,
      NsgPeriodGranularity.week => tranControls.week,
      NsgPeriodGranularity.day => tranControls.day,
      NsgPeriodGranularity.days => tranControls.period,
      NsgPeriodGranularity.custom => tranControls.period_with_time,
    };
  }
}

class NsgPeriodPickerWidget<S extends NsgPeriodPickerState, E extends NsgPeriodPickerEvent<S>> extends StatelessWidget {
  final E event;
  final List<(String, NsgEventBuilder<S>)> optionBuildersCustom;
  const NsgPeriodPickerWidget({super.key, required this.event, this.optionBuildersCustom = const []});

  Widget child(BuildContext context, S state) {
    return Container(padding: EdgeInsets.all(5), child: Text(event.state.period.dateText(false, Localizations.localeOf(context).languageCode)));
  }

  Widget commonOption(BuildContext context, S state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        spacing: 6,
        children: [NsgPeriodGranularity.day, NsgPeriodGranularity.week, NsgPeriodGranularity.month, NsgPeriodGranularity.year]
            .map(
              (periodGranularity) => NsgPeriodWidget(
                context: context,
                disabled: state.disabled,
                selected: state.period.type == periodGranularity,
                period: state.period,
                periodGranularity: periodGranularity,
                label: event.granularityName(periodGranularity),
                onChanged: (period, periodGranularity) => event.changePeriod(period),
                onPressed: (period, periodGranularity) {
                  event.changePeriod(period, selected: true);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  /// Кастомная опция выбора вида периода. Пользователь выбирает NsgPeriodGranularity и уже при нажатии на виждет NsgPeriodWidget, выскакивает модальное окно с выбором времени
  Widget customOption(BuildContext context, S state) {
    return Column(
      children: [
        NsgPeriodWidget(
          context: context,
          disabled: state.disabled,
          selected: true, // Выбран всегда, так как это единственный виджет периода для этой опции
          period: state.period,
          periodGranularity: state.period.type, // Тип определяется автоматически для этого виджета
          onChanged: (period, periodGranularity) => event.changePeriod(period),
          onPressed: (period, periodGranularity) async {
            final newPeriod = await showNsgPeriodPicker(
              context: context,
              period: state.period,
              minimumDate: state.minimumDate,
              maximumDate: state.maximumDate,
              label: state.optionLabel,
            );
            if (newPeriod != null) {
              event.changePeriod(newPeriod);
            }
          },
        ),
        NsgGrid(
          crossAxisCount: 2,
          children:
              [
                    NsgPeriodGranularity.year,
                    NsgPeriodGranularity.quarter,
                    NsgPeriodGranularity.month,
                    NsgPeriodGranularity.week,
                    NsgPeriodGranularity.day,
                    NsgPeriodGranularity.days,
                    NsgPeriodGranularity.custom,
                  ]
                  .map(
                    (periodGranularity) => NsgCheckBox(
                      key: GlobalKey(),
                      radio: true,
                      label: event.granularityName(periodGranularity),
                      value: state.period.type == periodGranularity,
                      onPressed: (_) {
                        // Так как кастомная опция реактивна, то мы не фиксируем выбор NsgPeriodGranularity.days, а changeType() по факту тот же тип, что и дата года или дня, поскольку начало и конец совпадают. Вместо этого мы создаём свой период относительно начала периода
                        if (periodGranularity == NsgPeriodGranularity.days) {
                          // Период из трёх дней, не день и не неделя
                          return event.changePeriod(NsgTypedPeriod.days(state.period.begin, state.period.begin.add(Duration(days: 2))));
                        } else if (periodGranularity == NsgPeriodGranularity.custom) {
                          // Период из двух дней со временем
                          return event.changePeriod(NsgTypedPeriod(state.period.begin.add(Duration(hours: 12)), state.period.begin.add(Duration(hours: 36))));
                        }
                        event.changePeriod(state.period.changeType(periodGranularity));
                      },
                    ),
                  )
                  .toList(),
        ),
        if (state.period.type == NsgPeriodGranularity.custom)
          Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 200, maxHeight: 50),
                child: Row(
                  children: [
                    Expanded(
                      child: NsgTimePicker.time(
                        key: GlobalKey(),
                        initialTime: TimeOfDay.fromDateTime(state.period.begin),
                        onClose: (time) {
                          // onChanged(period.copyWithBegin(time));
                        },
                        onValidTime: (time) {
                          event.changePeriod(state.period.copyWithBeginTime(time));
                        },
                        validator: (time) {
                          final dateBegin = state.period.begin.copyWith(hour: time.hour, minute: time.minute);
                          if (dateBegin.isAfter(state.period.end)) {
                            event.showError(tranControls.period_begin_must_be_before_end);
                            return false;
                          }
                          return true;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NsgTimePicker.time(
                        key: GlobalKey(),
                        initialTime: TimeOfDay.fromDateTime(state.period.end),
                        onClose: (time) {
                          // onChanged(period.copyWithBegin(time));
                        },
                        onValidTime: (time) {
                          event.changePeriod(state.period.copyWithEndTime(time));
                        },
                        validator: (time) {
                          final dateEnd = state.period.end.copyWith(hour: time.hour, minute: time.minute);
                          if (dateEnd.isBefore(state.period.begin)) {
                            event.showError(tranControls.period_begin_must_be_before_end);
                            return false;
                          }
                          return true;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: nsgtheme.colorError, fontSize: nsgtheme.sizeS),
                ),
            ],
          ),
      ],
    );
  }

  List<(String, NsgEventBuilder<S>)> optionBuilders() {
    return [(tranControls.quick_selection, commonOption), (tranControls.period_with_time, customOption)];
  }

  Widget pickerContentBuilder(BuildContext context, S state) {
    final records = optionBuildersCustom.isEmpty ? optionBuilders() : optionBuildersCustom;

    return Column(
      children: records
          .map(
            (record) => Column(
              children: [
                NsgCheckBox(
                  key: GlobalKey(),
                  radio: true,
                  label: record.$1.toUpperCase(),
                  value: record.$1 == state.optionLabel,
                  onPressed: (value) {
                    event.changeOptionLabel(record.$1);
                  },
                ),
                if (record.$1 == state.optionLabel) record.$2(context, state),
              ],
            ),
          )
          .toList(),
    );
  }

  Future<void> showPicker(BuildContext context, S state) async {
    await showNsgDialog(
      context: context,
      isScrollable: true,
      title: tranControls.select_period,
      showCloseButton: true,
      constraints: BoxConstraints(maxWidth: 600),
      child: ListenableBuilder(listenable: event.stateN, builder: (context, widget) => pickerContentBuilder(context, event.state)),
      onConfirm: () {
        // state может быть не актуальным, поэтому берём state из event
        event.changePeriod(event.state.period, selected: true);
      },
      onClose: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () async => await showPicker(context, event.state), child: child(context, event.state));
  }
}

class NsgPeriodPicker extends StatefulWidget {
  /// Объект, значение поля которого отображается
  final NsgDataItem dataItem;

  /// Поле для отображения и задания значения
  final String dateBeginFieldName;

  /// Поле для отображения и задания значения
  final String dateEndFieldName;

  final void Function(NsgTypedPeriod period, String? optionLabel)? onChanged;

  final void Function(NsgTypedPeriod period, String? optionLabel)? onSelected;

  const NsgPeriodPicker({super.key, required this.dataItem, required this.dateBeginFieldName, required this.dateEndFieldName, this.onChanged, this.onSelected});

  @override
  State<NsgPeriodPicker> createState() => _NsgPeriodPickerState();
}

class _NsgPeriodPickerState extends State<NsgPeriodPicker> {
  late final NsgPeriodPickerEvent event;

  @override
  void initState() {
    super.initState();
    final beginDate = widget.dataItem.getFieldValue(widget.dateBeginFieldName) as DateTime;
    final endDate = widget.dataItem.getFieldValue(widget.dateEndFieldName) as DateTime;
    event = NsgPeriodPickerEvent(
      state: NsgPeriodPickerState(period: NsgTypedPeriod(beginDate, endDate)),
      onChangedAction: (state) {
        widget.onChanged?.call(state.period, state.optionLabel);
      },
      onSelectedAction: (state) {
        widget.dataItem.setFieldValue(widget.dateBeginFieldName, state.period.begin);
        widget.dataItem.setFieldValue(widget.dateEndFieldName, state.period.end);
        widget.onSelected?.call(state.period, state.optionLabel);
      },
    );
  }

  @override
  void dispose() {
    event.stateN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NsgPeriodPickerWidget(event: event);
  }
}

typedef NsgPeriodCallback = void Function(NsgTypedPeriod period, NsgPeriodGranularity periodGranularity);

/// Виджет, который отображает период в текущей granularity и позволяет менять его sub() и add()
class NsgPeriodWidget extends StatelessWidget {
  final BuildContext context;
  final bool disabled;
  final bool selected;
  final NsgTypedPeriod period;
  final NsgPeriodGranularity periodGranularity;
  final String? label;
  final String? timeText;
  final NsgPeriodCallback? onChanged;
  final NsgPeriodCallback? onPressed;
  final NsgPeriodCallback? onLeftButtonPressed; // Без автоматического изменения granularity при нажатии (если не зависит от granularity)
  final NsgPeriodCallback? onRightButtonPressed; // Без автоматического изменения granularity при нажатии (если не зависит от granularity)
  final NsgPeriodCallback? onTimePressed; // Без автоматического изменения granularity при нажатии (если не зависит от granularity)
  const NsgPeriodWidget({
    super.key,
    required this.context,
    this.disabled = false,
    this.selected = false,
    required this.period,
    required this.periodGranularity,
    this.label,
    this.timeText,
    this.onChanged,
    this.onPressed,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
    this.onTimePressed,
  });

  /// period.type == periodGranularity
  bool get isGranularitySame => period.type == periodGranularity;

  /// Изменить granularity, если не совподает с periodGranularity и выполнить func
  bool changeGranularity(NsgPeriodCallback? func) {
    if (!isGranularitySame) {
      final newPeriod = period.changeType(periodGranularity);
      func?.call(newPeriod, periodGranularity);
      return true;
    }
    func?.call(period, periodGranularity);
    return false;
  }

  static Widget button({bool disabled = false, selected = false, required IconData icon, void Function()? onPressed}) {
    return GestureDetector(
      onTap: () => !disabled && onPressed != null ? onPressed() : null,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(color: nsgtheme.colorMain, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 35),
      ),
    );
  }

  static Widget time({
    required BuildContext context,
    bool disabled = false,
    bool selected = false,
    required NsgTypedPeriod period,
    required NsgPeriodGranularity periodGranularity,
    String? timeText,
    void Function()? onPressed,
  }) {
    return GestureDetector(
      onTap: () => !disabled ? onPressed?.call() : null,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: !selected ? nsgtheme.colorMain : nsgtheme.colorGreyDarker,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: nsgtheme.colorMain, width: 2),
        ),
        child: Text(
          timeText ?? period.changeType(periodGranularity).dateText(false, Localizations.localeOf(context).languageCode),
          style: TextStyle(fontSize: nsgtheme.sizeL, color: !selected ? nsgtheme.colorPrimaryText : nsgtheme.colorText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Text(
              label!,
              style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorText),
            ),
          ),
        SizedBox(
          height: 45,
          child: Row(
            spacing: 8,
            children: [
              NsgPeriodWidget.button(
                disabled: disabled,
                selected: selected,
                icon: Icons.chevron_left_rounded,
                onPressed: () {
                  if (onLeftButtonPressed != null) {
                    onLeftButtonPressed?.call(period, periodGranularity);
                  } else {
                    changeGranularity((period, _) => onChanged?.call(period.sub(), periodGranularity));
                  }
                },
              ),
              Expanded(
                child: NsgPeriodWidget.time(
                  context: context,
                  disabled: disabled,
                  selected: selected,
                  period: period,
                  periodGranularity: periodGranularity,
                  onPressed: () {
                    if (onTimePressed != null) {
                      onTimePressed?.call(period, periodGranularity);
                    } else {
                      changeGranularity((period, _) => onPressed?.call(period, periodGranularity));
                    }
                  },
                ),
              ),
              NsgPeriodWidget.button(
                disabled: disabled,
                selected: selected,
                icon: Icons.chevron_right_rounded,
                onPressed: () {
                  if (onRightButtonPressed != null) {
                    onRightButtonPressed?.call(period, periodGranularity);
                  } else {
                    changeGranularity((period, _) => onChanged?.call(period.add(), periodGranularity));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
