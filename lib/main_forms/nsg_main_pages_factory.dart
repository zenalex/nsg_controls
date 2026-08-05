import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/main_forms/nsg_main_item_form.dart';
import 'package:nsg_controls/main_forms/nsg_main_items_list_form.dart';
import 'package:nsg_data/nsg_data_client.dart';

typedef ControllerFactory = NsgMainFormController Function();
typedef PageItemFactory = NsgMainItemForm Function();
typedef PageListFactory = NsgMainItemsListForm Function();
typedef TagFactory = String Function();

abstract class ControlsRoutes {
  static final registry = <Type, ({ControllerFactory c, PageItemFactory p, PageListFactory l, TagFactory t})>{};
  static void register(Type type, {required ControllerFactory c, required PageItemFactory p, required PageListFactory l, required TagFactory t}) {
    registry[type] = (c: c, p: p, l: l, t: t);
  }

  static void initRegistry() {
    for (var item in NsgDataClient.client.registeredDataItems) {
      registry[item.runtimeType] = (
        c: () => NsgMainFormController(item.runtimeType),
        p: () => NsgMainItemForm(dataType: item.runtimeType),
        l: () => NsgMainItemsListForm(dataType: item.runtimeType),
        t: () => item.runtimeType.toString(),
      );
    }
  }

  static String getTagForType(Type dataType) {
    return registry[dataType]?.t() ?? '';
  }
}
