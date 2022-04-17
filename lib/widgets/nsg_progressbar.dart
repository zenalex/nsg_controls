import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NsgProgressBar extends StatefulWidget {
  const NsgProgressBar({Key? key}) : super(key: key);
  @override
  _NsgProgressBarState createState() => _NsgProgressBarState();
}

class _NsgProgressBarState extends State<NsgProgressBar> with TickerProviderStateMixin {
  // Create a controller
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: false);

  // Create an animation with value of type "double"
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: 2.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _animation,
              child: SvgPicture.asset('assets/images/sv1.svg'),
            ),
            Transform.translate(
              offset: const Offset(.3, 6.5),
              child: SvgPicture.asset('assets/images/sv2.svg'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
