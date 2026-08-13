import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../nsg_control_options.dart';

enum NsgSnarkBarType {
  info('Информация', Icons.info_outline),
  warning('Предупреждение', Icons.warning_outlined),
  error('Ошибка', Icons.error_outline);

  final String title;
  final IconData icon;

  const NsgSnarkBarType(this.title, this.icon);
}

/// Показать снекбар.
///
/// ## Почему свой OverlayEntry, а не Get.snackbar, Flushbar или ScaffoldMessenger
///
/// Это четвёртая реализация, и у каждой смены была своя причина. Ни одна из
/// них не была вкусовой, поэтому список стоит прочитать целиком, прежде чем
/// «вернуть как было».
///
/// 1. `Get.snackbar` (`SnackbarController` + `GetQueue`) падал с
///    `Null check operator used on a null value`: снекбар из очереди стрелял уже
///    после того, как корневой Overlay/Navigator пересобран
///    (NSG-SOFT/futbolista-tasks#1324, до того #26/#205/#263).
/// 2. `Flushbar` это чинил, но кладёт **pageless-маршрут на корневой Navigator**.
///    Его снятие прилетает по таймеру — в момент, который никто не планировал, —
///    и может угодить в build-фазу. В связке с GetX это давало ре-энтрантную
///    пересборку навигатора внутри его же `pop()`: в debug ассерт
///    `!_debugLocked`, а в release (ассерты сняты, условие осталось) — дубль
///    `OverlayEntry` с одним `GlobalKey`: залипший снекбар, призрачная страница
///    или маршрут, который не закрывается. Разбор: #1449.
/// 3. `ScaffoldMessenger` маршрут не создаёт — уже хорошо. Но рисует снекбар
///    **внутри текущего Scaffold**, а диалог это отдельный маршрут поверх него.
///    То есть сообщение, показанное из диалога, оказывалось ПОД диалогом —
///    ровно там, где его чаще всего и показывают («сохранено», «ошибка связи»).
/// 4. Свой `OverlayEntry` в корневом Overlay: маршрут не создаётся (пункт 2
///    закрыт), а вставка идёт поверх текущих записей Overlay, то есть и поверх
///    открытого диалога (пункт 3 закрыт).
///
/// **Инвариант, который нельзя нарушать: показ снекбара не трогает Navigator.**
/// Ни push, ни pop, ни pageless-маршрутов. Как только он снова начнёт менять
/// стек маршрутов, вернётся #1449. На это есть тест.
///
/// ## Что осталось за рамками
///
/// Корень #1449 (GetX зовёт `notifyListeners()` внутри `pop()`) этим НЕ чинится —
/// убирается реальный путь в build-фазу.
///
/// Диалог, открытый ПОСЛЕ снекбара, ляжет поверх него: Overlay складывает записи
/// по порядку вставки. Случай редкий и самоизлечивается за секунды, поэтому
/// городить постоянный хост над Navigator не стали.
///
/// ## Поведение
///
/// Одновременно виден один снекбар: новый вызов заменяет предыдущий. Очереди
/// сознательно нет — именно очередь (`GetQueue`) и была причиной падений в п.1.
///
/// Тап закрывает снекбар; если задан [onTap], он вызывается после закрытия
/// (обычно по тапу уходят на другой экран, и висящая поверх плашка там не нужна).
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
  final spec = NsgSnackbarSpec(
    text: text,
    title: title,
    type: type,
    onTap: onTap,
    duration: duration ?? const Duration(seconds: 3),
    fontSize: fontSize,
    textAlign: textAlign,
    color: color,
    backColor: backColor,
  );

  void show() {
    final overlay = _resolveOverlay(context);
    if (overlay == null) {
      // Приложение ещё не смонтировано (холодный старт, снекбар из фонового
      // Future) либо Overlay уже разобран. Потерять сообщение лучше, чем уронить
      // экран: прежние реализации падали именно здесь.
      if (kDebugMode) {
        debugPrint('[nsgSnackbar] Overlay недоступен — снекбар пропущен: ${title ?? ''} / $text');
      }
      return;
    }
    NsgSnackbarOverlay.show(overlay, spec);
  }

  // Вставка в Overlay — это setState. Если мы сейчас внутри build/layout, звать
  // её нельзя: получим «setState() or markNeedsBuild() called during build».
  // Снекбары зовут из контроллеров, а те живут в build'е экрана, так что случай
  // не теоретический.
  final phase = SchedulerBinding.instance.schedulerPhase;
  final inBuild = phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks;

  if (!inBuild && _resolveOverlay(context) != null) {
    show();
    return;
  }
  // Overlay ещё не готов либо идёт кадр — ждём следующего и пробуем один раз.
  WidgetsBinding.instance.addPostFrameCallback((_) => show());
}

/// Корневой Overlay: тот же, в котором живут маршруты, включая диалоги.
///
/// Порядок кандидатов — от точного к общему:
/// 1. переданный [context] (`rootOverlay: true` принципиально: вложенные
///    навигаторы заводят свой Overlay, и снекбар из него не вышел бы за пределы
///    вкладки);
/// 2. контексты GetX — быстрый путь в приложениях на Get;
/// 3. обход дерева от корня.
///
/// Третий пункт добавлен сознательно: без него снекбар работает ТОЛЬКО в
/// приложении с GetRoot, а в обычном `MaterialApp` молча ничего не показывает.
/// Для библиотечного кода это скрытая мина, и она же не давала написать тесты.
OverlayState? _resolveOverlay(BuildContext? context) {
  final ctx = _firstMountedContext([
    () => context,
    () => Get.overlayContext,
    () => Get.context,
  ]);
  if (ctx != null) {
    try {
      final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
      if (overlay != null && overlay.mounted) return overlay;
    } catch (_) {
      // Контекст не под Overlay — идём в обход дерева.
    }
  }
  return _findRootOverlay();
}

/// Первый Overlay сверху дерева — то есть Overlay корневого навигатора.
///
/// Именно он держит маршруты, включая диалоги, поэтому вставка в него ложится
/// поверх открытого диалога.
OverlayState? _findRootOverlay() {
  final root = WidgetsBinding.instance.rootElement;
  if (root == null) return null;

  OverlayState? found;
  void visit(Element element) {
    if (found != null) return;
    if (element is StatefulElement && element.state is OverlayState) {
      final state = element.state as OverlayState;
      if (state.mounted) {
        found = state;
        return;
      }
    }
    element.visitChildren(visit);
  }

  try {
    visit(root);
  } catch (e) {
    if (kDebugMode) debugPrint('[nsgSnackbar] обход дерева проглочен: $e');
    return null;
  }
  return found;
}

/// Первый контекст из списка, который ещё в дереве.
///
/// Обращаться к размонтированному BuildContext нельзя. Кандидаты вычисляются
/// лениво и под try: `Get.context` и `Get.overlayContext` не возвращают null, а
/// БРОСАЮТ, если GetRoot ещё (или уже) не в дереве. Тот же приём, что в
/// [NsgProgressDialog].
BuildContext? _firstMountedContext(List<BuildContext? Function()> candidates) {
  for (final candidate in candidates) {
    try {
      final ctx = candidate();
      if (ctx != null && ctx.mounted) return ctx;
    } catch (_) {
      // Нет GetRoot — пробуем следующего кандидата.
    }
  }
  return null;
}

/// Параметры одного снекбара. Отдельно от виджета, чтобы их можно было
/// передавать и проверять в тестах.
@immutable
class NsgSnackbarSpec {
  final String text;
  final String? title;
  final NsgSnarkBarType? type;
  final VoidCallback? onTap;
  final Duration duration;
  final double? fontSize;
  final TextAlign? textAlign;
  final Color? color;
  final Color? backColor;

  const NsgSnackbarSpec({
    required this.text,
    required this.duration,
    this.title,
    this.type,
    this.onTap,
    this.fontSize,
    this.textAlign,
    this.color,
    this.backColor,
  });
}

/// Вставка снекбара в Overlay и снятие его оттуда.
///
/// Вынесено в класс ради единственного статического поля [_current]: снекбар
/// показывается по одному, и новый обязан снять предыдущий. Без этого быстрая
/// череда сообщений оставила бы висеть стопку записей Overlay.
class NsgSnackbarOverlay {
  NsgSnackbarOverlay._();

  static OverlayEntry? _current;

  /// Сколько снекбаров сейчас в Overlay. Для тестов.
  @visibleForTesting
  static int get activeCount => _current == null ? 0 : 1;

  static void show(OverlayState overlay, NsgSnackbarSpec spec) {
    _removeCurrent();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NsgSnackbarView(
        spec: spec,
        onClosed: () => _remove(entry),
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void _removeCurrent() {
    final entry = _current;
    if (entry != null) _remove(entry);
  }

  /// Снятие записи. Идемпотентно и под try: запись могли уже снять (свой таймер,
  /// тап, следующий снекбар), а Overlay — разобрать вместе с приложением.
  static void _remove(OverlayEntry entry) {
    if (identical(_current, entry)) _current = null;
    try {
      if (entry.mounted) entry.remove();
    } catch (e) {
      if (kDebugMode) debugPrint('[nsgSnackbar] снятие записи проглочено: $e');
    }
  }

  /// Убрать снекбар, если он показан. Нужно тестам и редким случаям, когда
  /// сообщение стало неактуальным раньше своего таймера.
  static void dismiss() => _removeCurrent();
}

class _NsgSnackbarView extends StatefulWidget {
  final NsgSnackbarSpec spec;
  final VoidCallback onClosed;

  const _NsgSnackbarView({required this.spec, required this.onClosed});

  @override
  State<_NsgSnackbarView> createState() => _NsgSnackbarViewState();
}

class _NsgSnackbarViewState extends State<_NsgSnackbarView> with SingleTickerProviderStateMixin {
  static const _animation = Duration(milliseconds: 200);

  late final AnimationController _controller;
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animation)..forward();
    _timer = Timer(widget.spec.duration, _close);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close({VoidCallback? then}) async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();

    // Обратная анимация — только если виджет ещё в дереве. Overlay могли
    // разобрать вместе с приложением, и reverse() упал бы на dispose'нутом
    // контроллере.
    if (mounted) {
      try {
        await _controller.reverse();
      } catch (_) {
        // Контроллер уже утилизирован — снимать запись всё равно надо.
      }
    }
    widget.onClosed();
    then?.call();
  }

  void _handleTap() {
    final onTap = widget.spec.onTap;
    _close(then: onTap);
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final textColor = spec.color ?? ControlOptions.instance.colorMainText;
    final size = spec.fontSize ?? ControlOptions.instance.sizeL;
    final align = spec.textAlign ?? TextAlign.center;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (spec.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              spec.title!,
              textAlign: align,
              style: TextStyle(fontSize: size, color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        Text(spec.text, textAlign: align, style: TextStyle(color: textColor, fontSize: size)),
      ],
    );

    if (spec.type != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(spec.type!.icon, color: textColor),
          ),
          Expanded(child: content),
        ],
      );
    }

    final media = MediaQuery.maybeOf(context);
    final screenWidth = media?.size.width;
    // Ограничение ширины 640 — как было у Flushbar: иначе на десктопе плашка
    // растягивается во всю ширину окна. На узких экранах ограничение не нужно,
    // там работают боковые отступы.
    final barWidth = (screenWidth != null && screenWidth > 672) ? 640.0 : null;

    // Поднимаемся над клавиатурой и над системной панелью: снекбар, спрятанный
    // за клавиатурой, для пользователя равнозначен непоказанному.
    final insets = media?.viewInsets.bottom ?? 0;
    final safeBottom = media?.padding.bottom ?? 0;
    final bottom = (insets > safeBottom ? insets : safeBottom) + 16;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: FadeTransition(
          opacity: _controller,
          child: Align(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: barWidth ?? double.infinity),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  type: MaterialType.transparency,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: spec.backColor ?? ControlOptions.instance.colorMain,
                        borderRadius: BorderRadius.circular(ControlOptions.instance.borderRadius),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
