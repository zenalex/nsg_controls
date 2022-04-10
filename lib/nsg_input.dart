import 'package:flutter/cupertino.dart';

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
  final Function(NsgDataItem)? onChanged;
  final VoidCallback? onPressed;
  final VoidCallback? onEditingComplete;
  final int? maxlines;

  /// Картинки для выводя рядом с текстом
  final List<String>? imagesList;

  /// Объект, значение поля которого отображается
  final NsgDataItem dataItem;

  /// Поле для отображения и задания значения
  final String fieldName;

  /// Контроллер для выбора связанного значения
  final NsgBaseController? selectionController;

  /// Контроллер, которому будет подаваться update при изменении значения в Input
  final NsgBaseController? updateController;

  ///Функция прорисовки строки
  final Widget Function(NsgDataItem)? rowWidget;

  ///Тип поля ввода. Если тип не задан, он будет выбран автоматически,
  ///исходя из типа данных поля объекта
  late NsgInputType inputType;

  NsgInput(
      {Key? key,
      required this.dataItem,
      required this.fieldName,
      this.selectionController,
      this.updateController,
      this.label,
      this.imagesList,
      this.disabled,
      this.fontSize = 16,
      this.margin = const EdgeInsets.fromLTRB(0, 10, 0, 5),
      this.gesture,
      this.hint,
      this.onChanged,
      this.onPressed,
      this.onEditingComplete,
      this.maxlines,
      this.widget,
      this.rowWidget,
      NsgInputType? userInputType})
      : super(key: key) {
    //Проверяем, выбран ли тип инпута пользователем
    if (userInputType == null) {
      //Если не выбран, задаем его автоматически, исходя из типа данных fieldName
      if (dataItem.getField(fieldName) is NsgDataReferenceField) {
        inputType = NsgInputType.reference;
      } else if (dataItem.getField(fieldName) is NsgDataEnumReferenceField) {
        inputType = NsgInputType.enumReference;
      } else if (dataItem.getField(fieldName) is NsgDataBoolField) {
        inputType = NsgInputType.boolValue;
      } else if (dataItem.getField(fieldName) is NsgDataStringField ||
          dataItem.getField(fieldName) is NsgDataIntField ||
          dataItem.getField(fieldName) is NsgDataDoubleField) {
        inputType = NsgInputType.stringValue;
      } else {
        throw Exception("Не указан тип поля ввода, тип данных неизвестен");
      }
    } else {
      //Если выбран, проверяем на допустимость типа данный fieldName
      if (userInputType == NsgInputType.reference) {
        assert(dataItem.getField(fieldName) is NsgDataReferenceField);
      } else if (userInputType == NsgInputType.enumReference) {
        assert(dataItem.getField(fieldName) is NsgDataReferenceField);
      } else if (userInputType == NsgInputType.boolValue) {
        assert(dataItem.getField(fieldName) is NsgDataBoolField);
      } else if (userInputType == NsgInputType.stringValue) {
        assert(dataItem.getField(fieldName) is NsgDataStringField);
      }

      inputType = userInputType;
    }
    //Проверяем заполненность ключевых полей для выбранного типа данных
    if (inputType == NsgInputType.reference) {
      assert(selectionController != null);
    }
  }

  @override
  State<NsgInput> createState() => _NsgInputState();
}

class _NsgInputState extends State<NsgInput> {
  /// Оборачивание disabled текстового поля, чтобы обработать нажатие на него
  Widget _gestureWrap(Widget interactiveWidget, bool noIcon) {
    if (widget.inputType == NsgInputType.stringValue &&
        widget.onPressed == null) {
      return interactiveWidget;
    }
    return GestureDetector(
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AbsorbPointer(child: interactiveWidget),
          if (noIcon == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 10, 0),
              child: Icon(
                Icons.unfold_more,
                size: 24,
                color: ControlOptions.instance.colorText,
              ),
            )
        ],
      ),
      onTap: _onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    var fieldValue = widget.dataItem.getFieldValue(widget.fieldName);
    if (widget.dataItem.isReferenceField(widget.fieldName)) {
      var refItem = widget.dataItem.getReferent(widget.fieldName)!;
      fieldValue = refItem.toString();
    }
    if (widget.inputType == NsgInputType.boolValue) {
      return _buildBoolWidget(fieldValue);
    }
    return _gestureWrap(
        Container(
            height: 50,
            margin: widget.margin,
            padding: widget.widget == null
                ? const EdgeInsets.fromLTRB(30, 0, 30, 0)
                : const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
                color: ControlOptions.instance.colorInverted,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    width: 2, color: ControlOptions.instance.colorMain)),
            child: Center(
              child: widget.widget ??
                  TextFormField(
                    key: GlobalKey(),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: widget.maxlines ?? 1,
                    cursorColor: ControlOptions.instance.colorText,
                    initialValue: fieldValue.toString(),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      if (widget.onEditingComplete != null) {
                        widget.onEditingComplete!();
                      }
                    },
                    onChanged: (String value) {
                      if (widget.inputType == NsgInputType.stringValue) {
                        widget.dataItem.setFieldValue(widget.fieldName, value);
                      }
                      if (widget.onChanged != null) {
                        widget.onChanged!(widget.dataItem);
                      }
                    },
                    style: TextStyle(
                        color: ControlOptions.instance.colorText,
                        fontSize: widget.fontSize,
                        height: 1),
                    //requestController.requestNew.requestSubjectName.toUpperCase(),
                    readOnly: (widget.disabled == null) ? false : true,
                    decoration: InputDecoration(
                      fillColor: ControlOptions.instance.colorInverted,
                      filled: true,
                      alignLabelWithHint: true,
                      hintText: widget.hint != null
                          ? '${widget.hint}'.toUpperCase()
                          : '',
                      label: Center(
                          child: Text(
                        widget.label != null
                            ? '   ${widget.label!.toUpperCase()}   '
                            : '',
                      )),
                      //labelText: label != null ? '$label'.toUpperCase() : '',
                      labelStyle: TextStyle(
                          color: ControlOptions.instance.colorMainDarker,
                          backgroundColor:
                              ControlOptions.instance.colorInverted),

                      //labelText: '$title'.toUpperCase(),
                      contentPadding: const EdgeInsets.only(
                          left: 20.0, bottom: 10.0, top: 10.0, right: 20.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //floatingLabelBehavior: FloatingLabelBehavior.always,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
            )),
        widget.widget == null ? false : true);
  }

  void _onPressed() {
    if (widget.inputType == NsgInputType.reference) {
      widget.selectionController!.selectedItem =
          widget.dataItem.getReferent(widget.fieldName);

      var form = NsgSelection(
          inputType: widget.inputType,
          controller: widget.selectionController!,
          rowWidget: widget.rowWidget);
      form.selectFromArray(
        widget.label ?? '',
        (item) {
          widget.dataItem.setFieldValue(
              widget.fieldName, widget.selectionController!.selectedItem);
          if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
          setState(() {});
          return null;
        },
      );
    } else if (widget.inputType == NsgInputType.enumReference) {
      var enumItem = widget.dataItem.getReferent(widget.fieldName) as NsgEnum;
      var form = NsgSelection(
          allValues: enumItem.getAll(),
          selectedElement: enumItem,
          rowWidget: widget.rowWidget,
          inputType: NsgInputType.enumReference);
      form.selectFromArray(
        widget.label ?? '',
        (item) {
          widget.dataItem.setFieldValue(widget.fieldName, item);
          if (widget.onChanged != null) widget.onChanged!(widget.dataItem);
          setState(() {});
          return null;
        },
      );
    }
  }

  Widget _buildBoolWidget(bool fieldValue) {
    return Container(
        margin: widget.margin,
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
            color: ControlOptions.instance.colorInverted,
            borderRadius: BorderRadius.circular(15),
            border:
                Border.all(width: 2, color: ControlOptions.instance.colorMain)),
        child: SizedBox(
            height: 38,
            child: Row(
              children: [
                Expanded(child: Text(widget.label ?? '')),
                CupertinoSwitch(
                    value: fieldValue,
                    activeColor: ControlOptions.instance.colorMain,
                    onChanged: (value) {
                      widget.dataItem
                          .setFieldValue(widget.fieldName, !fieldValue);
                      if (widget.updateController != null) {
                        widget.updateController!.update();
                      }
                    })
              ],
            )));
  }
}
