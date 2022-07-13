import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';

import 'nsg_icon_button.dart';
import 'nsg_input_type.dart';
import 'nsg_selection.dart';
import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import 'nsg_control_options.dart';

class NsgInput extends StatefulWidget {
  final String? label;
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

  // Высота
  final double? height;

  /// Картинки для выводя рядом с текстом
  final List<String>? imagesList;

  /// Объект, значение поля которого отображается
  final NsgDataItem dataItem;

  /// Поле для отображения и задания значения
  final String fieldName;

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

  const NsgInput(
      {Key? key,
      required this.dataItem,
      required this.fieldName,
      this.selectionController,
      this.updateController,
      this.label,
      this.imagesList,
      this.disabled = false,
      this.fontSize = 16,
      this.borderRadius = 15,
      this.margin = const EdgeInsets.fromLTRB(0, 0, 0, 5),
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
      this.mask})
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
  late NsgInputType inputType;
  NsgBaseController? selectionController;

  get useSelectionController => inputType == NsgInputType.reference || inputType == NsgInputType.referenceList;

  @override
  void initState() {
    super.initState();
    //Проверяем, выбран ли тип инпута пользователем
    inputType = widget.selectInputType();
    if (useSelectionController) {
      var sc = widget.selectionController ?? widget.dataItem.defaultController;
      if (sc == null) {
        assert(widget.dataItem.getField(widget.fieldName) is NsgDataBaseReferenceField, widget.fieldName);
        sc = NsgDefaultController(dataType: (widget.dataItem.getField(widget.fieldName) as NsgDataBaseReferenceField).referentElementType);
      }
      selectionController = sc;
    }
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
      if (widget.disabled != true)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
          child: NsgIconButton(
              onPressed: () {
                widget.dataItem[widget.fieldName] = widget.dataItem.getField(widget.fieldName).defaultValue;
                setState(() {});
              },
              icon: Icons.close_outlined),
        )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.disabled);
    var fieldValue = widget.dataItem.getFieldValue(widget.fieldName);
    NsgDataItem? refItem;
    if (widget.dataItem.isReferenceField(widget.fieldName)) {
      refItem = widget.dataItem.getReferent(widget.fieldName)!;
      fieldValue = refItem.toString();
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
                Focus(
                    canRequestFocus: false,
                    // ↓ Focus widget handler e.g. user taps elsewhere
                    autofocus: false,
                    onFocusChange: (hasFocus) {
                      if (widget.onEditingComplete != null) {
                        hasFocus ? print('Focus') : widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                      }
                    },
                    child: TextFormField(
                      inputFormatters: widget.mask != null
                          ? [
                              MaskTextInputFormatter(
                                initialText: fieldValue.toString(),
                                mask: widget.mask,
                              )
                            ]
                          : null,
                      maxLength: _maxLength,
                      autofocus: false,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      keyboardType: widget.keyboard,
                      initialValue: fieldValue.toString(),
                      cursorColor: ControlOptions.instance.colorText,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: widget.label != null
                            ? widget.disabled == false
                                ? widget.label!
                                : '🔒 ${widget.label!}'
                            : ' ',
                        //hintText: "Phone number",
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.fromLTRB(0, 10, useSelectionController ? 25 : 0, 10), //  <- you can it to 0.0 for no space
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorMainDark)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorText)),
                        labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
                      ),
                      key: GlobalKey(),
                      onEditingComplete: () {
                        //FocusScope.of(context).nextFocus();
                        if (widget.onEditingComplete != null) {
                          widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                        }
                      },
                      onChanged: (String value) {
                        if (inputType == NsgInputType.stringValue) {
                          widget.dataItem.setFieldValue(widget.fieldName, value);
                        }
                        if (widget.onChanged != null) {
                          widget.onChanged!(widget.dataItem);
                        }
                      },
                      style: TextStyle(color: ControlOptions.instance.colorText, fontSize: widget.fontSize),
                      readOnly: widget.disabled,
                    ))),
        fieldValue.toString() != '');
  }

  void _onPressed() {
    if (inputType == NsgInputType.reference && widget.disabled != true) {
      selectionController!.selectedItem = widget.dataItem.getReferent(widget.fieldName);
      selectionController!.refreshData();
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        var form = NsgSelection(inputType: inputType, controller: selectionController, rowWidget: widget.rowWidget);
        form.selectFromArray(
          widget.label ?? '',
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
          setState(() {});
        };
        Get.toNamed(widget.selectionForm);
      }
    } else if (inputType == NsgInputType.enumReference && widget.disabled != true) {
      var enumItem = widget.dataItem.getReferent(widget.fieldName) as NsgEnum;
      var form = NsgSelection(allValues: enumItem.getAll(), selectedElement: enumItem, rowWidget: widget.rowWidget, inputType: NsgInputType.enumReference);
      form.selectFromArray(
        widget.label ?? '',
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
                Expanded(child: Text(widget.label ?? '')),
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
