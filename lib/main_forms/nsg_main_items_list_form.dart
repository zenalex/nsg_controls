import 'package:flutter/material.dart';
import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/new_table/nsg_base_table.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/navigator/nsg_navigator.dart';

class NsgMainItemsListForm extends StatelessWidget {
  const NsgMainItemsListForm({super.key, required this.dataType});
  final Type dataType;

  @override
  Widget build(BuildContext context) {
    var controller = NsgMainFormController.getTypeDefaultController(dataType)!;
    controller.buildTable();
    return Material(
      child: BodyWrap(
        child: Column(
          children: [
            NsgLightAppBar(
              title: controller.listTitle,
              leftIcons: [NsgLigthAppBarIcon(icon: Icons.arrow_back, onTap: () => NsgNavigator.pop())],
              rightIcons: [NsgLigthAppBarIcon(icon: Icons.add, onTap: () => controller.itemNewDefaultPageOpen())],
            ),
            Expanded(child: NsgBaseTable(controller: controller.tableController!)),
          ],
        ),
      ),
    );
  }
}
