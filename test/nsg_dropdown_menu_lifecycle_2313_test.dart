import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/dropdown/nsg_dropdown_menu.dart';
import 'package:nsg_controls/dropdown/nsg_dropdown_menu_item.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    ControlOptions.instance = ControlOptions(
      appMinWidth: 320,
      appMaxWidth: 1920,
    );
  });
  tearDown(Get.reset);

  Future<(NsgDropdownMenu, BuildContext, ValueNotifier<bool>)> mount(
    WidgetTester tester, {
    bool sliver = false,
  }) async {
    final visible = ValueNotifier(true);
    final key = GlobalKey();
    late BuildContext owner;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              owner = context;
              return ValueListenableBuilder<bool>(
                valueListenable: visible,
                builder: (_, value, _) {
                  if (!value) {
                    return const SizedBox();
                  }
                  if (sliver) {
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          key: key,
                          padding: const EdgeInsets.all(8),
                          sliver: const SliverToBoxAdapter(
                            child: SizedBox(height: 30),
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: SizedBox(key: key, width: 80, height: 30),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    final anchor = key.currentContext!;
    final menu = NsgDropdownMenu(
      context: owner,
      widgetList: () => [const NsgDropdownMenuItem(text: 'Choice')],
    );
    addTearDown(visible.dispose);
    addTearDown(menu.hideOverlay);
    return (menu, anchor, visible);
  }

  for (final explicitOffset in [false, true]) {
    testWidgets('live anchor/explicitOffset=$explicitOffset selects once', (
      tester,
    ) async {
      final (menu, anchor, _) = await mount(tester);
      var selected = 0;
      menu.showOverlay(
        parentContext: anchor,
        offset: explicitOffset ? const Offset(10, 10) : null,
        onSelect: (_, __) => selected++,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Choice'), findsOneWidget);
      await tester.tap(find.text('Choice'));
      await tester.pump();
      expect(selected, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('disposed parent before show does not open or throw', (
    tester,
  ) async {
    final (menu, anchor, visible) = await mount(tester);
    visible.value = false;
    await tester.pump();
    expect(anchor.mounted, isFalse);
    menu.showOverlay(parentContext: anchor, onSelect: (_, __) {});
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Choice'), findsNothing);
    expect(menu.entry, isNull);
  });

  testWidgets('disposed owner before show does not look up Overlay', (
    tester,
  ) async {
    final (menu, anchor, _) = await mount(tester);
    await tester.pumpWidget(const SizedBox());
    expect(menu.context.mounted, isFalse);
    menu.showOverlay(parentContext: anchor, onSelect: (_, __) {});
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(menu.entry, isNull);
  });

  testWidgets('overlay rebuild after anchor disposal dismisses its own entry', (
    tester,
  ) async {
    final (menu, anchor, visible) = await mount(tester);
    menu.showOverlay(parentContext: anchor, onSelect: (_, __) {});
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    visible.value = false;
    await tester.pump();
    expect(anchor.mounted, isFalse);
    menu.entry!.markNeedsBuild();
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(menu.entry, isNull);
    expect(find.text('Choice'), findsNothing);
    // Drain GetMaterialApp's zero-delay rebuild timer before teardown.
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('mounted non-RenderBox anchor is rejected without a cast', (
    tester,
  ) async {
    final (menu, anchor, _) = await mount(tester, sliver: true);
    expect(anchor.mounted, isTrue);
    expect(anchor.findRenderObject(), isNot(isA<RenderBox>()));
    menu.showOverlay(parentContext: anchor, onSelect: (_, __) {});
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(menu.entry, isNull);
  });
  testWidgets('explicit offset does not require a RenderBox anchor', (
    tester,
  ) async {
    final (menu, anchor, _) = await mount(tester, sliver: true);
    var selected = 0;
    menu.showOverlay(
      parentContext: anchor,
      offset: const Offset(10, 10),
      onSelect: (_, __) => selected++,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.text('Choice'), findsOneWidget);
    await tester.tap(find.text('Choice'));
    await tester.pump();
    expect(selected, 1);
    expect(menu.entry, isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('mounted owner without Overlay does not open or throw', (
    tester,
  ) async {
    late BuildContext owner;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            owner = context;
            return const SizedBox();
          },
        ),
      ),
    );
    final menu = NsgDropdownMenu(
      context: owner,
      widgetList: () => [const NsgDropdownMenuItem(text: 'Choice')],
    );
    menu.showOverlay(offset: const Offset(10, 10), onSelect: (_, __) {});
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(menu.entry, isNull);
  });
}
