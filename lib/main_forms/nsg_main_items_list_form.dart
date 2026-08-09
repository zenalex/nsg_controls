import 'package:flutter/material.dart';
import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/navigator/nsg_navigator.dart';
import 'package:nsg_data/nsg_data_item.dart';

class NsgMainItemsListForm extends StatelessWidget {
  const NsgMainItemsListForm({super.key, required this.dataType});
  final Type dataType;

  @override
  Widget build(BuildContext context) {
    var controller = NsgMainFormController.getTypeDefaultController(dataType)!;
    return Material(
      child: BodyWrap(
        child: Column(
          children: [
            NsgLightAppBar(
              title: controller.listTitle,
              leftIcons: [NsgLigthAppBarIcon(icon: Icons.arrow_back, onTap: () => NsgNavigator.pop())],
              rightIcons: [NsgLigthAppBarIcon(icon: Icons.add, onTap: () => controller.itemNewDefaultPageOpen())],
            ),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(10), child: controller.getListWidget((item) => item.buildItemWidget(context, controller))),
            ),
          ],
        ),
      ),
    );
  }
}

extension on NsgDataItem {
  Widget buildItemWidget(BuildContext context, NsgMainFormController controller) {
    return GestureDetector(
      onTap: () => controller.itemDefaultPageOpen(this),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.all(10),
        child: Text(toString()),
      ),
    );
  }
}
