import 'package:flutter/material.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class SearchWidget extends StatefulWidget {
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final NsgBaseController controller;
  final double borderRadius;
  final EdgeInsets? padding;
  final TextEditingController? textController;
  const SearchWidget({super.key, required this.controller, this.borderRadius = 100, this.onSuffixIconTap, this.suffixIcon, this.padding, this.textController});

  @override
  State<SearchWidget> createState() => SearchWidgetState();

  ///Для перекрытия в каждом проекте
  InputDecoration decoration(SearchWidgetState state) => InputDecoration(
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Icon(NsgIcons.search, color: nsgtheme.colorTertiary, size: 20),
    ),
    enabledBorder: OutlineInputBorder(
      gapPadding: 8,
      borderSide: BorderSide(color: ControlOptions.instance.colorTertiary),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    ),
    focusedBorder: OutlineInputBorder(
      gapPadding: 8,
      borderSide: BorderSide(color: ControlOptions.instance.colorPrimary),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    ),
    suffixIcon: IconButton(
      padding: const EdgeInsets.only(bottom: 0, right: 12, left: 8),
      onPressed:
          onSuffixIconTap ??
          () {
            state.textEditController.text = '';
            controller.controllerFilter.searchString = state.textEditController.text;
            controller.refreshData();
          },
      icon: suffixIcon ?? Icon(NsgIcons.close, color: nsgtheme.colorTertiary, size: 20),
    ),
    // prefixIcon: Icon(Icons.search),
    hintText: tran.search,
    hintStyle: TextStyle(color: ControlOptions.instance.colorTertiary, fontWeight: FontWeight.w500),
  );

  ///Для перекрытия в каждом проекте
  TextAlignVertical get textAlignVertical => TextAlignVertical.bottom;

  ///Для перекрытия в каждом проекте
  TextStyle get textStyle => TextStyle(color: ControlOptions.instance.colorBase.c100);
}

class SearchWidgetState extends State<SearchWidget> {
  late TextEditingController textEditController = widget.textController ?? TextEditingController();

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
    return Padding(
      padding: widget.padding ?? EdgeInsets.all(0),
      child: SizedBox(
        height: 44,
        child: TextField(
          cursorColor: Theme.of(context).primaryColor,
          controller: textEditController,
          decoration: widget.decoration(this),
          textAlignVertical: widget.textAlignVertical,
          style: widget.textStyle,
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
      ),
    );
  }
}
