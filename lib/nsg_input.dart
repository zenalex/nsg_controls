import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'nsg_icon_button.dart';
import 'nsg_input_mask_type.dart';
import 'nsg_input_type.dart';
import 'nsg_selection.dart';
import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import 'nsg_control_options.dart';

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

  /// Обязательное поле
  final bool required;

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

  const NsgInput(
      {Key? key,
      this.validateText = '',
      required this.dataItem,
      required this.fieldName,
      this.controller,
      this.selectionController,
      this.updateController,
      this.label = '',
      this.imagesList,
      this.disabled = false,
      this.fontSize = 16,
      this.borderRadius = 15,
      this.margin = const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
      this.required = false})
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
      }

      return inputType;
    }
  }
}

class _NsgInputState extends State<NsgInput> {
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
    focus.addListener(() {
      if (focus.hasFocus) {
        textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
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
          textController.text = text;
          if (start != -1 && end != -1) textController.selection = TextSelection(baseOffset: start, extentOffset: end);
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
        sc = NsgDefaultController(dataType: (widget.dataItem.getField(widget.fieldName) as NsgDataBaseReferenceField).referentElementType);
      }
      selectionController = sc;
    }
    if (widget.controller != null && widget.controller!.readOnly == true) {
      //_disabled = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    focus.removeListener(() {});
    focus.dispose();
  }

  /// Оборачивание disabled текстового поля, чтобы обработать нажатие на него
  Widget _gestureWrap(Widget interactiveWidget, bool clearIcon) {
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
      if (_disabled != true)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: NsgIconButton(
              onPressed: () {
                widget.dataItem[widget.fieldName] = widget.dataItem.getField(widget.fieldName).defaultValue;
                textController.text = widget.dataItem[widget.fieldName].toString();

                Future.delayed(const Duration(milliseconds: 10), () {
                  FocusScope.of(context).requestFocus(focus);
                });
                textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
                if (widget.onEditingComplete != null) {
                  widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                }
                // setState(() {});
              },
              icon: Icons.close_outlined),
        )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var fieldValue = widget.dataItem.getFieldValue(widget.fieldName);
    if (widget.dataItem.isReferenceField(widget.fieldName)) {
      var refItem = widget.dataItem.getReferentOrNull(widget.fieldName);
      fieldValue = refItem == null ? '' : refItem.toString();
    }
    textController.text = fieldValue.toString();
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

    return _gestureWrap(
        Container(
            //height: widget.height,
            margin: widget.margin,
            padding: widget.widget == null ? const EdgeInsets.fromLTRB(0, 0, 0, 0) : const EdgeInsets.fromLTRB(0, 0, 0, 0),
            /* decoration: BoxDecoration(
                color: ControlOptions.instance.colorInverted,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),*/
            child: widget.widget ??
                /*   Focus(
                    canRequestFocus: false,
                    //autofocus: true,
                    onFocusChange: (hasFocus) {
                      isFocused = hasFocus;
                      if (widget.onEditingComplete != null) {
                        if (!hasFocus) {
                          widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                        }
                      }
                    },*/
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    if (widget.validateText != '')
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            widget.validateText,
                            style: TextStyle(fontSize: 10, color: ControlOptions.instance.colorError),
                          )),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: textController,
                          /*   onTap: () {
                            print('Widget ${focus.hasFocus}');
                            if (!focus.hasFocus) {
                              //print(textController.text.length);
                              textController.selection =
                                  TextSelection(baseOffset: 0, extentOffset: textController.text.length);
                            }
                          },*/
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
                            prefix: _disabled == false
                                ? null
                                : Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Icon(
                                      Icons.lock,
                                      size: 12,
                                      color: ControlOptions.instance.colorMain,
                                    ),
                                  ),

                            counterText: "",
                            labelText: widget.required ? widget.label + ' *' : widget.label,
                            hintText: widget.hint,
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 10, useSelectionController ? 25 : 25, 10), //  <- you can it to 0.0 for no space
                            isDense: true,
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2, color: widget.validateText != '' ? ControlOptions.instance.colorError : ControlOptions.instance.colorMain)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: ControlOptions.instance.colorMainLight)),
                            labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
                          ),
                          //key: GlobalKey(),
                          onFieldSubmitted: (string) {
                            //FocusScope.of(context).nextFocus();

                            if (widget.onEditingComplete != null) {
                              widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                            }
                          },
                          /*      onEditingComplete: () {
                            //FocusScope.of(context).nextFocus();
                            if (widget.onEditingComplete != null) {
                              widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                            }
                          },*/
                          /* onChanged: (String value) {
                            if (inputType == NsgInputType.stringValue) {
                              widget.dataItem.setFieldValue(widget.fieldName, value);
                            }
                            if (widget.onChanged != null) {
                              widget.onChanged!(widget.dataItem);
                            }
                          },*/
                          style: TextStyle(color: ControlOptions.instance.colorText, fontSize: widget.fontSize),
                          readOnly: _disabled,
                        ),
                      ),
                    ),
                  ],
                )),
        fieldValue.toString() != '');
  }

  void _onPressed() {
    if (inputType == NsgInputType.reference && _disabled != true) {
      selectionController!.selectedItem = widget.dataItem.getReferent(widget.fieldName);
      selectionController!.refreshData();
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        var form = NsgSelection(inputType: inputType, controller: selectionController, rowWidget: widget.rowWidget);
        form.selectFromArray(
          widget.label,
          (item) {
            widget.dataItem.setFieldValue(widget.fieldName, selectionController!.selectedItem);
            if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
            if (widget.onEditingComplete != null) widget.onEditingComplete!(widget.dataItem, widget.fieldName);
            setState(() {});
            return null;
          },
        );
      } else {
        //Иначе - вызываем переданную форму для подбора
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        selectionController!.regime = NsgControllerRegime.selection;
        selectionController!.onSelected = (item) {
          Get.back();
          selectionController!.regime = NsgControllerRegime.view;
          selectionController!.onSelected = null;
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
          if (widget.onEditingComplete != null) widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          //TODO: эксперимент. Нужен ли здесь setState?
          //setState(() {});
        };
        Get.toNamed(widget.selectionForm);
      }
    } else if (inputType == NsgInputType.enumReference && _disabled != true) {
      var enumItem = widget.dataItem.getReferent(widget.fieldName) as NsgEnum;
      var itemsArray = widget.itemsToSelect ?? enumItem.getAll();
      var form = NsgSelection(allValues: itemsArray, selectedElement: enumItem, rowWidget: widget.rowWidget, inputType: NsgInputType.enumReference);
      form.selectFromArray(
        widget.label,
        (item) {
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
          if (widget.onEditingComplete != null) widget.onEditingComplete!(widget.dataItem, widget.fieldName);
          setState(() {});
          return null;
        },
      );
    }
  }

  Widget _buildBoolWidget(bool fieldValue) {
    return Container(
        margin: widget.margin,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
            color: ControlOptions.instance.colorInverted,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
        child: SizedBox(
            height: 38,
            child: Row(
              children: [
                Expanded(child: Text(widget.label)),
                CupertinoSwitch(
                    value: fieldValue,
                    activeColor: ControlOptions.instance.colorMain,
                    onChanged: (value) {
                      widget.dataItem.setFieldValue(widget.fieldName, !fieldValue);
                      if (widget.updateController != null) {
                        widget.updateController!.update();
                      }
                    })
              ],
            )));
  }
}
