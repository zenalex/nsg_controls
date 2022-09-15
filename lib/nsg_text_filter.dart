// импорт
import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_snackbar.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgTextFilter extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  NsgTextFilter({Key? key, required this.controller, this.isOpen, this.onSetFilter}) : super(key: key);

  final NsgDataController controller;
  final bool? isOpen;
  final VoidCallback? onSetFilter;

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    textController.text = controller.controllerFilter.searchString;
    var isFilterOpen = isOpen ?? controller.controllerFilter.isOpen;

    void setFilter() {
      if (controller.controllerFilter.searchString != textController.text) {
        controller.controllerFilter.searchString = textController.text;
        //controller.controllerFilter.refreshControllerWithDelay();
        controller.refreshData();
        if (onSetFilter != null) onSetFilter!();
      } else {
        nsgSnackbar(text: 'Фильтр по тексту не изменился', type: NsgSnarkBarType.warning);
      }
    }

    return !isFilterOpen
        ? const SizedBox()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                    child: TextFormField(
                      controller: textController,
                      autofocus: false,
                      cursorColor: ControlOptions.instance.colorText,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: 'Фильтр по тексту',
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 5), //  <- you can it to 0.0 for no space
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: ControlOptions.instance.colorMain)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: ControlOptions.instance.colorMainLight)),
                        labelStyle: TextStyle(color: ControlOptions.instance.colorMainDark, backgroundColor: Colors.transparent),
                      ),
                      onEditingComplete: () {
                        setFilter();
                      },
                      onChanged: (value) {},
                      style: TextStyle(color: ControlOptions.instance.colorText, fontSize: 16),
                    )),
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
}
