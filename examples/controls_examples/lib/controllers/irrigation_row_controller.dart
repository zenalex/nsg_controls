import 'package:nsg_data/nsg_data.dart';

import '../model/irrigation_row.dart';

class IrrigationRowController extends NsgDataController<IrrigationRow> {
  IrrigationRowController() : super(requestOnInit: false, autoRepeate: true, autoRepeateCount: 10);

  int selectedWateringDay = 0;
}
