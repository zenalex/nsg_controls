// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgProgressDialog {
  double percent;
  bool showPercents;
  bool? canStopped;
  Function? requestStop;
  String textDialog;
  NsgProgressDialogWidget? dialogWidget;
  BuildContext? context;
  int? delay;

  ///Если пользователь нажмет отменить, будет передан запрос на отмену сетевого соединения
  NsgCancelToken? cancelToken;
  bool visible = false;

  /// Контекст самого диалога (из builder). Закрываем окно именно по нему:
  /// он живёт внутри маршрута диалога, в отличие от внешнего context /
  /// Get.context, который к моменту hide() может оказаться размонтированным.
  BuildContext? _dialogContext;

  /// hide() позвали раньше, чем диалог успел построиться.
  bool _hideRequested = false;

  NsgProgressDialog({
    this.delay,
    this.showPercents = false,
    this.percent = 0,
    this.canStopped = false,
    this.requestStop,
    this.textDialog = '',
    this.cancelToken,
    this.context,
  });

  void show({String text = ''}) {
    if (visible) return;
    // открываем popup с прогрессбаром NsgProgressBar
    //print("SHOW");
    // Живой контекст обязателен: showDialog по размонтированному элементу
    // упадёт, и вызывающий код прервётся на середине. Лучше не показать
    // прогресс, чем уронить операцию.
    final ctx = _firstMountedContext([() => context, () => Get.context, () => Get.overlayContext]);
    if (ctx == null) {
      debugPrint('NsgProgressDialog.show: нет живого контекста — прогресс не показан');
      return;
    }
    context = ctx;
    visible = true;
    _hideRequested = false;
    _dialogContext = null;

    try {
      showDialog(
        context: ctx,
        builder: (dialogContext) {
          _dialogContext = dialogContext;
          // Гонка: hide() успел отработать до первого build диалога (быстрая
          // операция). Без этого маршрут диалога останется на экране навсегда.
          if (_hideRequested) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _closeDialog());
          }
          return NsgProgressDialogWidget(
            delay: delay,
            canStopped: canStopped,
            cancelToken: cancelToken,
            dialogWidget: showPercents ? this : null,
            requestStop: requestStop,
            text: text,
            textDialog: textDialog,
            visible: visible,
          );
        },
      );
    } catch (e) {
      // Индикатор прогресса — вспомогательный: если показать его не вышло,
      // операция всё равно должна выполниться.
      visible = false;
      debugPrint('NsgProgressDialog.show: не удалось показать прогресс: $e');
    }

    // showDialog(
    //     //ANCHOR -  context: context!,
    //     NsgProgressDialogWidget(
    //         delay: delay,
    //         canStopped: canStopped,
    //         cancelToken: cancelToken,
    //         dialogWidget: showPercents ? this : null,
    //         requestStop: requestStop,
    //         text: text,
    //         textDialog: textDialog,
    //         visible: visible));
    // Get.dialog(
    //     dialogWidget = NsgProgressDialogWidget(
    //         canStopped: canStopped,
    //         cancelToken: cancelToken,
    //         dialogWidget: showPercents ? this : null,
    //         requestStop: requestStop,
    //         text: text,
    //         textDialog: textDialog,
    //         visible: visible),
    //     barrierColor: Colors.transparent,
    //     barrierDismissible: false);
  }

  void hide() {
    if (!visible) return;
    visible = false;
    _hideRequested = true;
    dialogWidget?.isClosed = true;
    _closeDialog();
  }

  /// Закрытие окна прогресса. Никогда не бросает исключение: если оно
  /// вылетит отсюда, модальный барьер с крутилкой останется на экране и
  /// приложение будет выглядеть зависшим — пользователю останется только
  /// перезапуск (titan-112, GlitchTip #3634: старый код звал
  /// `Navigator.of(context ?? Get.context!)` по уже размонтированному
  /// элементу и падал null-check'ом прямо в hide()).
  void _closeDialog() {
    final dc = _dialogContext;
    // Диалог ещё не построился — закроем его в builder по _hideRequested.
    // Вслепую звать Navigator.pop() тут нельзя: маршрута диалога на стеке
    // ещё нет, и мы сняли бы текущую страницу пользователя.
    if (dc == null) return;
    // Контекст мёртв — значит поддерева диалога в дереве уже нет, закрывать
    // нечего.
    if (!dc.mounted) {
      _dialogContext = null;
      return;
    }

    try {
      final route = ModalRoute.of(dc);
      final navigator = Navigator.maybeOf(dc);
      if (navigator == null || route == null || !route.isActive) return;
      // Если сверху успел лечь другой маршрут — снимаем именно свой, чтобы
      // не закрыть чужое окно.
      route.isCurrent ? navigator.pop() : navigator.removeRoute(route);
    } catch (e, st) {
      debugPrint('NsgProgressDialog.hide: не удалось закрыть окно прогресса: $e\n$st');
    } finally {
      _dialogContext = null;
    }
  }

  /// Первый контекст из списка, который ещё в дереве. Обращаться к
  /// размонтированному BuildContext нельзя: Navigator.of/maybeOf упадёт на
  /// `StatefulElement.state` (там `_state!`).
  ///
  /// Кандидаты вычисляются лениво и под try: `Get.context` и
  /// `Get.overlayContext` не возвращают null, а бросают исключение, если
  /// GetRoot ещё (или уже) не в дереве.
  static BuildContext? _firstMountedContext(List<BuildContext? Function()> candidates) {
    for (final candidate in candidates) {
      try {
        final ctx = candidate();
        if (ctx != null && ctx.mounted) return ctx;
      } catch (_) {
        // Нет GetRoot — просто пробуем следующего кандидата.
      }
    }
    return null;
  }

  // При нажатии на кнопку отмены вызываем requestStop - убираем кнопку отмены, пишем "обработка отмены"
}

// ignore: must_be_immutable
class NsgProgressDialogWidget extends StatefulWidget {
  final String? text;
  NsgProgressDialog? dialogWidget;
  final bool? canStopped;
  final Function? requestStop;
  final String textDialog;
  final NsgCancelToken? cancelToken;
  final bool visible;
  bool isClosed = false;

  /// Задержка в миллисекундах до появления прогрессбара
  final int? delay;
  NsgProgressDialogWidget({
    super.key,
    required this.text,
    required this.dialogWidget,
    required this.canStopped,
    required this.requestStop,
    required this.textDialog,
    required this.cancelToken,
    required this.visible,
    this.delay = 500,
  });

  @override
  State<NsgProgressDialogWidget> createState() => _NsgProgressDialogWidgetState();
}

class _NsgProgressDialogWidgetState extends State<NsgProgressDialogWidget> {
  bool destroyed = false;
  bool loadingTooLong = true;

  @override
  void dispose() {
    destroyed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration(milliseconds: widget.delay), () {
    //   if (!destroyed && !widget.isClosed) {
    //     setState(() {
    //       loadingTooLong = true;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return !loadingTooLong
        ? const SizedBox()
        : nsgBackDrop(
            child: GestureDetector(
              onLongPress: () {
                NsgNavigator.pop();
              },
              child: Container(
                decoration: BoxDecoration(color: ControlOptions.instance.colorMainBack.withAlpha(200)),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.textDialog.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              widget.textDialog,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ControlOptions.instance.colorText),
                            ),
                          ),
                        NsgProgressBar(text: widget.text!, dialogWidget: widget.dialogWidget),
                        if (widget.canStopped == true)
                          NsgButton(
                            text: 'Отмена',
                            onPressed: () {
                              if (widget.requestStop != null) {
                                widget.requestStop!();
                              }
                              widget.cancelToken?.calcel();
                              Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
