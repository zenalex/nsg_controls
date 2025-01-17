import 'package:get/get.dart';
import 'package:nsg_controls/nsg_progress_dialog.dart';
import 'package:nsg_data/nsg_data.dart';

import '../app_pages.dart';
import '../controllers/irrigation_row_controller.dart';
import '../controllers/student_controller.dart';
import 'generated/data_controller.g.dart';

class DataController extends DataControllerGenerated {
  DataController() : super();
  bool controllersInitialized = false;

  @override
  Future onInit() async {
    if (provider == null) {
      provider = NsgDataProvider(
          applicationName: 'controls_examples',
          firebaseToken: '',
          applicationVersion: '',
          availableServers: NsgServerParams({'serverGroups': 'https://currentServer'}, 'https://currentServer'));
      //firebaseToken: nsgFirebase == null ? '' : nsgFirebase!.firebasetoken);
      //provider!.getLoginWidget = (provider) => LoginPage(provider);
      //provider!.getVerificationWidget = (provider) => VerificationPage(provider);
      provider!.allowConnect = false;
    }
    await super.onInit();
  }

  @override
  Future loadProviderData() async {
    await super.loadProviderData();
    await requestAllControllers();
    _gotoMainPage();
  }

  Future requestAllControllers() async {
    var progress = NsgProgressDialog(textDialog: 'Инициализация данных');
    progress.show();
    var studC = Get.find<StudentController>();
    var irrC = Get.find<IrrigationRowController>();

    await studC.requestItems();
    await irrC.requestItems();

    controllersInitialized = true;
    progress.hide();
  }

  bool _animationFinished = false;

  void splashAnimationFinished() async {
    _animationFinished = true;
    _gotoMainPage();
  }

  void _gotoMainPage() {
    if (_animationFinished && controllersInitialized) {
      NsgNavigator.instance.offAndToPage(Routes.startPage);
    }
  }
}
