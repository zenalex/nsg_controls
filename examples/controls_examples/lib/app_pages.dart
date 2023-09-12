import 'package:get/get.dart';

import 'main_binding.dart';
import 'start_page.dart';

class AppPages {
  static const initial = Routes.startPage;

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.startPage,
      page: () => StartPage(),
      binding: MainBinding(),
    ),
  ];
}

abstract class Routes {
  static const startPage = '/start';
}
