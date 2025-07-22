import 'package:get/get.dart';

import '../controllers/irrigation_row_controller.dart';
import '../controllers/student_controller.dart';
import '../model/data_controller.dart';

// ignore: deprecated_member_use
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataController(), permanent: true);
    Get.put(StudentController(), permanent: true);
    Get.put(IrrigationRowController(), permanent: true);
  }
}
