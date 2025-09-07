// импорт
import 'package:flutter/material.dart';

import '../nsg_text.dart';

class NsgErrorPage extends StatelessWidget {
  final String? text;
  const NsgErrorPage({super.key, this.text = ''});

  title() {
    List<String> list = (text ?? 'Неизвестная ошибка|||').split('|||');
    return list[0];
  }

  @override
  Widget build(BuildContext context) {
    List<String> list = (text ?? 'Неизвестная ошибка|||').split('|||');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: NsgText("Ошибка ${list[0]}", type: NsgTextType.h1),
            ),
            if (list.length > 1) Flexible(child: SingleChildScrollView(child: NsgText(list[1]))),
          ],
        ),
      ),
    );
  }
}
