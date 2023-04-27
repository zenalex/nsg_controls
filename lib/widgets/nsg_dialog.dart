import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NsgDialogBodyController {
  NsgDialogBodyState currentState = NsgDialogBodyState();
  //AnimationController transitionAnimationController = AnimationController(vsync: vsync);
  Future openDialog(Widget child) async {
    return await currentState.openDialog(child);
  }

  BuildContext getContext() {
    BuildContext context = currentState.context;
    return context;
  }
}

class NsgDialog {
  Future<void> show({required BuildContext context, required Widget child, AnimationController? animationController}) {
    return showModalBottomSheet<void>(
      transitionAnimationController: animationController,
      context: context,
      constraints: BoxConstraints(maxHeight: Get.height - Get.statusBarHeight * 2 / 3),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return child;
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
  static late AnimationController _controller;
  late Animation<double> _padding;
  bool dialogOpen = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      child: Transform.scale(
        scale: dialogOpen ? 0.9 : 1,
        child: ClipRRect(borderRadius: dialogOpen ? BorderRadius.circular(20) : BorderRadius.circular(0), child: widget.child),
      ),
    );
    // return AnimatedBuilder(
    //     animation: _padding,
    //     builder: (ctx, ch) => Padding(
    //           padding: EdgeInsets.all(_padding.value),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(_padding.value),
    //             child: widget.child,
    //           ),
    //         ));
  }

  Future openDialog(Widget child) async {
    return await _showNsgDialog(context, child);
  }

  Future _showNsgDialog(BuildContext context, Widget child) async {
    // _controller.forward();
    setState(() {
      dialogOpen = true;
    });
    return await NsgDialog().show(context: context, child: child, animationController: _controller).then((value) {
      value;
      setState(() {
        dialogOpen = false;
      });
      // _controller.reverse();
    });
  }
}
