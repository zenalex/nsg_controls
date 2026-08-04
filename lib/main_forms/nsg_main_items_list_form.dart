import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/navigator/nsg_navigator.dart';
import 'package:nsg_data/nsg_data_item.dart';

class NsgMainItemsListForm<T extends NsgDataItem> extends StatelessWidget {
  const NsgMainItemsListForm({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.putOrFind<NsgMainFormController<T>>(() => NsgMainFormController<T>());
    return BodyWrap(
      child: Column(
        children: [
          NsgLightAppBar(
            title: controller.title,
            leftIcons: [NsgLigthAppBarIcon(icon: Icons.arrow_back, onTap: () => NsgNavigator.pop())],
            rightIcons: [NsgLigthAppBarIcon(icon: Icons.add, onTap: () => controller.itemNewPageOpen(controller.getItemPageRoute()))],
          ),
          Expanded(child: controller.getListWidget((item) => item.buildItemWidget(context))),
        ],
      ),
    );
  }
}

extension on NsgDataItem {
  Widget buildItemWidget(BuildContext context) {
    return Row(children: fieldList.fields.values.map((field) => Text(getFieldValue(field.name).toString())).toList());
  }
}
