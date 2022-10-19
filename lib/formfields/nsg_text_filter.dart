// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_snackbar.dart';
import 'package:nsg_data/nsg_data.dart';

import '../nsg_icon_button.dart';

class NsgTextFilter extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  NsgTextFilter(
      {Key? key,
      this.label = 'Фильтр по тексту',
      this.margin = const EdgeInsets.fromLTRB(5, 5, 5, 5),
      this.required = false,
      required this.controller,
      this.isOpen,
      this.onSetFilter})
      : super(key: key);

  final NsgDataController controller;
  final bool? isOpen;
  final VoidCallback? onSetFilter;
  final String label;
  final bool required;
  final EdgeInsets margin;

  @override
  State<NsgTextFilter> createState() => _NsgTextFilterState();
}

late double textScaleFactor;
FocusNode focus = FocusNode();
late TextEditingController textController;

class _NsgTextFilterState extends State<NsgTextFilter> {
  @override
  void initState() {
    super.initState();

    focus.addListener(() {
      print("FOCUS ${focus.hasFocus}");
      if (focus.hasFocus) {
        setState(() {});
      }

      /* if (!focus.hasFocus && widget.onEditingComplete != null) {
        widget.onEditingComplete!(widget.dataItem, widget.fieldName);
      }*/
    });

    textController = TextEditingController();
    textController.addListener(() {});
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    focus.removeListener(() {});
    //focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textScaleFactor = MediaQuery.of(context).textScaleFactor;
    TextEditingController textController = TextEditingController();
    textController.text = widget.controller.controllerFilter.searchString;
    var isFilterOpen = widget.isOpen ?? widget.controller.controllerFilter.isOpen;

    void setFilter() {
      if (widget.controller.controllerFilter.searchString != textController.text || widget.controller.controllerFilter.searchString == '') {
        widget.controller.controllerFilter.searchString = textController.text;
        //controller.controllerFilter.refreshControllerWithDelay();
        widget.controller.refreshData();
        if (widget.onSetFilter != null) widget.onSetFilter!();
      } else {
        nsgSnackbar(text: 'Фильтр по тексту не изменился', type: NsgSnarkBarType.warning);
      }
    }

    textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));

    return !isFilterOpen
        ? const SizedBox()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: widget.margin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        // height: 12 * textScaleFactor,
                        child: Text(
                          focus.hasFocus || textController.text != ''
                              ? widget.required
                                  ? widget.label + ' *'
                                  : widget.label
                              : '',
                          style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: ControlOptions.instance.colorMainDark),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          //height: 20 * textScaleFactor,
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: ControlOptions.instance.colorMain))),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!focus.hasFocus && textController.text == '')
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.label,
                                    style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: ControlOptions.instance.colorGrey),
                                  ),
                                ),
                              TextFormField(
                                controller: textController,
                                focusNode: focus,
                                autofocus: false,
                                cursorColor: ControlOptions.instance.colorText,
                                decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: const EdgeInsets.fromLTRB(0, 2, 25, 2),
                                  isDense: true,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
                                ),
                                onEditingComplete: () {
                                  setFilter();
                                },
                                onChanged: (value) {},
                                style: TextStyle(color: ControlOptions.instance.colorText, fontSize: ControlOptions.instance.sizeM),
                              ),
                              Align(alignment: Alignment.centerRight, child: _addClearIcon()),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: () {
                    setFilter();
                  },
                  child: Icon(
                    Icons.search_outlined,
                    size: 24,
                    color: ControlOptions.instance.colorMain,
                  ),
                ),
              )
            ],
          );
  }

  /// Оборачиваем Stack и добавляем иконку "очистить поле"
  Widget _addClearIcon() {
    return NsgIconButton(
        onPressed: () {
          textController.text = '';
          widget.controller.controllerFilter.searchString = '';
          //widget.controller.refreshData();
          Future.delayed(const Duration(milliseconds: 10), () {
            FocusScope.of(context).requestFocus(focus);
          });
          setState(() {});
        },
        icon: Icons.close_outlined);
  }
}
