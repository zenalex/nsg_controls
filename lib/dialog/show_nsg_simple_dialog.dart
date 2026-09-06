// импорт

import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';

import '../helpers.dart';

/// Простой модальный диалог с одной кнопкой «ОК».
///
/// Контент задаётся ОДНИМ из двух способов: [text] — готовая строка, [child] —
/// произвольный виджет. Цвет текста у обоих одинаковый — `nsgtheme.colorText`,
/// под фон `nsgtheme.colorModalBack`.
///
/// ⚠️ Если переопределяете [backgroundColor], цвет текста за вами не пойдёт:
/// он остаётся `colorText`. На светлой подложке задавайте стиль в [child] сами.
Future showNsgSimpleDialog({
  required BuildContext context,
  // bool showCancelButton = true,
  // String title = 'Необходимо подтверждение',
  String? text,
  Color? barrierColor,
  Color? backgroundColor,
  // String textConfirm = 'ОК',
  // String textCancel = 'Отмена',
  Widget? child,
  // List<Widget>? buttons,
  VoidCallback? onConfirm,
  // VoidCallback? onCancel
}) async {
  text ??= tranControls.are_you_sure;
  await showDialog(
    barrierColor: barrierColor ?? nsgtheme.colorMainBack.withAlpha(230),
    context: context,
    builder: (context) {
      return SimpleDialog(
        insetPadding: const EdgeInsets.all(10),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(20),
        backgroundColor: backgroundColor ?? nsgtheme.colorModalBack,
        children: [
          Center(
            // Цвет контента задаётся ОДИН раз и одинаково для обеих веток.
            //
            // Раньше он стоял только на ветке `text:`, а `child:` уходил без
            // всякого `DefaultTextStyle` и донаследовал то, что `SimpleDialog`
            // кладёт детям, — `textTheme.titleMedium`. Этот слот приложения
            // обычно не переопределяют (в footballers_diary_app заданы восемь
            // соседних, а он — нет), поэтому оставался материаловский
            // `Colors.black87`, и на тёмном фоне модалки текст был почти
            // нечитаем: 1.50 : 1 при норме WCAG AA 4.5 : 1
            // (NSG-SOFT/futbolista-tasks#1942).
            //
            // Именно `merge`, а не `DefaultTextStyle`: виджеты со своим стилем
            // (`NsgInput`, `NsgButton`, текст на цветной подложке) перекрывают
            // цвет сами, а размер и гарнитура наследуются от темы приложения.
            child: DefaultTextStyle.merge(
              style: TextStyle(color: nsgtheme.colorText),
              child: child ?? Text(text!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NsgButton(
                  width: 100,
                  text: tranControls.ok.toUpperCase(),
                  onTap: () {
                    if (onConfirm != null) {
                      onConfirm();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
