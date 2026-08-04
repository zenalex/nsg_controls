import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_animations/animations.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_data/helpers/double_extension.dart';
import 'package:vector_math/vector_math.dart' as vmath show radians;

class NewNsgProgressWidget extends StatefulWidget {
  const NewNsgProgressWidget({super.key, this.delay = const Duration(seconds: 1), this.controller});
  final Duration delay;
  final NsgProgressWidgetController? controller;

  @override
  State<NewNsgProgressWidget> createState() => _NewNsgProgressWidgetState();
}

class _NewNsgProgressWidgetState extends State<NewNsgProgressWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late NsgProgressWidgetController controller = widget.controller ?? NsgProgressWidgetController();

  var arc1 = 0.0;
  var arc2 = 0.0;
  var arc3 = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 10000));

    _animation = Tween<double>(begin: 0, end: 101).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          arc3 += .5;

          if (arc3 < 180) {
            arc1 += 1;
            arc2 += 2;
          } else if (arc3 < 360) {
            arc1 += 2;
            arc2 += 1;
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpacityAnimation(
      begin: 0,
      end: 1,
      duration: const Duration(milliseconds: 500),
      delay: widget.delay,
      onComplete: (AnimationController value) {},
      idleValue: 0,
      child: Center(
        child: SizedBox(
          width: 210,
          height: 210,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, w) {
              return Stack(
                children: <Widget>[
                  controller.cancelingStarted
                      ? Center(
                          child: CustomPaint(
                            painter: OpenPainter(value: controller.cancelPercent, arc1: arc1, arc2: arc2, percent: !controller.showPercents ? false : true),
                          ),
                        )
                      : Center(
                          child: CustomPaint(
                            painter: OpenPainter(
                              value: controller.cancelMode || !controller.showPercents ? _animation.value : widget.controller!.percent,
                              arc1: arc1,
                              arc2: arc2,
                              percent: controller.cancelMode || !controller.showPercents ? false : true,
                            ),
                          ),
                        ),
                  controller.cancelingStarted
                      ? Center(
                          child: Text(
                            tranControls.cancel,
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: ControlOptions.instance.colorText),
                          ),
                        )
                      : Center(
                          child: Text(
                            controller.cancelMode
                                ? "Canceling..."
                                : !controller.showPercents
                                ? controller.userLabelText ?? ""
                                : '${controller.userLabelText ?? ""} ${widget.controller!.percent}%',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: ControlOptions.instance.colorText),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class NsgProgressWidgetController extends ChangeNotifier {
  NsgProgressWidgetController({this.showPercents = false, this.timeout, this.onCancelMethod}) {
    Future.delayed((timeout ?? Duration.zero), () {
      _canCancel = true;
      notifyListeners();
    });
  }
  final bool showPercents;
  final Duration? timeout;
  Future<void> Function()? onCancelMethod;
  String? _userLabelText;

  String? get userLabelText => _userLabelText;
  set userLabelText(String? val) {
    if (_userLabelText != val) {
      _userLabelText = val;
      notifyListeners();
    }
  }

  final Duration _durationForCancel = Duration(seconds: 3);
  DateTime _cancelStartTimestamp = DateTime.now();

  double _cancelingPercent = 0;
  double get cancelPercent => _cancelingPercent;
  set _cancelPercent(double val) {
    if (_cancelingPercent != val) {
      _cancelingPercent = val;
      notifyListeners();
    }
  }

  bool _cancelMode = false;
  bool get cancelMode => _cancelMode;
  set _cancelingMode(bool val) {
    if (_cancelMode != val) {
      _cancelMode = val;
      notifyListeners();
    }
  }

  Timer? _timer;
  bool _canceling = false;
  bool get cancelingStarted => _canceling;
  set _cancelingStarted(bool val) {
    if (_canceling != val) {
      _canceling = val;
      notifyListeners();
    }
  }

  bool _canCancel = false;
  bool get canCancel => _canCancel;

  double _percent = 0;

  double get percent => _percent;
  set percent(double val) {
    double newValue = val.nsgRoundToDouble(2);
    if (_percent != newValue) {
      _percent = min(newValue, 100);
      notifyListeners();
    }
  }

  Future<void> onCancel({Future<void> Function()? onCancelSucess}) async {
    _cancelingMode = true;
    if (onCancelMethod != null) {
      await onCancelMethod!();
    }
    //test delay
    await Future.delayed(Duration(seconds: 2));
    if (onCancelSucess != null) {
      await onCancelSucess();
    }
  }

  void startCancelLongPress(Future<void> Function() onCancelSucess) {
    _cancelStartTimestamp = DateTime.now();
    _cancelingStarted = true;
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      var timePassed = DateTime.now().difference(_cancelStartTimestamp);
      var timeLeft = _durationForCancel - timePassed;

      _cancelPercent = ((timePassed.inMilliseconds * 100) / _durationForCancel.inMilliseconds).nsgRoundToDouble(2);

      if (timeLeft <= Duration.zero) {
        stopCancelLongPress();
        onCancel(onCancelSucess: onCancelSucess);
        return;
      }
    });
  }

  void stopCancelLongPress() {
    _cancelingStarted = false;
    _timer?.cancel();
    _timer = null;
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
    double val2 = value / 4;
    const rect = Rect.fromLTWH(0.0, 0.0, 200, 200);
    final gradient = LinearGradient(
      begin: const Alignment(-1.0, 0.0),
      end: const Alignment(1.0, 0.0),
      colors: [nsgtheme.colorPrimary, nsgtheme.colorPrimary, nsgtheme.colorPrimary.b70],
      stops: const <double>[0, .5, 1],
      transform: GradientRotation(val2),
    );

    canvas.drawCircle(
      center,
      85,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = ControlOptions.instance.colorSecondary
        ..strokeWidth = 5,
    );
    canvas.saveLayer(Rect.fromCenter(center: center, width: 200, height: 200), Paint());
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 170, height: 170),
      vmath.radians(percent == true ? 0 : arc1),
      vmath.radians(percent == true ? val : arc2 - arc1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect)
        ..strokeWidth = 5,
    );
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 150, height: 150),
      vmath.radians(arc1),
      vmath.radians(arc2 - arc1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = ControlOptions.instance.colorPrimary.withAlpha(120)
        ..strokeWidth = 1,
    );
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 190, height: 190),
      vmath.radians(-arc1),
      vmath.radians(-arc2 + arc1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = ControlOptions.instance.colorPrimary.withAlpha(120)
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
