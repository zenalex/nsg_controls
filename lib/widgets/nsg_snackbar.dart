import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../nsg_control_options.dart';

enum NsgSnarkBarType {
  info('Информация', Icons.info_outline),
  warning('Предупреждение', Icons.warning_outlined),
  error('Ошибка', Icons.error_outline);

  final String title;
  final IconData icon;

  const NsgSnarkBarType(this.title, this.icon);
}

/// Ключ мессенджера, через который показываются снекбары без BuildContext.
///
/// Приложение ОБЯЗАНО передать его в свой `MaterialApp`/`GetMaterialApp`:
/// ```dart
/// GetMaterialApp(scaffoldMessengerKey: nsgScaffoldMessengerKey, ...)
/// ```
/// Без этого `nsgSnackbar` будет работать только там, где передан `context`,
/// а вызовы из контроллеров и фоновых Future молча ничего не покажут.
final GlobalKey<ScaffoldMessengerState> nsgScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Показать снекбар.
///
/// ## Почему ScaffoldMessenger, а не Flushbar и не Get.snackbar
///
/// Это третья реализация, и у каждой смены была своя причина.
///
/// 1. `Get.snackbar` (`SnackbarController` + `GetQueue`) падал с
///    `Null check operator used on a null value`: снекбар из очереди стрелял уже
///    после того, как root Overlay/Navigator пересобран
///    (NSG-SOFT/futbolista-tasks#1324, до того #26/#205/#263).
/// 2. Flushbar это чинил, но кладёт **pageless-маршрут на корневой Navigator**.
///    Его снятие прилетает по таймеру — в момент, который никто не планировал, — и
///    может угодить в build-фазу. В связке с GetX это давало ре-энтрантную
///    пересборку навигатора внутри его же `pop()`: в debug ассерт
///    `!_debugLocked`, а в release (ассерты сняты, условие осталось) — дубль
///    `OverlayEntry` с одним `GlobalKey`, то есть залипший снекбар, призрачная
///    страница или маршрут, который не закрывается. Разбор:
///    NSG-SOFT/futbolista-tasks#1449.
/// 3. `ScaffoldMessenger` маршрут не создаёт вообще — снекбар рисует сам
///    Scaffold. Навигатор не мутируется, значит описанного пути просто нет.
///
/// Корень (GetX зовёт `notifyListeners()` внутри `pop()`) этим НЕ чинится —
/// убирается реальный путь в build-фазу. См. #1449.
void nsgSnackbar({
  VoidCallback? onTap,
  String? title,
  BuildContext? context,
  required String text,
  NsgSnarkBarType? type,
  Duration? duration,
  double? fontSize,
  TextAlign? textAlign,
  Color? color,
  Color? backColor,
}) {
  final textColor = color ?? ControlOptions.instance.colorMainText;
  final size = fontSize ?? ControlOptions.instance.sizeL;
  final align = textAlign ?? TextAlign.center;

  SnackBar buildBar(ScaffoldMessengerState messenger) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              title,
              textAlign: align,
              style: TextStyle(fontSize: size, color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        Text(text, textAlign: align, style: TextStyle(color: textColor, fontSize: size)),
      ],
    );

    if (type != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(type.icon, color: textColor),
          ),
          Expanded(child: content),
        ],
      );
    }

    if (onTap != null) {
      // У материального снекбара нет onTap на всю плашку — вешаем сами.
      // Скрываем перед колбэком: обычно по тапу уходят на другой экран, и
      // висящая поверх плашка там уже не нужна.
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          messenger.hideCurrentSnackBar();
          onTap();
        },
        child: content,
      );
    }

    return SnackBar(
      content: Center(
        child: ConstrainedBox(
          // maxWidth: 640 — как было у Flushbar, иначе на десктопе плашка
          // растягивается во всю ширину окна.
          constraints: const BoxConstraints(maxWidth: 640),
          child: content,
        ),
      ),
      backgroundColor: backColor ?? ControlOptions.instance.colorMain,
      duration: duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ControlOptions.instance.borderRadius)),
      elevation: 6,
    );
  }

  ScaffoldMessengerState? resolveMessenger() {
    final byKey = nsgScaffoldMessengerKey.currentState;
    if (byKey != null) return byKey;
    if (context != null && context.mounted) return ScaffoldMessenger.maybeOf(context);
    return null;
  }

  void show() {
    final messenger = resolveMessenger();
    if (messenger == null) {
      // Приложение ещё не смонтировано (холодный старт, снекбар из фонового
      // Future) либо ключ не проброшен в MaterialApp. Потерять снекбар лучше,
      // чем уронить экран — прежние реализации падали именно здесь.
      if (kDebugMode) {
        debugPrint('[nsgSnackbar] ScaffoldMessenger недоступен — снекбар пропущен: ${title ?? ''} / $text');
      }
      return;
    }
    try {
      messenger.showSnackBar(buildBar(messenger));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[nsgSnackbar] проглочено: $e');
      }
    }
  }

  if (resolveMessenger() != null) {
    show();
    return;
  }
  // Мессенджера ещё нет — ждём следующего кадра и пробуем один раз.
  WidgetsBinding.instance.addPostFrameCallback((_) => show());
}
