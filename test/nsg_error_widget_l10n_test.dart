// Подписи диалога ошибки настраиваемые, умолчание — русские строки прежних
// версий (NSG-SOFT/futbolista-tasks#3510). До правки «Копировать»/«Переслать»
// были зашиты в nsg_error_widget.dart и в английском интерфейсе приложения
// диалог оставался русским.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';

void main() {
  tearDown(NsgErrorWidget.resetTexts);

  test('умолчания — русские строки, остальные приложения не меняются', () {
    expect(NsgErrorWidget.textCopy, 'Копировать');
    expect(NsgErrorWidget.textCopiedToClipboard, 'Скопировано в буфер обмена');
    expect(NsgErrorWidget.textShare, 'Переслать');
    expect(NsgErrorWidget.textShareSubject, 'Отправить текст ошибки');
  });

  Future<void> openErrorDialog(WidgetTester tester, String message) async {
    // GetMaterialApp, а не MaterialApp: _showError читает Get.context.
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox.shrink())));
    await tester.pumpAndSettle();

    // Фьюча завершится только при закрытии диалога — не ждём её.
    // ignore: unawaited_futures
    NsgErrorWidget.showErrorByString(message);
    await tester.pumpAndSettle();
  }

  testWidgets('без настройки диалог показывает русские подписи', (tester) async {
    await openErrorDialog(tester, 'boom');

    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Копировать'), findsOneWidget);
    expect(find.text('Переслать'), findsOneWidget);
  });

  testWidgets('диалог показывает заданные приложением подписи', (tester) async {
    NsgErrorWidget.textCopy = 'Copy';
    NsgErrorWidget.textCopiedToClipboard = 'Copied to clipboard';
    NsgErrorWidget.textShare = 'Forward';
    NsgErrorWidget.textShareSubject = 'Send error text';

    await openErrorDialog(tester, 'boom');

    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Forward'), findsOneWidget);
    expect(find.text('Копировать'), findsNothing);
    expect(find.text('Переслать'), findsNothing);
  });
}
