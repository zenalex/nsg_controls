import 'package:get/get.dart';
import 'package:nsg_data/nsgApiException.dart';

///Класс для отображение ошибок для пользователю
class NsgErrorWidget {
  static void showError(NsgApiException exception) {
    Get.defaultDialog(title: 'ОШИБКА ${exception.error.code}', textConfirm: 'OK', middleText: exception.error.message ?? '');
  }
}
