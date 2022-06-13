import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;

import '../nsg_control_options.dart';

class NsgProgressBar extends StatefulWidget {
  final double? percent;
  NsgProgressBar({this.percent}) : super();

  @override
  _NsgProgressBarState createState() => _NsgProgressBarState();
}

class _NsgProgressBarState extends State<NsgProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  var arc1 = 0.0;
  var arc2 = 0.0;
  var arc3 = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 10000,
      ),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 101,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          arc3 += 1;

          if (arc3 < 180) {
            arc1 += 2;
            arc2 += 4;
          } else if (arc3 < 360) {
            arc1 += 4;
            arc2 += 2;
          } else {
            arc3 = 0;
          }
          if (arc1 > 360) {
            arc1 -= 360;
            arc2 -= 360;
          }
          if (arc2 > 360) {
            arc1 -= 360;
            arc2 -= 360;
          }
        });
      });

    _controller.repeat();
    //_controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 210,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              child: CustomPaint(
                key: GlobalKey(),
                painter: OpenPainter(
                    value: widget.percent == null ? _animation.value : widget.percent!.toDouble(),
                    arc1: arc1,
                    arc2: arc2,
                    percent: widget.percent == null ? false : true),
              ),
            ),
          ),
          Center(
            child: Text(
              widget.percent == null ? 'Загрузка' : 'Загрузка ${widget.percent}%',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpenPainter extends CustomPainter {
  final double value;
  double arc1, arc2;
  bool percent;
  OpenPainter({required this.value, required this.arc1, required this.arc2, this.percent = false}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double val = value * 3.6;
    double val2 = value / 8;
    const rect = Rect.fromLTWH(0.0, 0.0, 200, 200);
    /*final gradient = new RadialGradient(
      radius: 1,
      tileMode: TileMode.mirror,
      colors: [colorMain, colorBack1],
      stops: <double>[value / 300, value / 100],
    );*/
    final gradient = LinearGradient(
      begin: const Alignment(-1.0, 0.0),
      end: const Alignment(1.0, 0.0),
      colors: [ControlOptions.instance.colorMain, ControlOptions.instance.colorMainDark],
      stops: <double>[0, 1],
      transform: GradientRotation(val2),
    );
    final gradient2 = RadialGradient(
      radius: 2,
      tileMode: TileMode.mirror,
      colors: [
        ControlOptions.instance.colorMainDark.withOpacity(.5),
        ControlOptions.instance.colorMain.withOpacity(.5)
      ],
      stops: <double>[value / 300, value / 100],
    );

    canvas.drawCircle(
      center,
      85,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = ControlOptions.instance.colorMain.withOpacity(0.1)
        ..strokeWidth = 5,
    );
    canvas.saveLayer(
      Rect.fromCenter(center: center, width: 200, height: 200),
      // Paint()..blendMode = BlendMode.dstIn,
      Paint(),
    );
    canvas.drawArc(
        Rect.fromCenter(center: center, width: 170, height: 170),
        vmath.radians(percent == true ? 0 : arc1),
        vmath.radians(percent == true ? val : arc2 - arc2),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..shader = gradient2.createShader(rect)
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0));
    canvas.drawArc(
        Rect.fromCenter(center: center, width: 170, height: 170),
        vmath.radians(percent == true ? 0 : arc1),
        vmath.radians(percent == true ? val : arc2 - arc1),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..shader = gradient.createShader(rect)
          ..strokeWidth = 5);
    canvas.drawArc(
        Rect.fromCenter(center: center, width: 150, height: 150),
        vmath.radians(arc1),
        vmath.radians(arc2 - arc1),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = ControlOptions.instance.colorMain.withOpacity(.3)
          ..strokeWidth = 1);
    canvas.drawArc(
        Rect.fromCenter(center: center, width: 190, height: 190),
        vmath.radians(-arc1),
        vmath.radians(-arc2 + arc1),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = ControlOptions.instance.colorMain.withOpacity(.3)
          ..strokeWidth = 1);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
