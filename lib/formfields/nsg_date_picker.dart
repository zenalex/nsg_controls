// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../helpers.dart';

class NsgDatePicker extends StatefulWidget {
  final String? label;
  final TextAlign textAlign;
  final EdgeInsets margin;
  final DateTime initialTime;
  final bool? disabled;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  final Widget? labelWidget;

  // final Color? outlineBorderColor;

  // final TextFormFieldType textFormFieldType;

  // final BorderRadiusGeometry? borderRadius;

  // final Color? fieldColor;

  // final Widget? lableWidget;

  // final TextStyle? textStyle;

  /// Убирает отступы сверху и снизу, убирает текст валидации
  final bool simple;
  final Function(DateTime endDate) onClose;

  const NsgDatePicker({
    Key? key,
    required this.initialTime,
    // this.textFormFieldType = TextFormFieldType.underlineInputBorder,
    required this.onClose,
    this.firstDateTime,
    this.lastDateTime,
    this.label = '',
    this.labelWidget,
    this.textAlign = TextAlign.center,
    this.disabled = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.simple = false,
    // this.outlineBorderColor,
    // this.borderRadius,
    // this.fieldColor,
    // this.lableWidget,
    // this.textStyle,
  }) : super(key: key);

  void showPopup(BuildContext context, DateTime date, Function(DateTime endDate) onClose) {
    DateTime selectedDate = date;
    //Если не задана дата (<1755) устанавливаем initialTime как начальную
    //Иначе, при нажатии на галку не происходит выбор даты
    if (selectedDate.year < 1800) {
      selectedDate = initialTime;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => NsgPopUp(
        title: tran.select_date,
        //height: 410,
        onConfirm: () {
          onClose(selectedDate);
        },
        onCancel: () {
          Navigator.of(context).pop();
          //Get.back();
        },
        getContent: () => [
          DatePickerContent(
            textAlign: textAlign,
            firstDateTime: firstDateTime,
            lastDateTime: lastDateTime,
            initialTime: initialTime,
            onChange: (endDate) {
              selectedDate = endDate;
            },
          ),
        ],
      ),
    );
  }

  @override
  State<NsgDatePicker> createState() => _NsgDatePickerState();
}

class _NsgDatePickerState extends State<NsgDatePicker> {
  DateTime _initTime = DateTime.now();
  late double textScaleFactor;

  @override
  void initState() {
    super.initState();
    _initTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    textScaleFactor = MediaQuery.of(context).textScaleFactor;
    inkWellWrapper({required Widget child}) {
      if (widget.disabled == true) {
        return child;
      } else {
        return InkWell(
          onTap: widget.disabled != true
              ? () {
                  NsgDatePicker(initialTime: _initTime, onClose: (value) {}).showPopup(context, _initTime, (value) {
                    widget.onClose(value);
                    _initTime = value;
                    setState(() {});
                  });
                }
              : null,
          child: child,
        );
      }
    }

    return inkWellWrapper(
      child: Padding(
        padding: widget.margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.simple != true)
              SizedBox(
                //  height: 12 * textScaleFactor,
                child: Text(
                  widget.label!,
                  textAlign: widget.textAlign,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorPrimary),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 2),
              //  height: 24 * textScaleFactor - 1,
              decoration: BoxDecoration(
                // color: widget.fieldColor ?? Colors.transparent,
                // borderRadius: widget.borderRadius,
                border:
                    // widget.textFormFieldType == TextFormFieldType.outlineInputBorder
                    //     ? Border.fromBorderSide(
                    //         BorderSide(color: widget.outlineBorderColor ?? nsgtheme.colorGreyLighter),
                    //       )
                    Border(bottom: BorderSide(width: 1, color: nsgtheme.colorMain)),
              ),
              child: Row(
                children: [
                  if (widget.disabled == true)
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Icon(Icons.lock, size: 12, color: nsgtheme.colorMain),
                    ),
                  Expanded(
                    child:
                        widget.labelWidget ??
                        Text(
                          NsgDateFormat.dateFormat(_initTime, format: 'dd.MM.yy', locale: Localizations.localeOf(context).languageCode),
                          textAlign: widget.textAlign,
                          style:
                              // widget.textStyle ??
                              TextStyle(fontSize: nsgtheme.sizeM),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatePickerContent extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime endDate) onChange;
  final TextAlign textAlign;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  const DatePickerContent({super.key, this.firstDateTime, this.lastDateTime, required this.initialTime, required this.textAlign, required this.onChange});

  @override
  State<DatePickerContent> createState() => _DatePickerContentState();
}

class _DatePickerContentState extends State<DatePickerContent> {
  String _initialTime = '';
  DateTime _initialTime2 = DateTime.now();
  final textController = TextEditingController();
  var firstDate = DateTime.now().subtract(const Duration(days: 200));
  var lastDate = DateTime.now().add(const Duration(days: 200));
  @override
  void initState() {
    //textController.text = _initialTime;
    //var loc = Localizations.localeOf(context).languageCode;

    textController.text = NsgDateFormat.dateFormat(widget.initialTime, format: 'dd.MM.yyyy', locale: 'en');
    textController.addListener(textChanged);
    super.initState();
  }

  bool _ignoreChange = false;
  void textChanged() {
    if (_ignoreChange) return;
    var value = textController.text;
    // if (value.length < _initialTime.length) {
    //   _initialTime = value;
    //   return;
    // } else if (value.length == _initialTime.length) {
    var start = textController.selection.start;
    if (start < _initialTime.length) {
      _initialTime = value.substring(0, start) + _initialTime.substring(start);
    } else {
      _initialTime = value;
    }

    DateTime? initialTimeNew;
    try {
      initialTimeNew = DateFormat('dd.MM.yyyy').parse(_initialTime);
      // ignore: empty_catches
    } catch (e) {}
    if (initialTimeNew != null) {
      _initialTime2 = initialTimeNew;
      /* ---------------------------------------------------- только на мобильных обновляем Дейтпикер --------------------------------------------------- */
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        datepicker!.setState(_initialTime2);
      } else {
        /* ----------------------------------------------------- на десктопе обновляем Календарьпикер ----------------------------------------------------- */
        calendarpicker!.setState(_initialTime2);
      }
      widget.onChange(_initialTime2);
    }
    if (textController.text != _initialTime) {
      var start = textController.selection.start;
      _ignoreChange = true;
      textController.text = _initialTime;

      textController.selection = TextSelection.fromPosition(TextPosition(offset: start));
      _ignoreChange = false;
    }
    // } else {
    //   _initialTime = value;
    // }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialTime.isEmpty) {
      _initialTime = NsgDateFormat.dateFormat(widget.initialTime, format: 'dd.MM.yyyy', locale: Localizations.localeOf(context).languageCode);
      _initialTime2 = widget.initialTime;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 40,
          width: 150,
          child: TextFormField(
            inputFormatters: [MaskTextInputFormatter(initialText: _initialTime, mask: "##.##.####")],
            keyboardType: TextInputType.number,
            cursorColor: nsgtheme.colorBase.b100,
            textAlign: widget.textAlign,
            controller: textController,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: nsgtheme.colorText),
              errorStyle: TextStyle(color: nsgtheme.colorText),
              labelText: '',
              contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: nsgtheme.colorMainDark)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: nsgtheme.colorMainText)),
              labelStyle: TextStyle(color: nsgtheme.colorMainDark, backgroundColor: Colors.transparent),
            ),
            // key: GlobalKey(),
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            onChanged: (String value) {
              //
            },

            style: TextStyle(color: nsgtheme.colorText, fontSize: 24),
          ),
        ),
        !kIsWeb && (Platform.isAndroid || Platform.isIOS)
            ? SizedBox(width: 300, height: 280, child: getCupertinoPicker())
            : SizedBox(height: 250, width: 300, child: getCalendarPicker()),
      ],
    );
  }

  NsgCalendarDatePicker? calendarpicker;
  Widget getCalendarPicker() {
    calendarpicker = NsgCalendarDatePicker(
      lastDateTime: widget.lastDateTime,
      firstDateTime: widget.firstDateTime,
      initialDateTime: _initialTime2,
      onDateTimeChanged: (DateTime value) {
        widget.onChange(value);
        _initialTime = NsgDateFormat.dateFormat(value, format: 'dd.MM.yyyy', locale: Localizations.localeOf(context).languageCode);
        _ignoreChange = true;
        textController.text = _initialTime;
        textController.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
        _ignoreChange = false;
      },
    );
    return calendarpicker!;
  }

  NsgCupertinoDatePicker? datepicker;
  Widget getCupertinoPicker() {
    datepicker = NsgCupertinoDatePicker(
      lastDateTime: widget.lastDateTime,
      firstDateTime: widget.firstDateTime,
      key: GlobalKey(),
      initialDateTime: _initialTime2,
      onDateTimeChanged: (DateTime value) {
        widget.onChange(value);
        _initialTime = NsgDateFormat.dateFormat(value, format: 'dd.MM.yyyy', locale: Localizations.localeOf(context).languageCode);
        _ignoreChange = true;
        textController.text = _initialTime;
        textController.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
        _ignoreChange = false;
      },
    );
    return datepicker!;
  }
}

// ignore: must_be_immutable
class NsgCupertinoDatePicker extends StatefulWidget {
  DateTime initialDateTime;
  final DateTime? lastDateTime;
  final DateTime? firstDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  NsgCupertinoDatePicker({Key? key, this.firstDateTime, this.lastDateTime, required this.initialDateTime, required this.onDateTimeChanged}) : super(key: key);

  @override
  State<NsgCupertinoDatePicker> createState() => NsgCupertinoDateState();

  NsgCupertinoDateState? currentState;

  void setState(DateTime date) {
    if (currentState != null) {
      initialDateTime = date;
      currentState!.externalSetState();
    }
  }
}

class NsgCupertinoDateState extends State<NsgCupertinoDatePicker> {
  @override
  void initState() {
    widget.currentState = this;
    super.initState();
  }

  void externalSetState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(fontSize: 16, color: nsgtheme.colorText)),
      ),
      child: CupertinoDatePicker(
        maximumDate: widget.lastDateTime ?? DateTime.now().add(const Duration(days: 365 * 2)),
        minimumDate: widget.firstDateTime ?? DateTime(0),
        key: GlobalKey(),
        mode: CupertinoDatePickerMode.date,
        initialDateTime: widget.initialDateTime,
        onDateTimeChanged: (d) => widget.onDateTimeChanged(d),
        use24hFormat: true,
        minuteInterval: 1,
      ),
    );
  }
}

// ignore: must_be_immutable
class NsgCalendarDatePicker extends StatefulWidget {
  DateTime initialDateTime;
  final DateTime? lastDateTime;
  final DateTime? firstDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  NsgCalendarDatePicker({Key? key, this.lastDateTime, this.firstDateTime, required this.initialDateTime, required this.onDateTimeChanged}) : super(key: key);

  @override
  State<NsgCalendarDatePicker> createState() => NsgCalendarDatePickerState();

  NsgCalendarDatePickerState? currentState;

  void setState(DateTime date) {
    if (currentState != null) {
      initialDateTime = date;
      currentState!.externalSetState();
    }
  }
}

class NsgCalendarDatePickerState extends State<NsgCalendarDatePicker> {
  @override
  void initState() {
    widget.currentState = this;
    super.initState();
  }

  void externalSetState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var lastDate = widget.initialDateTime.isBefore(DateTime.now().add(const Duration(days: 365 * 2)))
        ? DateTime.now().add(const Duration(days: 365 * 2))
        : widget.initialDateTime;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(fillColor: nsgtheme.colorPrimary),
          colorScheme: ColorScheme.light(
            primary: nsgtheme.colorTertiary,
            onPrimary: nsgtheme.colorText,
            onSurface: nsgtheme.colorText.withAlpha(80),
            secondary: nsgtheme.colorText,
            tertiary: nsgtheme.colorText,
          ),
        ),
        child: CalendarDatePicker(
          key: GlobalKey(),
          firstDate: widget.firstDateTime ?? DateTime(0),
          lastDate: widget.lastDateTime ?? lastDate,
          initialDate: widget.initialDateTime,
          onDateChanged: (d) {
            widget.onDateTimeChanged(d);
          },
        ),
      ),
    );
  }
}
