import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

import '../helpers.dart';

class NsgSearchTextfield extends StatefulWidget {
  final NsgBaseController? controller;
  final double borderRadius;
  final Function(String text)? onChanged;
  const NsgSearchTextfield({Key? key, required this.controller, this.borderRadius = 20, required this.onChanged}) : super(key: key);

  @override
  State<NsgSearchTextfield> createState() => _NsgSearchTextfieldState();
}

class _NsgSearchTextfieldState extends State<NsgSearchTextfield> {
  TextEditingController textEditController = TextEditingController();

  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller!.controllerFilter.isOpen = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    textEditController.dispose();
    if (widget.controller != null) {
      widget.controller!.controllerFilter.isOpen = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
          controller: textEditController,
          decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  NsgIcons.search,
                  color: nsgtheme.colorTertiary,
                  size: 20,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                  gapPadding: 8,
                  borderSide: BorderSide(color: ControlOptions.instance.colorTertiary),
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius))),
              focusedBorder: OutlineInputBorder(
                  gapPadding: 8,
                  borderSide: BorderSide(color: ControlOptions.instance.colorPrimary),
                  borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius))),
              suffixIcon: IconButton(
                  padding: const EdgeInsets.only(bottom: 0, right: 12, left: 8),
                  onPressed: (() {
                    textEditController.text = '';
                    if (widget.controller != null) {
                      widget.controller!.controllerFilter.searchString = textEditController.text;
                      widget.controller!.refreshData();
                    }
                    setState(() {});
                  }),
                  icon: Icon(
                    NsgIcons.close,
                    color: nsgtheme.colorTertiary,
                    size: 20,
                  )),
              // prefixIcon: Icon(Icons.search),
              hintText: tran.search,
              hintStyle: TextStyle(color: ControlOptions.instance.colorSecondary, fontWeight: FontWeight.w500)),
          textAlignVertical: TextAlignVertical.bottom,
          style: TextStyle(color: ControlOptions.instance.colorBase.c100),
          onChanged: (val) {
            if (widget.onChanged != null) {
              widget.onChanged!(val);
            }
            if (widget.controller != null) {
              widget.controller!.controllerFilter.searchString = textEditController.text;
              var filter = widget.controller!.getRequestFilter;
              if (textEditController.text.isNotEmpty) {
                var params = <String, dynamic>{};
                params.addAll({'globalSearch': true});
                filter.params?.addAll(params);

                filter.params ??= params;
              } else {
                filter = widget.controller!.getRequestFilter;
              }
              widget.controller!.controllerFilter.refreshControllerWithDelay(filter: filter);
              widget.controller!.sendNotify();
            }
          }),
    );
  }
}
