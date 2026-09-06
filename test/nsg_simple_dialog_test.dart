// Цвет текста в контенте showNsgSimpleDialog (NSG-SOFT/futbolista-tasks#1942).
//
// Диалог задавал цвет ТОЛЬКО ветке `text:`, а `child:` отдавал вызывающей
// стороне без всякого `DefaultTextStyle`. Голый `Text` внутри `SimpleDialog`
// донаследует `textTheme.titleMedium` — слот, который приложения обычно не
// переопределяют (в footballers_diary_app заданы восемь соседних, а он нет), —
// и получал материаловский `Colors.black87` на тёмном фоне модалки.
//
// В приложении так «потерялись» шесть диалогов сразу; организатор описал это
// как «тёмный текст на тёмном фоне, и такой цвет на многих уведомлениях».
//
// Контраст здесь считается формулой WCAG 2.x, а цвет читается из отрисованного
// дерева — на глаз такое не проверяется.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dialog/show_nsg_simple_dialog.dart';
import 'package:nsg_controls/nsg_control_options.dart';

void main() {
  /// Относительная яркость по WCAG 2.x.
  double relativeLuminance(Color c) {
    double channel(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }

  double contrastRatio(Color a, Color b) {
    final la = relativeLuminance(a);
    final lb = relativeLuminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Норма AA для обычного текста.
  const double aa = 4.5;

  setUpAll(() {
    // Тёмная тема — как у приложения-потребителя: фон модалки #302D38,
    // текст белый. На умолчаниях библиотеки (они светлые) тест мерил бы не то.
    ControlOptions.instance = ControlOptions(
      colorModalBack: const Color(0xFF302D38),
      colorMainBack: const Color(0xFF1C1B1F),
      colorBase: const Color(0xFF1C1B1F),
      colorText: const Color(0xFFFFFFFF),
    );
  });

  /// Тема, в которой `titleMedium` НЕ задан, — то есть ровно та ситуация, из
  /// которой вырос дефект. Соседние слоты заданы белым, как в приложении.
  ThemeData themeWithoutTitleMedium() => ThemeData(
    useMaterial3: false,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
    ),
  );

  Future<void> open(WidgetTester tester, {String? text, Widget? child}) async {
    late BuildContext ctx;
    // `GetMaterialApp`, а не `MaterialApp`: диалог первой же строкой читает
    // `tranControls`, а тот идёт за `Get.context`.
    await tester.pumpWidget(
      GetMaterialApp(
        theme: themeWithoutTitleMedium(),
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // `home` у GetMaterialApp строится не на первом кадре.
    await tester.pumpAndSettle();

    showNsgSimpleDialog(context: ctx, text: text, child: child);
    await tester.pumpAndSettle();
  }

  Color renderedColor(WidgetTester tester, String data) {
    final rich = tester.widget<RichText>(find.descendant(of: find.text(data), matching: find.byType(RichText)));
    return (rich.text as TextSpan).style!.color!;
  }

  group('showNsgSimpleDialog красит контент обеих веток', () {
    testWidgets('child: получает colorText — это и есть #1942', (tester) async {
      await open(tester, child: const Text('приглашение'));

      final color = renderedColor(tester, 'приглашение');
      expect(color, nsgtheme.colorText);
      expect(
        contrastRatio(color, nsgtheme.colorModalBack),
        greaterThanOrEqualTo(aa),
        reason: 'до правки здесь был Colors.black87 — 1.50 : 1',
      );
    });

    testWidgets('text: остался как был — цвет не потерялся', (tester) async {
      await open(tester, text: 'вы уверены?');

      expect(renderedColor(tester, 'вы уверены?'), nsgtheme.colorText);
    });

    testWidgets('красит всё поддерево, а не только верхний Text', (tester) async {
      await open(
        tester,
        child: const Column(
          children: [Text('заголовок'), Padding(padding: EdgeInsets.all(4), child: Text('абзац'))],
        ),
      );

      for (final data in ['заголовок', 'абзац']) {
        expect(renderedColor(tester, data), nsgtheme.colorText, reason: data);
      }
    });

    testWidgets('SelectableText тоже наследует', (tester) async {
      await open(tester, child: const SelectableText('Иванов\nПетров'));

      expect(tester.widget<EditableText>(find.byType(EditableText)).style.color, nsgtheme.colorText);
    });

    testWidgets('свой явный цвет не перебивается', (tester) async {
      // Текст на цветной подложке задаёт цвет осознанно — merge его не трогает.
      await open(tester, child: const Text('ссылка', style: TextStyle(color: Colors.black)));

      expect(renderedColor(tester, 'ссылка'), Colors.black);
    });

    testWidgets('размер и гарнитуру из темы не ломает', (tester) async {
      // Тему читаем ИЗ дерева, а не из свежесобранной ThemeData: геометрию
      // текста (в т.ч. fontSize) навешивает `ThemeData.localize` уже внутри
      // MaterialApp, и снаружи titleMedium.fontSize ещё null.
      TextStyle? inherited;
      await open(
        tester,
        child: Builder(
          builder: (c) {
            inherited = Theme.of(c).textTheme.titleMedium;
            return const Text('абзац');
          },
        ),
      );

      final rich = tester.widget<RichText>(find.descendant(of: find.text('абзац'), matching: find.byType(RichText)));
      final style = (rich.text as TextSpan).style!;
      // Задан только цвет: остальное осталось от titleMedium текущей темы.
      expect(style.fontSize, inherited!.fontSize);
      expect(style.fontFamily, inherited!.fontFamily);
      expect(style.fontWeight, inherited!.fontWeight);
      expect(style.color, isNot(inherited!.color), reason: 'цвет — единственное, что меняем');
    });
  });
}
