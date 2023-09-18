import 'package:get/get.dart';

import 'splash/splash_binding.dart';
import 'splash/splash_page.dart';
import 'start_page.dart';

class AppPages {
  static const initial = Routes.splashPage;

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.splashPage,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.startPage,
      page: () => const StartPage(),
      //binding: MainBinding(),
    ),
  ];
}

abstract class Routes {
  static const startPage = '/start';
  static const splashPage = '/splash';
}
