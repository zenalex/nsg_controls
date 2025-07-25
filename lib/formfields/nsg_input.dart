// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/formfields/nsg_position_boolBox.dart';
import 'package:nsg_controls/formfields/nsg_switch_horizontal.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:hovering/hovering.dart';
import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_controls/formfields/nsg_field_type.dart';

import 'nsg_input_selection_widget_type.dart';

class NsgInput extends StatefulWidget {
  final String label;
  final Color? labelColor;
  final bool disabled;
  final bool? gesture;
  final double? fontSize;
  final EdgeInsets? margin;
  final String? hint;
  final Widget? widget;
  final double borderRadius;
  final Function(NsgDataItem)? onChanged;
  final Function(bool value)? onFocusChanged;
  final VoidCallback? onPressed;
  final Function(NsgDataItem, String)? onEditingComplete;
  final Function(NsgDataItem, String)? onFieldSubmitted;
  final int maxLines;
  final int minLines;

  /// Дефолтный выбранный код страны, например: 'en'
  final String? countryCodeInitial;

  /// Список кодов стран при выборе кода телефонного номера страны, например: ['en','ru']
  final List<String>? countryCodes;

  ///Для обработки нажатия на физические кнопки при нахождении в фокусе
  final KeyEventResult Function(FocusNode focus, KeyEvent event)? onKeyEvent;

  /// Максимальное количество символов
  final int? maxLenght;

  /// Виджет для Bool переключателя, если нужно что-то сложнее простой текстовой строки
  final Widget? child;

  /// Автовокус на поле при входе на страницу
  final bool autofocus;

  /// Красный текст валидации под текстовым полем
  final String validateText;

  /// Обязательное поле (будет помечено звездочкой)
  final bool? required;

  /// Высота
  //final double? height;

  /// Картинки для выводя рядом с текстом
  final List<String>? imagesList;

  /// Объект, значение поля которого отображается
  final NsgDataItem dataItem;

  /// Поле для отображения и задания значения
  final String fieldName;

  /// Контроллер
  final NsgDataController? controller;

  /// Контроллер для выбора связанного значения
  final NsgBaseController? selectionController;

  /// Внешний вид отображение Selection (колонка или грид)
  final NsgInputSelectionWidgetType selectionWidgetType;

  /// Контроллер, которому будет подаваться update при изменении значения в Input
  final NsgDataController? updateController;

  /// Функция прорисовки строки
  final Widget Function(NsgDataItem, bool)? rowWidget;

  /// Тип поля ввода. Если тип не задан (NsgInputType.autoselect), он будет выбран автоматически,
  /// исходя из типа данных поля объекта
  final NsgInputType inputType;

  /// В случае задания формы для подбора значений для ссылочный полей, вместо стандартной формы будет выполнен переход
  /// на данную форму в режиме контроллера выбор значения
  final String selectionForm;

  /// Тип клавиатуры
  final TextInputType? keyboard;

  /// Маска текста
  final String? mask;

  /// Поле с телефоном и специальной маской для телефонов разных стран
  /// Поле с российским номером автомобиля и автокорректировкой символов
  final NsgInputMaskType? maskType;

  ///При работе с enum можно задать возможные варианты для выбора, если не заданы, будут предложены все
  final List<NsgDataItem>? itemsToSelect;

  /// Показывать label
  final bool? showLabel;

  /// Показывать иконку удаления
  final bool showDeleteIcon;

  /// Выравнивание текста
  final TextAlign textAlign;

  /// Тип поля ввода
  final TextFormFieldType? textFormFieldType;

  /// Цвет границ поля ввода
  final Color? borderColor;

  /// Закрашивать ли поле цветом
  final bool? filled;

  /// Цвет окрашивания поля
  final Color? filledColor;

  /// Поджимать поле по высоте (встроенный параметр в textForField)
  final bool? isDense;

  /// Виджет для отображения в поле ввода как подсказка
  final Widget? labelWidget;

  /// Самая ранняя дата, доступная для выбора
  final DateTime? firstDateTime;

  /// Самая поздняя дата, доступная для выбора
  final DateTime? lastDateTime;

  /// Дата с которой будет предложен выбор, если поле равно 0г. или 1754г.
  final DateTime? initialDateTime;

  /// Показывать значек замка при параметре disabled
  final bool showLock;

  /// Поведение label при вводе контента
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// Стиль текста в поле ввода
  final TextStyle? textStyle;

  /// Заменяет  дефолтный виджет для bool значений на кастомный
  final Widget? boolWidget;

  /// Положение bool элемента относително label или labelWidget
  final BoolBoxPosition? boolBoxPosition;

  /// Параметры отступа для значений внутри NsgInput
  final EdgeInsets? contentPadding;

  /// Виджет для отображения в начале NsgInput
  final Widget? prefix;

  /// Иконка для отображения в конце NsgInput
  final Widget? suffixIcon;

  /// Форматировать отображение времени для входящего виджета
  final String? formatDateTime;

  final Color? trackColor, activeColor, thumbColor;

  final NsgSwitchHorizontalStyle nsgSwitchHorizontalStyle;

  final NsgDataRequestParams Function()? getRequestFilter;

  final List<dynamic> dynamicList;

  ///Стандартные правила автопростановки заглавных букв при вводе текста
  ///Просто транслируется в FormTextField и работает по стандартной логике
  final TextCapitalization textCapitalization;

  ///Режим автозамены. Вкл/Выкл
  final bool autocorrect;

  const NsgInput({
    super.key,
    this.countryCodes,
    this.countryCodeInitial,
    this.child,
    this.dynamicList = const [],
    this.nsgSwitchHorizontalStyle = const NsgSwitchHorizontalStyle(),
    this.trackColor,
    this.selectionWidgetType = NsgInputSelectionWidgetType.column,
    this.activeColor,
    this.thumbColor,
    this.autofocus = false,
    this.initialDateTime,
    this.firstDateTime,
    this.lastDateTime,
    this.onKeyEvent,
    this.maxLenght,
    this.validateText = '',
    this.textAlign = TextAlign.left,
    required this.dataItem,
    required this.fieldName,
    this.showDeleteIcon = true,
    this.showLabel,
    this.controller,
    this.selectionController,
    this.updateController,
    this.label = '',
    this.labelColor,
    this.imagesList,
    this.disabled = false,
    this.fontSize,
    this.borderRadius = 15,
    this.margin,
    this.gesture,
    this.hint,
    this.onChanged,
    this.onFocusChanged,
    this.onPressed,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines = 1,
    //this.height = 50,
    this.widget,
    this.rowWidget,
    this.inputType = NsgInputType.autoselect,
    this.selectionForm = '',
    this.keyboard = TextInputType.text,
    this.mask,
    this.maskType,
    this.itemsToSelect,
    this.required,
    this.textFormFieldType,
    this.borderColor,
    this.filled,
    this.filledColor,
    this.isDense,
    this.labelWidget,
    this.showLock = true,
    this.floatingLabelBehavior = FloatingLabelBehavior.never,
    this.textStyle,
    this.boolWidget,
    this.boolBoxPosition = BoolBoxPosition.end,
    this.contentPadding,
    this.prefix,
    this.suffixIcon,
    this.formatDateTime,
    this.getRequestFilter,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
  });

  @override
  State<NsgInput> createState() => _NsgInputState();

  // if (dynamicList.isNotEmpty && !kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  NsgInputType selectInputType() {
    if (dynamicList.isNotEmpty) {
      return NsgInputType.dynamicList;
    }
    if (inputType == NsgInputType.autoselect) {
      //Если не выбран, задаем его автоматически, исходя из типа данных fieldName
      if (dataItem.getField(fieldName) is NsgDataReferenceField) {
        return NsgInputType.reference;
      } else if (dataItem.getField(fieldName) is NsgDataEnumReferenceField) {
        return NsgInputType.enumReference;
      } else if (dataItem.getField(fieldName) is NsgDataBoolField) {
        return NsgInputType.boolValue;
      } else if (dataItem.getField(fieldName) is NsgDataStringField ||
          dataItem.getField(fieldName) is NsgDataIntField ||
          dataItem.getField(fieldName) is NsgDataDoubleField) {
        return NsgInputType.stringValue;
      } else if (dataItem.getField(fieldName) is NsgDataDateField) {
        return NsgInputType.dateValue;
      } else {
        throw Exception("Не указан тип поля ввода, тип данных неизвестен");
      }
    } else {
      //Если выбран, проверяем на допустимость типа данный fieldName
      if (inputType == NsgInputType.reference) {
        assert(dataItem.getField(fieldName) is NsgDataReferenceField);
      } else if (inputType == NsgInputType.enumReference) {
        assert(dataItem.getField(fieldName) is NsgDataReferenceField);
      } else if (inputType == NsgInputType.boolValue) {
        assert(dataItem.getField(fieldName) is NsgDataBoolField);
      } else if (inputType == NsgInputType.stringValue) {
        assert(dataItem.getField(fieldName) is NsgDataStringField);
      } else if (inputType == NsgInputType.dateValue) {
        assert(dataItem.getField(fieldName) is NsgDataDateField);
      }
      return inputType;
    }
  }
}

class _NsgInputState extends State<NsgInput> {
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  late double textScaleFactor;
  late double fontSize;
  FocusNode focus = FocusNode();
  late TextInputType? keyboard;
  late NsgInputType inputType;
  NsgBaseController? selectionController;
  bool isFocused = false;
  PhoneInputFormatter phoneFormatter = PhoneInputFormatter();
  bool _disabled = false;
  late TextEditingController textController;
  bool get useSelectionController => inputType == NsgInputType.reference || inputType == NsgInputType.referenceList;
  TextFormFieldType? textFormFieldType;
  bool _ignoreChange = false;

  @override
  void initState() {
    super.initState();

    focus = FocusNode(onKeyEvent: widget.onKeyEvent);

    textFormFieldType = widget.textFormFieldType ?? nsgtheme.nsgInputOutlineBorderType;
    fontSize = widget.fontSize ?? ControlOptions.instance.sizeM;
    focus.addListener(() {
      if (focus.hasFocus) {
        if (widget.onFocusChanged != null) {
          widget.onFocusChanged!(true);
        }
        setState(() {});
      } else {
        if (widget.onFocusChanged != null) {
          widget.onFocusChanged!(false);
        }
        setState(() {});
      }

      if (!focus.hasFocus && widget.onEditingComplete != null) {
        widget.onEditingComplete!(widget.dataItem, widget.fieldName);
      }
    });
    //Проверяем, выбран ли тип инпута пользователем
    _disabled = widget.disabled;
    inputType = widget.selectInputType();
    textController = TextEditingController();
    keyboard = widget.keyboard;
    if (widget.dataItem.getField(widget.fieldName) is NsgDataDoubleField) {
      keyboard = TextInputType.number;
    } else if (widget.dataItem.getField(widget.fieldName) is NsgDataIntField) {
      keyboard = TextInputType.number;
    } else if (inputType == NsgInputType.stringValue && widget.maskType == NsgInputMaskType.car) {
      keyboard = TextInputType.number;
    }

    textController.addListener(() {
      if (textController.text == '') {
        _notifier.value = true;
      } else {
        _notifier.value = false;
      }

      if (_ignoreChange) return;

      /// Заменяем в Double запятую на точку, удаляем всё, кроме цифр
      if (widget.dataItem.getField(widget.fieldName) is NsgDataDoubleField) {
        var start = textController.selection.start;
        var end = textController.selection.end;
        String text = textController.text;
        text = text.replaceAll(',', '.');
        text = text.replaceAll(RegExp('[^0-9.-]'), '');
        widget.dataItem.setFieldValue(widget.fieldName, text);
        _ignoreChange = true;
        try {
          if (textController.text != text) {
            textController.text = text;
            if (start != -1 && end != -1) {
              textController.selection = TextSelection(baseOffset: start, extentOffset: end);
            }
          }
        } finally {
          _ignoreChange = false;
        }
      } else if (inputType == NsgInputType.stringValue) {
        if (widget.maskType == NsgInputMaskType.car) {
          var start = textController.selection.start;
          var end = textController.selection.end;
          String text = textController.text.toUpperCase();
          text = text.replaceAll(RegExp('[^0-9АВЕКМНОРСТУХABEKMHOPCTYX]'), '');
          if (start > text.length) {
            start = text.length;
            end = start;
          }
          widget.dataItem.setFieldValue(widget.fieldName, text);
          _ignoreChange = true;
          try {
            textController.text = text;
            if (start != -1 && end != -1) {
              textController.selection = TextSelection(baseOffset: start, extentOffset: end);
            }
          } finally {
            _ignoreChange = false;
          }
        }
        widget.dataItem.setFieldValue(widget.fieldName, textController.value.text);
      }
    });

    if (useSelectionController) {
      var sc = widget.selectionController;
      if (sc == null) {
        var di = widget.dataItem.getReferentOrNull(widget.fieldName);
        if (di != null) {
          sc = di.defaultController;
        }
      }
      if (sc == null) {
        assert(widget.dataItem.getField(widget.fieldName) is NsgDataBaseReferenceField, widget.fieldName);
        sc = NsgDefaultController(
          dataType: (widget.dataItem.getField(widget.fieldName) as NsgDataBaseReferenceField).referentElementType,
          controllerMode: NsgDataControllerMode(storageType: widget.dataItem.storageType),
        );
      }
      selectionController = sc;
    }
    if (widget.controller != null && widget.controller!.readOnly == true) {
      //_disabled = true;
    }
  }

  @override
  void didUpdateWidget(NsgInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    inputType = widget.selectInputType();
  }

  @override
  void dispose() {
    _notifier.dispose();
    textController.dispose();
    focus.removeListener(() {});
    focus.dispose();

    super.dispose();
  }

  /* --------------------------------------------------------------------- BUILD -------------------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    //textScaleFactor = MediaQuery.of(context).textScaleFactor;

    var fieldValue = widget.dataItem.getFieldValue(widget.fieldName);
    if (widget.dataItem.isReferenceField(widget.fieldName)) {
      if (fieldValue is List) {
        //ReferentListField
        List listValue = fieldValue;
        fieldValue = '';
        for (var v in listValue) {
          fieldValue += (fieldValue == '' ? '' : ', ') + v.toString();
        }
      } else {
        var refItem = widget.dataItem.getReferentOrNull(widget.fieldName);
        fieldValue = refItem == null ? '' : refItem.toString();
      }
    }
    if (inputType == NsgInputType.dateValue) {
      if (DateTime(01, 01, 01).isAtSameMomentAs(fieldValue) || DateTime(1754, 01, 01).isAtSameMomentAs(fieldValue)) {
        //Убрал это, зачем вообще присваивать в текст значение лейбла?
        //textController.text = widget.label;
        textController.text = '';
      } else {
        textController.text = NsgDateFormat.dateFormat(fieldValue, format: widget.formatDateTime, locale: Localizations.localeOf(context).languageCode);
      }
    } else {
      textController.text = fieldValue.toString();
    }
    if (inputType == NsgInputType.boolValue) {
      return _buildBoolWidget(fieldValue);
    }

    int? maxLength;
    if (widget.maxLenght != null) {
      maxLength = widget.maxLenght;
    } else {
      if (widget.dataItem.getField(widget.fieldName) is NsgDataStringField) {
        maxLength = (widget.dataItem.getField(widget.fieldName) as NsgDataStringField).maxLength;
        if (maxLength == 0) {
          maxLength = null;
        }
      }
    }

    if (focus.hasFocus) {
      textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
    }

    return Container(
      //key: widget.key ?? GlobalKey(),
      margin: widget.margin ?? nsgtheme.nsgInputMargin,
      child:
          widget.widget ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showLabel ?? nsgtheme.nsgInputShowLabel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    focus.hasFocus || textController.text != '' || nsgtheme.nsgInputHintAlwaysOnTop == true
                        ? (widget.required ?? widget.dataItem.isFieldRequired(widget.fieldName))
                              ? '${widget.label} *'
                              : widget.label
                        : ' ',
                    style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: widget.labelColor ?? nsgtheme.nsgInputColorLabel),
                  ),
                ),
              _gestureWrap(
                clearIcon: fieldValue.toString() != '',
                interactiveWidget: Container(
                  //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      inputType == NsgInputType.phoneCode
                          ? CountryDropdown(
                              initialCountryData: widget.countryCodeInitial == null
                                  ? null
                                  : PhoneCodes.getPhoneCountryDataByCountryCode(widget.countryCodeInitial!),
                              filter: getPhoneCountryDataByCountryCodes(),
                              printCountryName: true,
                              onCountrySelected: (PhoneCountryData countryData) {
                                textController.text = countryData.countryCode.toString();
                                widget.dataItem.setFieldValue(widget.fieldName, countryData.countryCode.toString());
                                if (widget.onChanged != null) {
                                  widget.onChanged!(widget.dataItem);
                                }
                                if (widget.onEditingComplete != null) {
                                  widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                                }
                                setState(() {});
                              },
                              dropdownColor: nsgtheme.colorModalBack,
                              decoration: InputDecoration(
                                suffixIcon: widget.suffixIcon,
                                floatingLabelBehavior: widget.floatingLabelBehavior,
                                contentPadding: getContentPaddingPhoneCode(),
                                isDense: widget.isDense ?? true,
                                filled: widget.filled ?? nsgtheme.nsgInputFilled,
                                fillColor: widget.filledColor ?? nsgtheme.nsgInputColorFilled,
                                border: textFormFieldType == TextFormFieldType.outlineInputBorder
                                    ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                                    : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                                focusedBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? focusedOutlineBorder : focusedUnderlineBorder,
                                enabledBorder: textFormFieldType == TextFormFieldType.outlineInputBorder
                                    ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                                    : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                                errorBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                                disabledBorder: textFormFieldType == TextFormFieldType.outlineInputBorder
                                    ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                                    : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                                focusedErrorBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                              ),
                              style: widget.textStyle ?? TextStyle(color: nsgtheme.nsgInputTextColor, fontSize: fontSize),
                            )
                          : TextFormField(
                              textCapitalization: widget.textCapitalization,
                              autocorrect: widget.autocorrect,
                              controller: textController,
                              inputFormatters: widget.maskType == NsgInputMaskType.phone
                                  ? [phoneFormatter]
                                  : widget.mask != null
                                  ? [MaskTextInputFormatter(initialText: fieldValue.toString(), mask: widget.mask)]
                                  : null,
                              maxLength: maxLength,
                              autofocus: widget.autofocus,
                              focusNode: focus,
                              maxLines: widget.maxLines,
                              minLines: widget.minLines,
                              textInputAction: keyboard == TextInputType.multiline ? TextInputAction.newline : TextInputAction.next,
                              keyboardType: keyboard,
                              cursorColor: ControlOptions.instance.colorText,
                              decoration: InputDecoration(
                                suffixIcon: widget.suffixIcon,
                                floatingLabelBehavior: widget.floatingLabelBehavior,
                                //label: widget.labelWidget,
                                prefix: prefix(),
                                counterText: "",
                                contentPadding: getContentPadding(),
                                isDense: widget.isDense ?? true,
                                filled: widget.filled ?? nsgtheme.nsgInputFilled,
                                fillColor: widget.filledColor ?? nsgtheme.nsgInputColorFilled,
                                border: textFormFieldType == TextFormFieldType.outlineInputBorder
                                    ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                                    : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                                focusedBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? focusedOutlineBorder : focusedUnderlineBorder,
                                enabledBorder: textFormFieldType == TextFormFieldType.outlineInputBorder
                                    ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                                    : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                                errorBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                                disabledBorder: textFormFieldType == TextFormFieldType.outlineInputBorder
                                    ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                                    : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                                focusedErrorBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                              ),
                              onFieldSubmitted: (s) {
                                if (widget.onFieldSubmitted != null) {
                                  widget.onFieldSubmitted!(widget.dataItem, widget.fieldName);
                                }
                              },

                              // onFieldSubmitted: (value) {
                              //   print("AAA");
                              // },
                              // onFieldSubmitted: (string) {
                              //   if (widget.onEditingComplete != null) {
                              //     widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                              //   }
                              // },
                              onEditingComplete: () {
                                if (keyboard != TextInputType.multiline) {
                                  if (widget.onEditingComplete != null) {
                                    widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                                  }

                                  Future.delayed(const Duration(milliseconds: 10), () {
                                    if (context.mounted) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  });
                                }
                                focus.unfocus();
                                if (widget.onFocusChanged != null) {
                                  widget.onFocusChanged!(false);
                                }
                              },
                              onChanged: (value) {
                                if (widget.onChanged != null) {
                                  widget.onChanged!(widget.dataItem);
                                }
                              },
                              textAlign: widget.textAlign,
                              style: widget.textStyle ?? TextStyle(color: nsgtheme.nsgInputTextColor, fontSize: fontSize),
                              readOnly: _disabled,
                            ),
                      if (!nsgtheme.nsgInputHintHidden && (!focus.hasFocus && textController.text == ''))
                        IgnorePointer(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: getHintPadding(),
                              child: widget.hint != null
                                  ? Text(
                                      widget.hint!,
                                      style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: nsgtheme.nsgInputHintColor),
                                    )
                                  : widget.labelWidget ??
                                        Text(
                                          (widget.required ?? widget.dataItem.isFieldRequired(widget.fieldName)) ? '${widget.label} *' : widget.label,
                                          style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: nsgtheme.nsgInputHintColor),
                                        ),
                            ),
                          ),
                        ),
                      if (widget.hint != null && focus.hasFocus && textController.text == '')
                        ValueListenableBuilder(
                          valueListenable: _notifier,
                          builder: (BuildContext context, bool val, Widget? child) {
                            if (_notifier.value == true) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: getHintPadding(),
                                  child: Text(
                                    widget.hint!,
                                    style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: nsgtheme.nsgInputHintColor),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (getValidateText() != '')
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    getValidateText(),
                    style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: ControlOptions.instance.colorError),
                  ),
                ),
            ],
          ),
    );
  }

  List<PhoneCountryData>? getPhoneCountryDataByCountryCodes() {
    if (widget.countryCodes == null) {
      return null;
    } else {
      List<PhoneCountryData> list = [];
      for (var countryCode in widget.countryCodes!) {
        if (PhoneCodes.getPhoneCountryDataByCountryCode(countryCode) != null) {
          list.add(PhoneCodes.getPhoneCountryDataByCountryCode(countryCode)!);
        }
      }
      return list;
    }
  }

  Widget? prefix() {
    if (widget.prefix != null) {
      return widget.prefix!;
    }
    return !_disabled
        ? null
        : widget.showLock
        ? widget.prefix ??
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Icon(Icons.lock, size: 12, color: ControlOptions.instance.colorMain),
              )
        : null;
  }

  String getValidateText() {
    if (widget.controller != null && widget.controller!.fieldsWithError.isNotEmpty && widget.controller!.fieldsWithError[widget.fieldName] != null) {
      return widget.controller!.fieldsWithError[widget.fieldName]!;
    } else {
      return widget.validateText;
    }
  }

  EdgeInsets getHintPadding() {
    if (widget.contentPadding != null) {
      return widget.contentPadding != null
          ? widget.contentPadding! //.subtract(const EdgeInsets.symmetric(vertical: 4)).resolve(TextDirection.ltr)
          : EdgeInsets.zero;
    } else {
      return nsgtheme.nsgInputContentPadding
          .subtract(EdgeInsets.only(top: nsgtheme.nsgInputContentPadding.top, bottom: nsgtheme.nsgInputContentPadding.bottom))
          .resolve(TextDirection.ltr);
    }
  }

  EdgeInsets getContentPadding() {
    if (widget.contentPadding != null) {
      return widget.contentPadding!;
    } else {
      EdgeInsets padding = nsgtheme.nsgInputContentPadding
          .subtract(
            EdgeInsets.fromLTRB(
              0,
              4,
              !widget.showDeleteIcon
                  ? 0
                  : useSelectionController
                  ? -15
                  : -15,
              4,
            ),
          )
          .resolve(TextDirection.ltr);
      return padding;
    }
  }

  EdgeInsets getContentPaddingPhoneCode() {
    if (widget.contentPadding != null) {
      return widget.contentPadding!;
    } else {
      EdgeInsets padding = nsgtheme.nsgInputContentPadding.subtract(EdgeInsets.fromLTRB(0, 7, 10, 7)).resolve(TextDirection.ltr);
      return padding;
    }
  }

  /// Оборачивание disabled текстового поля, чтобы обработать нажатие на него
  Widget _gestureWrap({required Widget interactiveWidget, required bool clearIcon}) {
    if (inputType == NsgInputType.stringValue && widget.onPressed == null) {
      return clearIcon == true ? _addClearIcon(interactiveWidget) : interactiveWidget;
    } else {
      if (inputType == NsgInputType.phoneCode) {
        return interactiveWidget;
      }
      return clearIcon == true
          ? _addClearIcon(
              InkWell(
                onTap: _onPressed,
                child: AbsorbPointer(child: interactiveWidget),
              ),
            )
          : InkWell(
              onTap: _onPressed,
              child: AbsorbPointer(child: interactiveWidget),
            );
    }
  }

  /// Оборачиваем Stack и добавляем иконку "очистить поле"
  Widget _addClearIcon(Widget child) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        child,
        if (!_disabled && widget.showDeleteIcon)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                widget.dataItem[widget.fieldName] = widget.dataItem.getField(widget.fieldName).defaultValue;
                textController.text = widget.dataItem[widget.fieldName].toString();
                textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
                Future.delayed(const Duration(milliseconds: 10), () {
                  if (context.mounted) {
                    // ignore: use_build_context_synchronously
                    FocusScope.of(context).requestFocus(focus);
                    if (widget.onEditingComplete != null) {
                      widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                    }
                    if (widget.onChanged != null) {
                      widget.onChanged!(widget.dataItem);
                    }
                  }
                });

                setState(() {});
              },
              child: HoverWidget(
                hoverChild: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(Icons.close_outlined, color: nsgtheme.nsginputCloseIconColor, size: 16),
                ),
                onHover: (PointerEnterEvent event) {},
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(Icons.close_outlined, color: nsgtheme.nsginputCloseIconColorHover, size: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onPressed() {
    if (_disabled) {
      return;
    }
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }
    var filter = widget.getRequestFilter == null ? null : widget.getRequestFilter!();
    if (inputType == NsgInputType.dynamicList) {
      var field = widget.dataItem.getField(widget.fieldName);

      var value = field is NsgDataReferenceField ? widget.dataItem.getReferent(widget.fieldName) : widget.dataItem.getFieldValue(widget.fieldName);
      int initItem = widget.dynamicList.indexOf(value);
      int countItem = initItem;
      // for (var item in widget.dynamicList) {
      //   list.add(
      //     Text(
      //       item.toString(),
      //       style: TextStyle(color: nsgtheme.nsgInputDynamicListTextColor),
      //     ),
      //   );
      // }
      var selectedElement = value;
      ScrollController scrollController = ScrollController();
      showDialog(
        context: context,
        builder: (_) {
          Widget dynamicListWidget() {
            return StatefulBuilder(
              builder: (context, setstate) {
                List<Widget> list = [];
                for (var element in widget.dynamicList) {
                  list.add(
                    InkWell(
                      onTap: () {
                        selectedElement = element;
                        setstate(() {});
                      },
                      child: Container(
                        //key: GlobalKey(),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: element == selectedElement ? nsgtheme.nsgInputDynamicListBackSelectedColor : nsgtheme.nsgInputDynamicListBackColor,
                        height: 50,
                        child: Center(
                          child: Text(
                            element.toString(),
                            style: TextStyle(
                              fontWeight: element == selectedElement ? FontWeight.w600 : FontWeight.w400,
                              color: element == selectedElement ? nsgtheme.nsgInputDynamicListTextSelectedColor : nsgtheme.nsgInputDynamicListTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(children: list),
                );
              },
            );
          }

          List<Widget> dynamicListWidgets() {
            List<Widget> list = [];
            for (var element in widget.dynamicList) {
              // ignore: sized_box_for_whitespace
              list.add(
                Container(
                  width: 300,
                  //color: element == selectedElement ? nsgtheme.colorPrimary : Colors.transparent,
                  height: 50,
                  child: Center(
                    child: Text(
                      element.toString(),
                      style: TextStyle(
                        fontWeight: element == selectedElement ? FontWeight.w600 : FontWeight.w200,
                        //color: element == selectedElement ? nsgtheme.nsgInputDynamicListTextSelectedColor : nsgtheme.nsgInputDynamicListTextColor),
                        color: nsgtheme.nsgInputDynamicListTextColor,
                      ),
                    ),
                  ),
                ),
              );
            }
            return list;
          }

          return nsgBackDrop(
            child: kIsWeb || !(Platform.isAndroid || Platform.isIOS)
                // Если Веб и (не андроид и не иос)
                ? NsgPopUp(
                    width: 300,
                    onConfirm: () {
                      countItem = widget.dynamicList.indexOf(selectedElement);
                      textController.text = widget.dynamicList[countItem].toString();
                      widget.dataItem.setFieldValue(widget.fieldName, widget.dynamicList[countItem]);
                      setState(() {});
                      if (widget.onEditingComplete != null) {
                        widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                      }
                    },
                    title: widget.label,
                    // ignore: sized_box_for_whitespace
                    contentTop: Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: RawScrollbar(
                        minOverscrollLength: 100,
                        minThumbLength: 100,
                        thickness: 16,
                        trackBorderColor: nsgtheme.colorSecondary,
                        trackColor: nsgtheme.colorSecondary,
                        thumbColor: nsgtheme.colorPrimary,
                        radius: const Radius.circular(0),
                        thumbVisibility: true,
                        trackVisibility: true,
                        controller: scrollController,
                        child: SingleChildScrollView(controller: scrollController, child: dynamicListWidget()),
                      ),
                    ),
                  )
                : NsgPopUp(
                    width: 300,
                    onConfirm: () {
                      countItem = widget.dynamicList.indexOf(selectedElement);
                      textController.text = widget.dynamicList[countItem].toString();
                      widget.dataItem.setFieldValue(widget.fieldName, widget.dynamicList[countItem]);
                      if (widget.onEditingComplete != null) {
                        widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                      }
                      setState(() {});
                    },
                    title: widget.label,
                    contentTop: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      constraints: BoxConstraints(maxHeight: 300),
                      child: StatefulBuilder(
                        builder: (context, setstate) {
                          return CupertinoPicker(
                            // selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                            //   background: nsgtheme.colorPrimary.withAlpha(50),
                            // ),
                            backgroundColor: Colors.transparent,
                            itemExtent: 30,
                            onSelectedItemChanged: (value) {
                              countItem = value;
                              selectedElement = widget.dynamicList[countItem];
                              setstate(() {});
                            },
                            scrollController: FixedExtentScrollController(
                              initialItem: widget.dynamicList.indexOf(
                                widget.dataItem.getField(widget.fieldName) is NsgDataReferenceField
                                    ? widget.dataItem.getReferent(widget.fieldName)
                                    : widget.dataItem.getFieldValue(widget.fieldName),
                              ),
                            ),
                            children: dynamicListWidgets(),
                          );
                        },
                      ),
                    ),
                  ),
          );
        },
      );
    } else if (inputType == NsgInputType.reference) {
      selectionController!.selectedItem = widget.dataItem.getReferent(widget.fieldName);
      //Зенков 27.12.2022 Вызывается в form.selectFromArray
      //Перенес вызов ниже в случае передачи пользовательской формы
      //selectionController!.refreshData();
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        var form = NsgSelection(widgetType: widget.selectionWidgetType, inputType: inputType, controller: selectionController, rowWidget: widget.rowWidget);
        form.selectFromArray(
          widget.label,
          (item) {
            widget.dataItem.setFieldValue(widget.fieldName, selectionController!.selectedItem);
            if (widget.onChanged != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged!(widget.dataItem));
            }
            if (widget.onFocusChanged != null) {
              widget.onFocusChanged!(false);
            }
            if (widget.onEditingComplete != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => widget.onEditingComplete!(widget.dataItem, widget.fieldName));
            }
            if (widget.controller != null) {
              widget.controller!.sendNotify();
            } else {
              //Navigator.pop(context);
              setState(() {});
            }
            return;
          },
          context: context,
          filter: filter,
        );
      } else {
        //Иначе - вызываем переданную форму для подбора
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию

        selectionController!.refreshData(filter: filter);
        selectionController!.regime = NsgControllerRegime.selection;
        selectionController!.onSelected = (item) {
          Get.back();
          selectionController!.regime = NsgControllerRegime.view;
          selectionController!.onSelected = null;
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged!(widget.dataItem));
          }
          if (widget.onEditingComplete != null) {
            widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          }
          if (mounted) {
            setState(() {});
          }
        };
        Get.toNamed(widget.selectionForm);
      }
    } else if (inputType == NsgInputType.enumReference) {
      var enumItem = widget.dataItem.getReferent(widget.fieldName) as NsgEnum;
      var itemsArray = widget.itemsToSelect ?? enumItem.getAll();
      var form = NsgSelection(
        widgetType: widget.selectionWidgetType,
        allValues: itemsArray,
        selectedElement: enumItem,
        rowWidget: widget.rowWidget,
        inputType: NsgInputType.enumReference,
      );
      form.selectFromArray(
        widget.label,
        (item) {
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged!(widget.dataItem));
          }
          if (widget.onFocusChanged != null) {
            widget.onFocusChanged!(false);
          }
          if (widget.onEditingComplete != null) {
            widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          }
          setState(() {});
          return null;
        },
        context: context,
        filter: filter,
      );
    } else if (inputType == NsgInputType.referenceList) {
      var form = NsgMultiSelection(controller: selectionController!);
      form.selectedItems = (widget.dataItem[widget.fieldName] as List).cast<NsgDataItem>();
      selectionController!.refreshData(filter: filter);
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        form.selectFromArray(widget.label, '', (items) {
          widget.dataItem.setFieldValue(widget.fieldName, items);
          if (widget.onChanged != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged!(widget.dataItem));
          }
          if (widget.onEditingComplete != null) {
            widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          }
          setState(() {});
        }, filter: filter);
      } else {
        NsgNavigator.instance.toPage(widget.selectionForm);
      }
    } else if (inputType == NsgInputType.dateValue) {
      widget.formatDateTime == 'HH:mm'
          ? NsgTimePicker(
              dateForTime: widget.dataItem[widget.fieldName],
              initialTime: Duration(
                hours: (widget.dataItem[widget.fieldName] ?? DateTime.now()).hour,
                minutes: (widget.dataItem[widget.fieldName] ?? DateTime.now()).minute,
              ),
              onClose: (Duration endDate) {},
            ).showPopup(context, widget.dataItem[widget.fieldName].hour, widget.dataItem[widget.fieldName].minute, (value) {
              widget.dataItem[widget.fieldName] = value;
              if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
              if (widget.onEditingComplete != null) {
                widget.onEditingComplete!(widget.dataItem, widget.fieldName);
              }
              setState(() {});
            })
          : NsgDatePicker(
              firstDateTime: widget.firstDateTime,
              lastDateTime: widget.lastDateTime,
              // initialTime: DateTime(01, 01, 01).isAtSameMomentAs(widget.dataItem[widget.fieldName]) ||
              //         DateTime(1754, 01, 01).isAtSameMomentAs(widget.dataItem[widget.fieldName])
              initialTime: (widget.dataItem[widget.fieldName] as DateTime).year < 1900
                  ? widget.initialDateTime ?? NsgPeriod.beginOfDay(DateTime.now())
                  : widget.dataItem[widget.fieldName],
              onClose: (value) {},
            ).showPopup(context, widget.dataItem[widget.fieldName], (value) {
              widget.dataItem[widget.fieldName] = value;
              if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
              if (widget.onEditingComplete != null) {
                widget.onEditingComplete!(widget.dataItem, widget.fieldName);
              }
              // widget.dataItem[widget.fieldName] = value;
              setState(() {});
            });
    }
  }

  Widget _buildBoolWidget(bool fieldValue) {
    var animKey = ValueKey(widget.fieldName);
    Widget boolBox =
        widget.boolWidget ??
        StatefulBuilder(
          key: animKey,
          builder:
              ((context, setState) => NsgSwitchHorizontal(
                style: widget.nsgSwitchHorizontalStyle,
                text: widget.label,
                isOn: fieldValue,
                onTap: () {
                  fieldValue = !fieldValue;
                  widget.dataItem.setFieldValue(widget.fieldName, fieldValue);
                  if (widget.onEditingComplete != null) {
                    widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                  }
                  if (widget.updateController != null) {
                    widget.updateController!.update();
                  } else {
                    setState(() {});
                  }
                },
                child: widget.child,
              )
              //  CupertinoSwitch(
              //     trackColor: widget.trackColor ?? ControlOptions.instance.colorMainDarker,
              //     activeColor: widget.activeColor ?? ControlOptions.instance.colorMain,
              //     thumbColor: widget.thumbColor ?? ControlOptions.instance.colorGrey,
              //     value: fieldValue,
              //     onChanged: (value) {
              //       fieldValue = !fieldValue;
              //       widget.dataItem.setFieldValue(widget.fieldName, fieldValue);
              //       if (widget.updateController != null) {
              //         widget.updateController!.update();
              //       } else {
              //         setState(() {});
              //       }
              //     })
              ),
        );

    return Container(
      //key: widget.key ?? GlobalKey(),
      margin: widget.margin ?? nsgtheme.nsgInputMargin,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        color: widget.filledColor ?? ControlOptions.instance.colorMainBack,
        //border: Border(bottom: BorderSide(width: 1, color: widget.borderColor ?? nsgtheme.nsgInputBorderColor))
      ),
      child: boolBox,
      //  Row(
      //   children: widget.boolBoxPosition == BoolBoxPosition.end ? [label, boolBox] : [boolBox, label],
      // )
    );
  }
}

// Определяем параметры границ текстового поля

OutlineInputBorder defaultOutlineBorder({Color? color}) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color ?? ControlOptions.instance.colorGreyLighter),
    borderRadius: const BorderRadius.all(Radius.circular(10)),
  );
}

OutlineInputBorder errorOutlineBorder = OutlineInputBorder(
  borderSide: BorderSide(color: ControlOptions.instance.colorError),
  borderRadius: const BorderRadius.all(Radius.circular(10)),
);
OutlineInputBorder focusedOutlineBorder = OutlineInputBorder(
  borderSide: BorderSide(color: ControlOptions.instance.colorMain),
  borderRadius: const BorderRadius.all(Radius.circular(10)),
);

UnderlineInputBorder defaultUnderlineBorder({Color? color}) {
  return UnderlineInputBorder(
    borderSide: BorderSide(color: color ?? ControlOptions.instance.colorMain),
    borderRadius: BorderRadius.zero,
  );
}

UnderlineInputBorder errorUnderlineBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: ControlOptions.instance.colorError),
  borderRadius: BorderRadius.zero,
);
UnderlineInputBorder focusedUnderlineBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: ControlOptions.instance.colorMain),
  borderRadius: BorderRadius.zero,
);
