import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';

import 'nsg_icon_button.dart';
import 'nsg_input_type.dart';
import 'nsg_selection.dart';
import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';
import 'nsg_control_options.dart';

class NsgInput extends StatefulWidget {
  final String? label;
  final bool? disabled;
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
  final NsgDataController? selectionController;

  /// Контроллер, которому будет подаваться update при изменении значения в Input
  final NsgDataController? updateController;

  ///Функция прорисовки строки
  final Widget Function(NsgDataItem)? rowWidget;

  ///Тип поля ввода. Если тип не задан (NsgInputType.autoselect), он будет выбран автоматически,
  ///исходя из типа данных поля объекта
  final NsgInputType inputType;

  ///В случае задания формы для подбора значений для ссылочный полей, вместо стандартной формы будет выполнен переход
  ///на данную форму в режиме контроллера выбор значения
  final String selectionForm;

  const NsgInput(
      {Key? key,
      required this.dataItem,
      required this.fieldName,
      this.selectionController,
      this.updateController,
      this.label,
      this.imagesList,
      this.disabled,
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
      this.selectionForm = ''})
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

  @override
  void initState() {
    super.initState();
    //Проверяем, выбран ли тип инпута пользователем
    inputType = widget.selectInputType();
    //Проверяем заполненность ключевых полей для выбранного типа данных
    if (inputType == NsgInputType.reference) {
      assert(widget.selectionController != null, widget.fieldName);
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
    var fieldValue = widget.dataItem.getFieldValue(widget.fieldName);
    NsgDataItem? refItem;
    if (widget.dataItem.isReferenceField(widget.fieldName)) {
      refItem = widget.dataItem.getReferent(widget.fieldName)!;
      fieldValue = refItem.toString();
    }
    if (inputType == NsgInputType.boolValue) {
      return _buildBoolWidget(fieldValue);
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
                        hasFocus ? print('') : widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                      }
                    },
                    child: TextFormField(
                      autofocus: false,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      keyboardType: TextInputType.multiline,
                      //maxLines: null,
                      //expands: true,
                      initialValue: fieldValue.toString(),
                      //keyboardType: TextInputType.number,
                      cursorColor: ControlOptions.instance.colorText,
                      decoration: InputDecoration(
                        labelText: widget.label != null
                            ? widget.disabled == null
                                ? '${widget.label!}'
                                : '🔒 ${widget.label!}'
                            : ' ',
                        //hintText: "Phone number",
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.fromLTRB(0, 10, widget.selectionController != null ? 25 : 0, 10), //  <- you can it to 0.0 for no space
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorMainDark)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ControlOptions.instance.colorText)),
                        labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
                      ),

                      key: GlobalKey(),
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
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
                      readOnly: widget.disabled == null ? false : true,
                    ))),
        fieldValue.toString() != '');
  }

  void _onPressed() {
    if (inputType == NsgInputType.reference && widget.disabled != true) {
      widget.selectionController!.selectedItem = widget.dataItem.getReferent(widget.fieldName);
      widget.selectionController!.refreshData();
      if (widget.selectionForm == '') {
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        var form = NsgSelection(inputType: inputType, controller: widget.selectionController!, rowWidget: widget.rowWidget);
        form.selectFromArray(
          widget.label ?? '',
          (item) {
            widget.dataItem.setFieldValue(widget.fieldName, widget.selectionController!.selectedItem);
            if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
            if (widget.onEditingComplete != null) widget.onEditingComplete!(widget.dataItem, widget.fieldName);
            setState(() {});
            return null;
          },
        );
      } else {
        //Иначе - вызываем переданную форму для подбора
        //Если формы для выбора не задана: вызываем форму подбора по умолчанию
        widget.selectionController!.regime = NsgControllerRegime.selection;
        widget.selectionController!.onSelected = (item) {
          Get.back();
          widget.selectionController!.regime = NsgControllerRegime.view;
          widget.selectionController!.onSelected = null;
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
