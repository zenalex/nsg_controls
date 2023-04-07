import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/formfields/nsg_position_boolBox.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:hovering/hovering.dart';
import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_controls/formfields/nsg_field_type.dart';

class NsgInput extends StatefulWidget {
  final String label;
  final bool disabled;
  final bool? gesture;
  final double? fontSize;
  final EdgeInsets? margin;
  final String? hint;
  final Widget? widget;
  final double borderRadius;
  final Function(NsgDataItem)? onChanged;
  final VoidCallback? onPressed;
  final Function(NsgDataItem, String)? onEditingComplete;
  final int maxLines;
  final int minLines;

  /// Красный текст валидации под текстовым полем
  final String validateText;

  /// Обязательное поле (будет помечено звездочкой)
  final bool? required;

  /// Высота
  final double? height;

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

  /// Контроллер, которому будет подаваться update при изменении значения в Input
  final NsgDataController? updateController;

  /// Функция прорисовки строки
  final Widget Function(NsgDataItem)? rowWidget;

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
  final bool showLabel;

  /// Показывать иконку удаления
  final bool showDeleteIcon;

  /// Выравнивание текста
  final TextAlign textAlign;

  /// Тип поля ввода
  final TextFormFieldType textFormFieldType;

  /// Цвет границ поля ввода
  final Color? borderColor;

  /// Закрашивать ли поле цветом
  final bool filled;

  /// Цвет окрашивания поля
  final Color? filledColor;

  /// Поджимать поле по высоте (встроенный параметр в textForField)
  final bool? isDense;

  /// Виджет для отображения в поле ввода как подсказка
  final Widget? lableWidget;

  /// Самая ранняя дата, доступная для выбора
  final DateTime? firstDateTime;

  /// Самая поздняя дата, доступная для выбора
  final DateTime? lastDateTime;

  /// Дата с которой будет предложен выбор, если поле равно 0г. или 1754г.
  final DateTime? initialDateTime;

  /// Показывать значек замка при параметре disabled
  final bool showLock;

  /// Поведение lable при вводе контента
  final FloatingLabelBehavior? floatingLabelBehavior;

  /// Стиль текста в поле ввода
  final TextStyle? textStyle;

  /// Заменяет  дефолтный виджет для bool значений на кастомный
  final Widget? boolWidget;

  /// Положение bool элемента относително lable или lableWidget
  final BoolBoxPosition? boolBoxPosition;

  /// Параметры отступа для значений внутри NsgInput
  final EdgeInsetsGeometry? contentPadding;

  /// Виджет для отображения в начале NsgInput
  final Widget? prefix;

  /// Иконка для отображения в конце NsgInput
  final Widget? suffixIcon;

  /// Форматировать отображение времени для входящего виджета
  final String? formatDateTime;

  const NsgInput(
      {Key? key,
      this.initialDateTime,
      this.firstDateTime,
      this.lastDateTime,
      this.validateText = '',
      this.textAlign = TextAlign.left,
      required this.dataItem,
      required this.fieldName,
      this.showDeleteIcon = true,
      this.showLabel = true,
      this.controller,
      this.selectionController,
      this.updateController,
      this.label = '',
      this.imagesList,
      this.disabled = false,
      this.fontSize,
      this.borderRadius = 15,
      this.margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      this.gesture,
      this.hint,
      this.onChanged,
      this.onPressed,
      this.onEditingComplete,
      this.maxLines = 1,
      this.minLines = 1,
      this.height = 50,
      this.widget,
      this.rowWidget,
      this.inputType = NsgInputType.autoselect,
      this.selectionForm = '',
      this.keyboard = TextInputType.multiline,
      this.mask,
      this.maskType,
      this.itemsToSelect,
      this.required,
      this.textFormFieldType = TextFormFieldType.underlineInputBorder,
      this.borderColor,
      this.filled = false,
      this.filledColor,
      this.isDense,
      this.lableWidget,
      this.showLock = true,
      this.floatingLabelBehavior = FloatingLabelBehavior.never,
      this.textStyle,
      this.boolWidget,
      this.boolBoxPosition = BoolBoxPosition.end,
      this.contentPadding,
      this.prefix,
      this.suffixIcon,
      this.formatDateTime})
      : super(key: key);

  @override
  State<NsgInput> createState() => _NsgInputState();

  NsgInputType selectInputType() {
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
  get useSelectionController => inputType == NsgInputType.reference || inputType == NsgInputType.referenceList;

  bool _ignoreChange = false;

  @override
  void initState() {
    super.initState();
    fontSize = widget.fontSize ?? ControlOptions.instance.sizeM;
    focus.addListener(() {
      if (focus.hasFocus) {
        setState(() {});
      } else {
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
        text = text.replaceAll(RegExp('[^0-9.]'), '');
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
      if (widget.onChanged != null) {
        widget.onChanged!(widget.dataItem);
      }
    });

    if (useSelectionController) {
      var sc = widget.selectionController ?? widget.dataItem.defaultController;
      if (sc == null) {
        assert(widget.dataItem.getField(widget.fieldName) is NsgDataBaseReferenceField, widget.fieldName);
        sc = NsgDefaultController(
            dataType: (widget.dataItem.getField(widget.fieldName) as NsgDataBaseReferenceField).referentElementType,
            controllerMode: NsgDataControllerMode(storageType: widget.dataItem.storageType));
      }
      selectionController = sc;
    }
    if (widget.controller != null && widget.controller!.readOnly == true) {
      //_disabled = true;
    }
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
        textController.text = widget.label;
      } else {
        textController.text = NsgDateFormat.dateFormat(fieldValue, format: widget.formatDateTime);
      }
    } else {
      textController.text = fieldValue.toString();
    }
    if (inputType == NsgInputType.boolValue) {
      return _buildBoolWidget(fieldValue);
    }

    int? _maxLength;
    if (widget.dataItem.getField(widget.fieldName) is NsgDataStringField) {
      _maxLength = (widget.dataItem.getField(widget.fieldName) as NsgDataStringField).maxLength;
      if (_maxLength == 0) {
        _maxLength = null;
      }
    }

    if (focus.hasFocus) {
      textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
    }

    return Container(
        margin: widget.margin,
        child: widget.widget ??
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showLabel)
                  Text(
                    focus.hasFocus || textController.text != ''
                        ? (widget.required ?? widget.dataItem.isFieldRequired(widget.fieldName))
                            ? widget.label + ' *'
                            : widget.label
                        : ' ',
                    style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: ControlOptions.instance.colorMainDark),
                  ),
                _gestureWrap(
                  clearIcon: fieldValue.toString() != '',
                  interactiveWidget: Container(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 2),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!focus.hasFocus && textController.text == '')
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              (widget.required ?? widget.dataItem.isFieldRequired(widget.fieldName)) ? widget.label + ' *' : widget.label,
                              style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: ControlOptions.instance.colorGrey),
                            ),
                          ),
                        if (widget.hint != null && focus.hasFocus && textController.text == '')
                          ValueListenableBuilder(
                              valueListenable: _notifier,
                              builder: (BuildContext context, bool val, Widget? child) {
                                if (_notifier.value == true) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.hint!,
                                      style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: ControlOptions.instance.colorGrey),
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }),
                        TextFormField(
                          controller: textController,
                          inputFormatters: widget.maskType == NsgInputMaskType.phone
                              ? [phoneFormatter]
                              : widget.mask != null
                                  ? [
                                      MaskTextInputFormatter(
                                        initialText: fieldValue.toString(),
                                        mask: widget.mask,
                                      )
                                    ]
                                  : null,
                          maxLength: _maxLength,
                          autofocus: false,
                          focusNode: focus,
                          maxLines: widget.maxLines,
                          minLines: widget.minLines,
                          keyboardType: keyboard,
                          cursorColor: ControlOptions.instance.colorText,
                          decoration: InputDecoration(
                            suffixIcon: widget.suffixIcon,
                            floatingLabelBehavior: widget.floatingLabelBehavior,
                            label: widget.lableWidget,
                            prefix: !_disabled
                                ? null
                                : widget.showLock
                                    ? widget.prefix ??
                                        Padding(
                                          padding: const EdgeInsets.only(right: 3.0),
                                          child: Icon(
                                            Icons.lock,
                                            size: 12,
                                            color: ControlOptions.instance.colorMain,
                                          ),
                                        )
                                    : null,
                            counterText: "",
                            contentPadding: widget.contentPadding ??
                                EdgeInsets.fromLTRB(
                                    0,
                                    4,
                                    !widget.showDeleteIcon
                                        ? 0
                                        : useSelectionController
                                            ? 25
                                            : 25,
                                    4),
                            isDense: widget.isDense ?? true,
                            filled: widget.filled,
                            fillColor: widget.filledColor,
                            border: widget.textFormFieldType == TextFormFieldType.outlineInputBorder
                                ? defaultOutlineBorder(color: widget.borderColor)
                                : defaultUnderlineBorder(color: widget.borderColor),
                            focusedBorder: widget.textFormFieldType == TextFormFieldType.outlineInputBorder ? focusedOutlineBorder : focusedUnderlineBorder,
                            enabledBorder: widget.textFormFieldType == TextFormFieldType.outlineInputBorder
                                ? defaultOutlineBorder(color: widget.borderColor)
                                : defaultUnderlineBorder(color: widget.borderColor),
                            errorBorder: widget.textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                            disabledBorder: widget.textFormFieldType == TextFormFieldType.outlineInputBorder
                                ? defaultOutlineBorder(color: widget.borderColor)
                                : defaultUnderlineBorder(color: widget.borderColor),
                            focusedErrorBorder: widget.textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                          ),
                          onFieldSubmitted: (string) {
                            if (widget.onEditingComplete != null) {}
                          },
                          textAlign: widget.textAlign,
                          style: widget.textStyle ?? TextStyle(color: ControlOptions.instance.colorText, fontSize: fontSize),
                          readOnly: _disabled,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.validateText != '')
                  Text(
                    widget.validateText,
                    style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: ControlOptions.instance.colorError),
                  ),
              ],
            ));
  }

  /// Оборачивание disabled текстового поля, чтобы обработать нажатие на него
  Widget _gestureWrap({required Widget interactiveWidget, required bool clearIcon}) {
    if (inputType == NsgInputType.stringValue && widget.onPressed == null) {
      return clearIcon == true ? _addClearIcon(interactiveWidget) : interactiveWidget;
    } else {
      return clearIcon == true
          ? _addClearIcon(InkWell(onTap: _onPressed, child: AbsorbPointer(child: interactiveWidget)))
          : InkWell(onTap: _onPressed, child: AbsorbPointer(child: interactiveWidget));
    }
  }

  /// Оборачиваем Stack и добавляем иконку "очистить поле"
  Widget _addClearIcon(Widget child) {
    return Stack(alignment: Alignment.centerRight, children: [
      child,
      if (!_disabled && widget.showDeleteIcon)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                widget.dataItem[widget.fieldName] = widget.dataItem.getField(widget.fieldName).defaultValue;
                textController.text = widget.dataItem[widget.fieldName].toString();

                Future.delayed(const Duration(milliseconds: 10), () {
                  FocusScope.of(context).requestFocus(focus);
                });
                textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
                if (widget.onEditingComplete != null) {
                  widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                }
                setState(() {});
              },
              child: HoverWidget(
                hoverChild: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.close_outlined,
                    color: ControlOptions.instance.colorMain,
                    size: 16,
                  ),
                ),
                onHover: (PointerEnterEvent event) {},
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.close_outlined,
                    color: ControlOptions.instance.colorGrey,
                    size: 16,
                  ),
                ),
              )),
        )
    ]);
  }

  void _onPressed() {
    if (_disabled) {
      return;
    }
    if (inputType == NsgInputType.reference) {
      selectionController!.selectedItem = widget.dataItem.getReferent(widget.fieldName);
      //Зенков 27.12.2022 Вызывается в form.selectFromArray
      //Перенес вызов ниже в случае передачи пользовательской формы
      //selectionController!.refreshData();
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        var form = NsgSelection(inputType: inputType, controller: selectionController, rowWidget: widget.rowWidget);
        form.selectFromArray(
          widget.label,
          (item) {
            widget.dataItem.setFieldValue(widget.fieldName, selectionController!.selectedItem);
            if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
            if (widget.onEditingComplete != null) {
              widget.onEditingComplete!(widget.dataItem, widget.fieldName);
            }
            if (widget.controller != null) {
              widget.controller!.sendNotify();
            } else {
              setState(() {});
            }
            return;
          },
        );
      } else {
        //Иначе - вызываем переданную форму для подбора
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        selectionController!.refreshData();
        selectionController!.regime = NsgControllerRegime.selection;
        selectionController!.onSelected = (item) {
          Get.back();
          selectionController!.regime = NsgControllerRegime.view;
          selectionController!.onSelected = null;
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
          if (widget.onEditingComplete != null) {
            widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          }
          setState(() {});
        };
        Get.toNamed(widget.selectionForm);
      }
    } else if (inputType == NsgInputType.enumReference) {
      var enumItem = widget.dataItem.getReferent(widget.fieldName) as NsgEnum;
      var itemsArray = widget.itemsToSelect ?? enumItem.getAll();
      var form = NsgSelection(allValues: itemsArray, selectedElement: enumItem, rowWidget: widget.rowWidget, inputType: NsgInputType.enumReference);
      form.selectFromArray(
        widget.label,
        (item) {
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
          if (widget.onEditingComplete != null) {
            widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          }
          setState(() {});
          return null;
        },
      );
    } else if (inputType == NsgInputType.referenceList) {
      var form = NsgMultiSelection(controller: selectionController!);
      form.selectedItems = (widget.dataItem[widget.fieldName] as List).cast<NsgDataItem>();
      selectionController!.refreshData();
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        form.selectFromArray(
          widget.label,
          '',
          (items) {
            widget.dataItem.setFieldValue(widget.fieldName, items);
            if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
            if (widget.onEditingComplete != null) {
              widget.onEditingComplete!(widget.dataItem, widget.fieldName);
            }
            setState(() {});
          },
        );
      } else {
        NsgNavigator.instance.toPage(widget.selectionForm);
      }
    } else if (inputType == NsgInputType.dateValue) {
      NsgDatePicker(
              firstDateTime: widget.firstDateTime,
              lastDateTime: widget.lastDateTime,
              initialTime: DateTime(01, 01, 01).isAtSameMomentAs(widget.dataItem[widget.fieldName]) ||
                      DateTime(1754, 01, 01).isAtSameMomentAs(widget.dataItem[widget.fieldName])
                  ? widget.initialDateTime ?? DateTime.now()
                  : widget.dataItem[widget.fieldName],
              onClose: (value) {})
          .showPopup(context, widget.dataItem[widget.fieldName], (value) {
        if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
        if (widget.onEditingComplete != null) {
          widget.onEditingComplete!(widget.dataItem, widget.fieldName);
        }
        widget.dataItem[widget.fieldName] = value;
        setState(() {});
      });
    }
  }

  Widget _buildBoolWidget(bool fieldValue) {
    Widget lable = widget.lableWidget ??
        Expanded(
            child: Text(
          widget.label,
          style: widget.textStyle ?? TextStyle(fontSize: ControlOptions.instance.sizeM),
        ));

    Widget boolBox = widget.boolWidget ??
        StatefulBuilder(
          builder: ((context, setState) => CupertinoSwitch(
              value: fieldValue,
              activeColor: ControlOptions.instance.colorMain,
              onChanged: (value) {
                fieldValue = !fieldValue;
                widget.dataItem.setFieldValue(widget.fieldName, fieldValue);
                if (widget.updateController != null) {
                  widget.updateController!.update();
                } else {
                  setState(() {});
                }
              })),
        );

    return Container(
        margin: widget.margin,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
            color: widget.filledColor ?? ControlOptions.instance.colorInverted,
            border: Border(bottom: BorderSide(width: 1, color: widget.borderColor ?? ControlOptions.instance.colorMain))),
        child: Row(
          children: widget.boolBoxPosition == BoolBoxPosition.end ? [lable, boolBox] : [boolBox, lable],
        ));
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
      borderSide: BorderSide(
        color: color ?? ControlOptions.instance.colorMain,
      ),
      borderRadius: BorderRadius.zero);
}

UnderlineInputBorder errorUnderlineBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: ControlOptions.instance.colorError,
    ),
    borderRadius: BorderRadius.zero);
UnderlineInputBorder focusedUnderlineBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: ControlOptions.instance.colorMain,
    ),
    borderRadius: BorderRadius.zero);
