import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

class NsgDialogBodyController {
  NsgDialogBodyState? currentState;

  BuildContext get currentContext {
    if (currentState != null) {
      BuildContext context = currentState!.context;
      return context;
    } else {
      throw ErrorDescription('currentState == null!');
    }
  }

  //AnimationController transitionAnimationController = AnimationController(vsync: vsync);
  Future openDialog(Widget child, {EdgeInsets? padding, bool enableDrag = true, bool autoHeight = false}) async {
    if (currentState != null) {
      return await currentState!.openDialog(child, padding: padding, enableDrag: enableDrag, autoHeight: autoHeight);
    } else {
      throw ErrorDescription('currentState == null!');
    }
  }
}

class NsgDialog {
  Future<void> show(
      {required BuildContext context,
      required Widget child,
      AnimationController? animationController,
      EdgeInsets? padding,
      bool enableDrag = true,
      bool autoHeight = false}) {
    return showModalBottomSheet<void>(
      barrierColor: nsgtheme.colorModalBack.withAlpha(200),
      enableDrag: autoHeight ? false : enableDrag,
      useSafeArea: autoHeight ? false : true,
      transitionAnimationController: animationController,
      context: context,
      constraints: autoHeight
          ? BoxConstraints(maxWidth: nsgtheme.appMinWidth)
          : BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - 40, maxWidth: nsgtheme.appMinWidth),
      isScrollControlled: autoHeight ? false : true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: nsgtheme.colorMainBack,
            //    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Padding(
              padding: padding ?? const EdgeInsets.only(bottom: 10),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class NsgDialogBody extends StatefulWidget {
  const NsgDialogBody({super.key, this.child, this.controller});
  final Widget? child;
  final NsgDialogBodyController? controller;

  @override
  State<NsgDialogBody> createState() => NsgDialogBodyState();
}

class NsgDialogBodyState extends State<NsgDialogBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _padding;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );

    _padding = Tween(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.controller != null) {
      widget.controller!.currentState = this;
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) {
      widget.controller!.currentState = this;
    }
    return AnimatedBuilder(
        animation: _padding,
        builder: (ctx, ch) => Padding(
              padding: EdgeInsets.all(_padding.value),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_padding.value),
                child: Scaffold(
                  body: widget.child,
                ),
              ),
            ));
  }

  Future openDialog(Widget child, {EdgeInsets? padding, bool enableDrag = true, bool autoHeight = false}) async {
    return await _showNsgDialog(context, child, padding, enableDrag, autoHeight);
  }

  Future _showNsgDialog(BuildContext context, Widget child, EdgeInsets? padding, bool enableDrag, bool autoHeight) async {
    try {
      _controller.forward();
    } catch (ex) {
      log(ex.toString());
      ex.printError();
    }
    return await NsgDialog()
        .show(enableDrag: enableDrag, context: context, child: child, animationController: _controller, padding: padding, autoHeight: autoHeight)
        .then((value) {
      try {
        _controller.reverse();
      } catch (ex) {
        log(ex.toString());
        ex.printError();
      }
    });
  }
}
