import 'package:controls_examples/model/generated/irrigation_row.g.dart';
import 'package:controls_examples/model/irrigation_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import 'controllers/irrigation_row_controller.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  var controller = Get.find<IrrigationRowController>();

  @override
  Widget build(BuildContext context) {
    return BodyWrap(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'CONTROLS EXAMPLES',
                  style: TextStyle(fontSize: nsgtheme.sizeH1),
                ),
              ),
              Expanded(child: controller.obx((state) => showTable())),
              button()
            ],
          ),
        ),
      ),
    );
  }

  Widget showTable() {
    List<NsgTableColumn> columns = [
      NsgTableColumn(name: IrrigationRowGenerated.nameDay, presentation: 'День', width: 400),
      NsgTableColumn(name: IrrigationRowGenerated.nameHour, presentation: 'Час', width: 400)
    ];
    return NsgTable(columns: columns, controller: controller);
  }

  Widget button() {
    return NsgButton(
      width: 200,
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      text: 'Добавить 5 строк',
      onPressed: () {
        for (var i = 0; i < 5; i++) {
          IrrigationRow item = IrrigationRow();
          item.newRecord();
          controller.items.add(item);
        }
        controller.sendNotify();
      },
    );
  }
}
