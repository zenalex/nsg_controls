import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/formfields/nsg_input.dart';
import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/main_forms/nsg_main_pages_factory.dart';
import 'package:nsg_controls/widgets/body_wrap.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';

class NsgMainItemForm extends StatelessWidget {
  const NsgMainItemForm({super.key, required this.dataType});
  final Type dataType;

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<NsgMainFormController>(tag: ControlsRoutes.getTagForType(dataType));
    return BodyWrap(
      child: Column(
        children: [
          NsgLightAppBar(
            title: controller.currentItem.id,
            leftIcons: [
              NsgLigthAppBarIcon(
                icon: Icons.arrow_back,
                onTap: () => controller.itemPageCancel(context: context),
              ),
            ],
            rightIcons: [NsgLigthAppBarIcon(icon: Icons.save, onTap: () => controller.itemPagePost())],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: controller.getFormFields((item, title, field) => NsgInput(dataItem: item, fieldName: field.name, label: title)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
