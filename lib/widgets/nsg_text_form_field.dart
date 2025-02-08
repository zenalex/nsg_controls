import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:hovering/hovering.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nsg_controls/formfields/nsg_field_type.dart';
import 'package:nsg_controls/formfields/nsg_input_mask_type.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgTextFormField extends StatefulWidget {
  const NsgTextFormField(
      {super.key,
      this.focusNode,
      this.showLabel = true,
      this.label,
      this.required = false,
      this.textController,
      this.labelColor,
      this.onEditingComplete,
      this.onChange,
      this.onFocusChanged,
      this.onKeyEvent,
      this.onFieldSubmitted,
      this.contentPadding,
      this.showDeleteIcon = true,
      this.defaultValue,
      this.textFormFieldType,
      this.borderColor,
      this.filledColor,
      this.textCapitalization = TextCapitalization.none,
      this.autocorrect = true,
      this.maskType,
      this.mask,
      this.autofocus = false,
      this.maxLines = 1,
      this.minLines = 1,
      this.suffixIcon,
      this.floatingLabelBehavior,
      this.filled,
      this.isDense,
      this.textAlign = TextAlign.start,
      this.textStyle,
      this.labelWidget,
      this.hint,
      this.prefix,
      this.showLock = false,
      this.maxLength,
      this.keyboard,
      this.fontSize,
      this.disabled = false});

  final TextEditingController? textController;
  final FocusNode? focusNode;
  final bool showLabel;
  final String? label;
  final bool required;
  final Color? labelColor;
  final Color? borderColor;
  final Color? filledColor;
  final void Function(String text)? onEditingComplete;
  final void Function(String text)? onChange;
  final void Function(bool isFocused)? onFocusChanged;
  final void Function(String text)? onFieldSubmitted;
  final EdgeInsets? contentPadding;
  final bool showDeleteIcon;
  final String? defaultValue;
  final TextFormFieldType? textFormFieldType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final NsgInputMaskType? maskType;
  final String? mask;
  final bool autofocus;
  final int maxLines;
  final int minLines;
  final Widget? suffixIcon;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final bool? isDense;
  final bool? filled;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final Widget? labelWidget;
  final String? hint;
  final Widget? prefix;
  final bool showLock;
  final int? maxLength;
  final TextInputType? keyboard;
  final double? fontSize;
  final bool disabled;

  ///Для обработки нажатия на физические кнопки при нахождении в фокусе
  final KeyEventResult Function(FocusNode focus, KeyEvent event)? onKeyEvent;

  @override
  State<StatefulWidget> createState() => _NsgTextFormFieldState();
}

class _NsgTextFormFieldState extends State<NsgTextFormField> {
  late TextEditingController textController;
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  FocusNode focus = FocusNode();
  TextFormFieldType? textFormFieldType;
  PhoneInputFormatter phoneFormatter = PhoneInputFormatter();
  late double fontSize;

  @override
  void initState() {
    textController = widget.textController ?? TextEditingController();
    focus = FocusNode(onKeyEvent: widget.onKeyEvent);
    textFormFieldType = widget.textFormFieldType ?? nsgtheme.nsgInputOutlineBorderType;
    fontSize = widget.fontSize ?? ControlOptions.instance.sizeM;

    // if (widget.focusNode != null && widget.focusNode!.hasFocus) {
    //   var start = textController.selection.start;
    //   var end = textController.selection.end;
    //   String text = textController.text;
    //   text = text.replaceAll(RegExp('[^0-9.-]'), '');
    //   if (textController.text != text) {
    //     textController.text = text;
    //     if (start != -1 && end != -1) {
    //       textController.selection = TextSelection(baseOffset: start, extentOffset: end);
    //     }
    //   }
    // }

    textController.addListener(() {
      if (textController.text == '') {
        _notifier.value = true;
      } else {
        _notifier.value = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _notifier.dispose();
    textController.dispose();
    focus.removeListener(() {});
    focus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (focus.hasFocus) {
      textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              focus.hasFocus || textController.text != '' || nsgtheme.nsgInputHintAlwaysOnTop == true
                  ? (widget.required)
                      ? '${widget.label!} *'
                      : widget.label!
                  : ' ',
              style: TextStyle(fontSize: ControlOptions.instance.sizeS, color: widget.labelColor ?? nsgtheme.nsgInputColorLabel),
            ),
          ),
        _gestureWrap(
          clearIcon: textController.text != '',
          interactiveWidget: Container(
            //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TextFormField(
                  textCapitalization: widget.textCapitalization,
                  autocorrect: widget.autocorrect,
                  controller: textController,
                  inputFormatters: widget.maskType == NsgInputMaskType.phone
                      ? [phoneFormatter]
                      : widget.mask != null
                          ? [
                              MaskTextInputFormatter(
                                initialText: textController.text,
                                mask: widget.mask,
                              )
                            ]
                          : null,
                  maxLength: widget.maxLength,
                  autofocus: widget.autofocus,
                  focusNode: focus,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  textInputAction: widget.keyboard == TextInputType.multiline ? TextInputAction.newline : TextInputAction.next,
                  keyboardType: widget.keyboard,
                  cursorColor: ControlOptions.instance.colorText,
                  decoration: InputDecoration(
                    suffixIcon: widget.suffixIcon,
                    floatingLabelBehavior: widget.floatingLabelBehavior,
                    //label: widget.labelWidget,
                    prefix: prefix(),
                    counterText: "",
                    contentPadding: getContentPadding(),
                    isDense: widget.isDense ?? true,
                    filled: widget.filled ?? nsgtheme.nsgInputFilled,
                    fillColor: widget.filledColor ?? nsgtheme.nsgInputColorFilled,
                    border: textFormFieldType == TextFormFieldType.outlineInputBorder
                        ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                        : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                    focusedBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? focusedOutlineBorder : focusedUnderlineBorder,
                    enabledBorder: textFormFieldType == TextFormFieldType.outlineInputBorder
                        ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                        : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                    errorBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                    disabledBorder: textFormFieldType == TextFormFieldType.outlineInputBorder
                        ? defaultOutlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor)
                        : defaultUnderlineBorder(color: widget.borderColor ?? nsgtheme.nsgInputBorderColor),
                    focusedErrorBorder: textFormFieldType == TextFormFieldType.outlineInputBorder ? errorOutlineBorder : errorUnderlineBorder,
                  ),
                  onFieldSubmitted: (s) {
                    if (widget.onFieldSubmitted != null) {
                      widget.onFieldSubmitted!(textController.text);
                    }
                  },
                  // onFieldSubmitted: (value) {
                  //   print("AAA");
                  // },
                  // onFieldSubmitted: (string) {
                  //   if (widget.onEditingComplete != null) {
                  //     widget.onEditingComplete!(widget.dataItem, widget.fieldName);
                  //   }
                  // },

                  onEditingComplete: () {
                    if (widget.keyboard != TextInputType.multiline) {
                      if (widget.onEditingComplete != null) {
                        widget.onEditingComplete!(textController.text);
                      }

                      Future.delayed(const Duration(milliseconds: 10), () {
                        if (context.mounted) {
                          FocusScope.of(context).unfocus();
                        }
                      });
                    }
                    focus.unfocus();
                    if (widget.onFocusChanged != null) {
                      widget.onFocusChanged!(false);
                    }
                  },
                  onChanged: (value) {
                    if (widget.onChange != null) {
                      widget.onChange!(textController.text);
                    }
                  },
                  textAlign: widget.textAlign,
                  style: widget.textStyle ?? TextStyle(color: nsgtheme.nsgInputTextColor, fontSize: fontSize),
                  readOnly: widget.disabled,
                ),
                if (!nsgtheme.nsgInputHintHidden && (!focus.hasFocus && textController.text == ''))
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: getHintPadding(),
                        child: widget.hint != null
                            ? Text(
                                widget.hint!,
                                style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: nsgtheme.nsgInputHintColor),
                              )
                            : widget.labelWidget ??
                                Text(
                                  (widget.required) ? '${widget.label ?? ""} *' : widget.label ?? "",
                                  style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: nsgtheme.nsgInputHintColor),
                                ),
                      ),
                    ),
                  ),
                if (widget.hint != null && focus.hasFocus && textController.text == '')
                  ValueListenableBuilder(
                      valueListenable: _notifier,
                      builder: (BuildContext context, bool val, Widget? child) {
                        if (_notifier.value == true) {
                          return Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: getHintPadding(),
                                child: Text(
                                  widget.hint!,
                                  style: TextStyle(fontSize: ControlOptions.instance.sizeM, color: nsgtheme.nsgInputHintColor),
                                ),
                              ));
                        } else {
                          return const SizedBox();
                        }
                      }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  EdgeInsets getHintPadding() {
    if (widget.contentPadding != null) {
      return widget.contentPadding != null
          ? widget.contentPadding! //.subtract(const EdgeInsets.symmetric(vertical: 4)).resolve(TextDirection.ltr)
          : EdgeInsets.zero;
    } else {
      return nsgtheme.nsgInputContentPadding
          .subtract(EdgeInsets.only(top: nsgtheme.nsgInputContentPadding.top, bottom: nsgtheme.nsgInputContentPadding.bottom))
          .resolve(TextDirection.ltr);
    }
  }

  EdgeInsets getContentPadding() {
    if (widget.contentPadding != null) {
      return widget.contentPadding!;
    } else {
      EdgeInsets padding = nsgtheme.nsgInputContentPadding.subtract(EdgeInsets.fromLTRB(0, 4, !widget.showDeleteIcon ? 0 : -15, 4)).resolve(TextDirection.ltr);
      return padding;
    }
  }

  Widget _gestureWrap({required Widget interactiveWidget, required bool clearIcon}) {
    return clearIcon == true ? _addClearIcon(interactiveWidget) : interactiveWidget;
  }

  Widget? prefix() {
    if (widget.prefix != null) {
      return widget.prefix!;
    }
    return !widget.disabled
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
            : null;
  }

  /// Оборачиваем Stack и добавляем иконку "очистить поле"
  Widget _addClearIcon(Widget child) {
    return Stack(alignment: Alignment.centerRight, children: [
      child,
      if (!widget.disabled && widget.showDeleteIcon)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                //TODO: Если только числа, и нет значения по умолчанию - 0
                textController.text = widget.defaultValue ?? "";
                textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
                Future.delayed(const Duration(milliseconds: 10), () {
                  if (context.mounted) {
                    // ignore: use_build_context_synchronously
                    FocusScope.of(context).requestFocus(focus);
                  }
                  if (widget.onEditingComplete != null) {
                    widget.onEditingComplete!(textController.text);
                  }
                  if (widget.onChange != null) {
                    widget.onChange!(textController.text);
                  }
                });

                setState(() {});
              },
              child: HoverWidget(
                hoverChild: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.close_outlined,
                    color: nsgtheme.nsginputCloseIconColor,
                    size: 16,
                  ),
                ),
                onHover: (PointerEnterEvent event) {},
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.close_outlined,
                    color: nsgtheme.nsginputCloseIconColorHover,
                    size: 16,
                  ),
                ),
              )),
        )
    ]);
  }

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
}
