// TypeError «PreparingCropEditorViewState is not a subtype of
// ReadyCropEditorViewState» при обрезке фото (NSG-SOFT/futbolista-tasks#1777,
// GT-4528, 95 событий).
//
// _crop() пакета crop_your_image сначала отдаёт результат в onCropped, а потом
// шлёт CropStatus.ready. NsgCropPage в onCropped подменяет картинку в
// редакторе, тот синхронно возвращается в Preparing, и сеттер aspectRatio из
// ready-колбэка падал на касте к Ready. Так было при каждом нажатии «обрезать».
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as imagedit;
import 'package:nsg_controls/file_picker/nsg_crop_page.dart';

void main() {
  testWidgets('обрезка с заданной пропорцией не бросает', (tester) async {
    final png = Uint8List.fromList(imagedit.encodePng(imagedit.Image(width: 80, height: 60)));
    final page = NsgCropPage(imageDataList: [png], aspectRatio: 1, isFree: false);

    await tester.pumpWidget(GetMaterialApp(home: page));

    // Разбор картинки и сама обрезка идут через compute — ждём по-настоящему.
    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
    }

    await settle();
    final before = page.imageDataList.first;

    await tester.tap(find.byIcon(Icons.crop));
    await settle();

    expect(tester.takeException(), isNull);
    // Анимации GetX заводят отложенные таймеры — снимаем дерево и
    // прокручиваем время, чтобы они не висели после теста.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(identical(page.imageDataList.first, before), isFalse, reason: 'обрезка должна была состояться');
  });
}
