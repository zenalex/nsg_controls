import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:intl/date_symbol_data_local.dart';

class _Record extends NsgDataItem {
  @override
  String get typeName => 'ClearIconThemeRecord';
  @override
  void initialize() {
    addField(NsgDataStringField('id'), primaryKey: true);
    addField(NsgDataStringField('name'));
    addField(NsgDataDateField('date'));
  }

  @override
  NsgDataItem getNewObject() => _Record();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    NsgDataClient.client.registerDataItem(_Record());
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = Platform.environment['AK1_CLEAR_FONT'];
    if (font != null) {
      final bytes = await File(font).readAsBytes();
      await (FontLoader(
        'Inter',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
  });
  Future<(_Record, ValueNotifier<NsgInputTheme?>)> mount(
    WidgetTester tester, {
    NsgInputTheme? theme,
    bool dark = false,
    bool date = false,
    bool disabled = false,
    bool showDelete = true,
    ValueChanged<NsgDataItem>? changed,
    void Function(NsgDataItem, String)? complete,
    GlobalKey? boundary,
  }) async {
    tester.view.physicalSize = const Size(390, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final row = _Record()..newRecord();
    row['name'] = 'Иван';
    row['date'] = DateTime(2026, 1, 2);
    final themes = ValueNotifier<NsgInputTheme?>(theme);
    addTearDown(themes.dispose);
    Widget app = ValueListenableBuilder<NsgInputTheme?>(
      valueListenable: themes,
      builder: (context, value, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: dark
              ? const Color(0xff201d29)
              : Colors.white,
          extensions: [if (value != null) value],
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: NsgInput(
                dataItem: row,
                fieldName: date ? 'date' : 'name',
                label: 'Имя',
                disabled: disabled,
                showDeleteIcon: showDelete,
                textStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: dark ? Colors.white : Colors.black,
                ),
                labelTextStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: dark ? Colors.white : Colors.black,
                ),
                onChanged: changed,
                onEditingComplete: complete,
              ),
            ),
          ),
        ),
      ),
    );
    if (boundary != null) app = RepaintBoundary(key: boundary, child: app);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    return (row, themes);
  }

  Future<TestGesture> hover(WidgetTester tester) async {
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byIcon(Icons.close_outlined)));
    await tester.pumpAndSettle();
    addTearDown(mouse.removePointer);
    return mouse;
  }

  Future<double> measure(
    WidgetTester tester,
    GlobalKey key,
    String name,
  ) async {
    final render =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final field = tester.getRect(find.byType(TextField)),
        icon = tester.getRect(find.byIcon(Icons.close_outlined));
    var ratio = 1.0;
    await tester.runAsync(() async {
      final image = await render.toImage(pixelRatio: 1);
      try {
        final bytes = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        Color pixel(Offset point) {
          final p = render.globalToLocal(point);
          final i = (p.dy.floor() * image.width + p.dx.floor()) * 4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        }

        final bg = pixel(Offset(field.right - 35, field.top + 3));
        final b = bg.computeLuminance();
        for (var y = icon.top.ceil(); y < icon.bottom.floor(); y++) {
          for (var x = icon.left.ceil(); x < icon.right.floor(); x++) {
            final a = pixel(Offset(x + .5, y + .5)).computeLuminance();
            ratio = math.max(
              ratio,
              (math.max(a, b) + .05) / (math.min(a, b) + .05),
            );
          }
        }
        final phase = Platform.environment['AK1_CLEAR_CAPTURE'];
        if (phase != null) {
          final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
          await File(
            '.dart_tool/ak1-clear-$phase-$name.png',
          ).writeAsBytes(png.buffer.asUint8List());
        }
      } finally {
        image.dispose();
      }
    });
    return ratio;
  }

  for (final extension in [false, true]) {
    testWidgets(
      'legacy normal and hover colors clear slot absent extension=$extension',
      (tester) async {
        await mount(
          tester,
          theme: extension
              ? const NsgInputTheme(textColor: Colors.black)
              : null,
        );
        expect(
          tester.widget<Icon>(find.byIcon(Icons.close_outlined)).color,
          nsgtheme.nsginputCloseIconColorHover,
        );
        await hover(tester);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.close_outlined)).color,
          nsgtheme.nsginputCloseIconColor,
        );
      },
    );
  }
  for (final dark in [false, true]) {
    for (final date in [false, true]) {
      testWidgets('opt-in clear normal hover callback dark=$dark date=$date', (
        tester,
      ) async {
        final ink = dark ? Colors.white : Colors.black;
        final key = GlobalKey();
        var changed = 0, complete = 0;
        final (row, _) = await mount(
          tester,
          dark: dark,
          date: date,
          boundary: key,
          theme: NsgInputTheme(clearIconColor: ink),
          changed: (_) => changed++,
          complete: (_, __) => complete++,
        );
        final state = tester.state(find.byType(NsgInput)),
            field = tester.getRect(find.byType(TextField));
        final normal = tester
            .widget<Icon>(find.byIcon(Icons.close_outlined))
            .color;
        final normalRatio = await measure(tester, key, '$dark-$date-normal');
        final mouse = await hover(tester);
        final hovered = tester
            .widget<Icon>(find.byIcon(Icons.close_outlined))
            .color;
        final hoverRatio = await measure(tester, key, '$dark-$date-hover');
        await mouse.moveTo(Offset.zero);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.close_outlined));
        await tester.pump(const Duration(milliseconds: 20));
        await tester.pumpAndSettle();
        expect(changed, 1);
        expect(complete, 1);
        if (date) {
          expect(
            (row['date'] as DateTime).isAtSameMomentAs(NsgDateHelper.minDate),
            isTrue,
          );
        } else {
          expect(row['name'], '');
        }
        expect(tester.state(find.byType(NsgInput)), same(state));
        expect(tester.getRect(find.byType(TextField)), field);
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .focusNode
              .hasFocus,
          isTrue,
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '',
        );
        // Date fields keep their legacy clear affordance even at minDate.
        expect(
          find.byIcon(Icons.close_outlined),
          date ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        debugPrint(
          'CLEAR_THEME dark=$dark date=$date normal=$normalRatio hover=$hoverRatio',
        );
        expect(normal, ink);
        expect(hovered, ink);
        expect(normalRatio, greaterThanOrEqualTo(3));
        expect(hoverRatio, greaterThanOrEqualTo(3));
      });
    }
  }
  for (final disabled in [false, true]) {
    testWidgets('clear hidden disabled=$disabled without geometry change', (
      tester,
    ) async {
      await mount(
        tester,
        theme: const NsgInputTheme(clearIconColor: Colors.black),
        disabled: disabled,
        showDelete: disabled,
      );
      expect(find.byIcon(Icons.close_outlined), findsNothing);
    });
  }
  testWidgets('clear theme update keeps state controller and focus', (
    tester,
  ) async {
    final (row, themes) = await mount(
      tester,
      theme: const NsgInputTheme(clearIconColor: Colors.black),
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(NsgInput)),
        editable = tester.state<EditableTextState>(find.byType(EditableText)),
        controller = tester
            .widget<TextField>(find.byType(TextField))
            .controller;
    final rect = tester.getRect(find.byType(TextField));
    themes.value = const NsgInputTheme(clearIconColor: Colors.deepPurple);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Icon>(find.byIcon(Icons.close_outlined)).color,
      Colors.deepPurple,
    );
    expect(tester.state(find.byType(NsgInput)), same(state));
    expect(
      tester.state<EditableTextState>(find.byType(EditableText)),
      same(editable),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller,
      same(controller),
    );
    expect(tester.getRect(find.byType(TextField)), rect);
    expect(editable.widget.focusNode.hasFocus, isTrue);
    expect(row['name'], 'Иван');
  });
  test('clear slot copyWith and lerp', () {
    const a = NsgInputTheme(
          clearIconColor: Colors.black,
          textColor: Colors.red,
        ),
        b = NsgInputTheme(clearIconColor: Colors.white);
    expect(a.copyWith().clearIconColor, Colors.black);
    expect(a.copyWith(clearIconColor: Colors.blue).clearIconColor, Colors.blue);
    expect(a.copyWith(clearIconColor: Colors.blue).textColor, Colors.red);
    expect(
      a.lerp(b, .5).clearIconColor,
      Color.lerp(Colors.black, Colors.white, .5),
    );
    expect(a.lerp(null, .5), same(a));
    expect(const NsgInputTheme().clearIconColor, isNull);
  });
}
