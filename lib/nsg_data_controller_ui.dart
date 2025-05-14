import 'package:flutter/material.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';

extension NsgDataUIExtension<T extends NsgDataItem> on NsgDataUI<T> {
  ///Виджет списка объектов
  Widget getListWidget(Widget? Function(T item) itemBuilder, {Widget? onEmptyList}) {
    return obx(
      (state) => ListView.builder(
        controller: scrollController,
        itemCount: items.length + 1,
        itemBuilder: (context, i) {
          if (items.isEmpty) {
            return onEmptyList ?? Padding(padding: EdgeInsets.only(top: 15, left: 20), child: Text(tranControls.empty_list));
          } else {
            if (i >= items.length) {
              if (scrollController.status == NsgLoadingScrollStatus.loading) {
                return NsgBaseController.getDefaultProgressIndicator();
              } else {
                return const SizedBox();
              }
            } else {
              return itemBuilder(items[i]);
            }
          }
        },
      ),
    );
  }
}
