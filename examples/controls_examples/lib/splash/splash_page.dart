// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import '../model/data_controller.dart';

// const List<String> _images = <String>[
//   'lib/assets/images/sv1.svg',
//   'lib/assets/images/sv2.svg',
//   'lib/assets/images/sv3.svg',
//   'lib/assets/images/sv4.svg',
//   'lib/assets/images/logo.svg'
// ];

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>

      ///
      _fadein,
      _translate,
      _opacity,
      _scale,
      _scale2,
      _scale3,
      _scale4,
      _translate3,
      _opacity5,
      _fadein1,
      _fadein2,
      _fadein3,
      _fadein4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _fadein = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _translate = Tween(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.5, curve: Curves.easeInOut),
      ),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 95),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 5)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0))));

    _scale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.2, curve: Curves.easeInOut),
      ),
    );

    _scale2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _scale3 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 20),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: -1.0, end: 1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20),
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5))));

    _translate3 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: -1.0, end: 0.0).chain(CurveTween(curve: Curves.bounceInOut)),
          weight: 10)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))));

    _scale4 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.linear)),
          weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)),
          weight: 10)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))));

    _opacity5 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: Curves.easeInOut),
      ),
    );

    _fadein1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.35, curve: Curves.easeInOut),
      ),
    );

    _fadein2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.4, curve: Curves.easeInOut),
      ),
    );

    _fadein3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.45, curve: Curves.easeInOut),
      ),
    );

    _fadein4 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.3, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        var controller = Get.find<DataController>();
        controller.splashAnimationFinished();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DataController>();
    double size;
    double getHeight = Get.height;
    double getWidth = Get.width;
    if (getWidth < getHeight) {
      size = getWidth - 60;
    } else {
      size = getHeight - 60;
    }
    if (size > 500) {
      size = 500;
    }

    BoxDecoration decorGreenGradient = const BoxDecoration(
        gradient: LinearGradient(
      stops: [0.0, 1.0],
      colors: [Color.fromRGBO(129, 198, 56, 1), Color.fromRGBO(129, 198, 56, 0)],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
    ));
    BoxDecoration decorGreen = BoxDecoration(color: const Color.fromRGBO(129, 198, 56, 0.3), borderRadius: BorderRadius.circular(3000));
    BoxDecoration decorYellow = BoxDecoration(color: const Color.fromRGBO(254, 194, 8, 1), borderRadius: BorderRadius.circular(3000));
    BoxDecoration decorDarkGradient = BoxDecoration(
        gradient: const LinearGradient(
          stops: [0.0, 0.7],
          colors: [Color.fromRGBO(0, 0, 0, 0.5), Color.fromRGBO(129, 198, 56, 0)],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(3000));
    TextStyle textstyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadein,
        builder: (ctx, ch) => Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(254, 194, 8, 1)),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _opacity,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Transform.translate(
                        offset: const Offset(0, 0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              alignment: Alignment.center,
                              scale: _scale4.value,
                              child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: decorDarkGradient,
                                  child: Container(width: size, height: size, decoration: decorYellow)),
                            ),
                            Transform.scale(scaleX: _scale3.value, child: Container(width: size / 1.4, height: size / 1.4, decoration: decorGreen)),
                            Transform.scale(
                                alignment: Alignment.topCenter,
                                scaleY: _scale2.value,
                                child: Container(width: 230, height: Get.height, decoration: decorGreenGradient)),
                            Transform.scale(
                              scale: _opacity5.value,
                              child: Opacity(
                                opacity: _opacity5.value,
                                child: Image.asset(
                                  'lib/assets/images/logo.png',
                                  width: 215,
                                  height: 144,
                                ),
                              ),
                            ),
                            Opacity(
                                opacity: _fadein1.value,
                                child: Transform.translate(
                                    offset: Offset((230 - size) / 2, Get.height / 2 - 110 - _fadein4.value * 20),
                                    child: Container(width: size, height: 10, decoration: const BoxDecoration(color: Color.fromRGBO(129, 198, 56, 1))))),
                            Opacity(
                                opacity: _fadein1.value,
                                child: Transform.translate(
                                    offset: Offset((230 / 2 + size / 3 / 2), Get.height / 2 - 100 - _fadein4.value * 20),
                                    child: Container(width: size / 3, height: 10, decoration: const BoxDecoration(color: Color.fromRGBO(154, 197, 48, 1))))),
                            Opacity(
                                opacity: _fadein1.value,
                                child: Transform.translate(
                                    offset: Offset(0, Get.height / 2 - 75 - _fadein1.value * 20),
                                    child: SizedBox(
                                      width: size / 1.5,
                                      height: size / 20,
                                      child: FittedBox(
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                        child: Text(
                                          "Рабочие среды",
                                          style: textstyle,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ))),
                            Opacity(
                                opacity: _fadein2.value,
                                child: Transform.translate(
                                    offset: Offset(0, Get.height / 2 - 50 - _fadein2.value * 20),
                                    child: SizedBox(
                                      width: size / 1.5,
                                      height: size / 20,
                                      child: FittedBox(
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                        child: Text("Автоматизация", style: textstyle, textAlign: TextAlign.left),
                                      ),
                                    ))),
                            Opacity(
                                opacity: _fadein3.value,
                                child: Transform.translate(
                                    offset: Offset(0, Get.height / 2 - 25 - _fadein3.value * 20),
                                    child: SizedBox(
                                        width: size / 1.5,
                                        height: size / 20,
                                        child: FittedBox(
                                            alignment: Alignment.center,
                                            fit: BoxFit.contain,
                                            child: Text("Мобильные решения", style: textstyle, textAlign: TextAlign.left)))))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              controller.obx(
                (state) => const SizedBox(),
                onLoading: FadeIn(
                  duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
                  curve: Curves.easeIn,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      'Подключение к серверу...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onError: (s) => FadeIn(
                  duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
                  curve: Curves.easeIn,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: ControlOptions.instance.colorError),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            'Проверьте интернет соединение',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
