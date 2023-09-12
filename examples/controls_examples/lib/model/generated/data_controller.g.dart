import 'package:get/get.dart';
import 'package:nsg_data/nsg_data.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import '../options/server_options.dart';
import '../data_controller_model.dart';

class DataControllerGenerated extends NsgBaseController {
  NsgDataProvider? provider;
  @override
  Future onInit() async {
    final info = await PackageInfo.fromPlatform();
    NsgMetrica.activate();
    NsgMetrica.reportAppStart();
    provider ??= NsgDataProvider(applicationName: 'BonPlantLocalApp', applicationVersion: info.version, firebaseToken: '');
    provider!.serverUri = NsgServerOptions.serverUriDataController;

    NsgDataClient.client
        .registerDataItem(Student(), remoteProvider: provider);
    NsgDataClient.client
        .registerDataItem(IrrigationRow(), remoteProvider: provider);
    await NsgLocalDb.instance.init(provider!.applicationName);
    provider!.useNsgAuthorization = true;
    var db = NsgLocalDb.instance;
    await db.init('BonPlantLocalApp');
    await provider!.connect(this);

    super.onInit();
  }

  @override
  Future loadProviderData() async {
    currentStatus = GetStatus.success(NsgBaseController.emptyData);
    sendNotify();
  }
}
