import 'package:flutter/material.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class SearchWidget extends StatefulWidget {
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final NsgBaseController controller;
  final double borderRadius;
  const SearchWidget({super.key, required this.controller, this.borderRadius = 100, this.onSuffixIconTap, this.suffixIcon});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController textEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.controllerFilter.isOpen = true;
    textEditController.text = widget.controller.controllerFilter.searchString;
  }

  @override
  void dispose() {
    textEditController.dispose();
    widget.controller.controllerFilter.isOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        cursorColor: Theme.of(context).primaryColor,
        controller: textEditController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(NsgIcons.search, color: nsgtheme.colorTertiary, size: 20),
          ),
          enabledBorder: OutlineInputBorder(
            gapPadding: 8,
            borderSide: BorderSide(color: ControlOptions.instance.colorTertiary),
            borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          ),
          focusedBorder: OutlineInputBorder(
            gapPadding: 8,
            borderSide: BorderSide(color: ControlOptions.instance.colorPrimary),
            borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          ),
          suffixIcon: IconButton(
            padding: const EdgeInsets.only(bottom: 0, right: 12, left: 8),
            onPressed:
                widget.onSuffixIconTap ??
                () {
                  textEditController.text = '';
                  widget.controller.controllerFilter.searchString = textEditController.text;
                  widget.controller.refreshData();
                  setState(() {});
                },
            icon: widget.suffixIcon ?? Icon(NsgIcons.close, color: nsgtheme.colorTertiary, size: 20),
          ),
          // prefixIcon: Icon(Icons.search),
          hintText: tran.search,
          hintStyle: TextStyle(color: ControlOptions.instance.colorTertiary, fontWeight: FontWeight.w500),
        ),
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(color: ControlOptions.instance.colorBase.c100),
        onChanged: (val) {
          widget.controller.top = 0;
          widget.controller.controllerFilter.searchString = textEditController.text;
          var filter = widget.controller.getRequestFilter;
          if (textEditController.text.isNotEmpty) {
            var params = <String, dynamic>{};
            params.addAll({'globalSearch': true});
            filter.params?.addAll(params);

            filter.params ??= params;
          } else {
            filter = widget.controller.getRequestFilter;
          }
          widget.controller.controllerFilter.refreshControllerWithDelay(filter: filter);
          widget.controller.sendNotify();
        },
      ),
    );
  }
}
