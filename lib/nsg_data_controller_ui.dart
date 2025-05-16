import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_measurable.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';

extension NsgDataUIExtension<T extends NsgDataItem> on NsgDataUI<T> {
  ///Виджет списка объектов
  Widget getListWidget(Widget? Function(T item) itemBuilder,
      {Widget? onEmptyList, String? grFieldName, Widget? Function(dynamic value)? dividerBuilder, PartOfDate partOfDate = PartOfDate.day, Key? key}) {
    return obx(
      (state) {
        DataGroupList dataGroups;
        if (grFieldName != null) {
          dataGroups = DataGroupList(_getGroupsByFieldName(grFieldName, partOfDate), needDivider: true);
        } else {
          dataGroups = DataGroupList([DataGroup(data: items, groupFieldName: "")]);
        }

        //scrollController.heightMap.clear();
        scrollController.dataGroups = dataGroups;

        return ListView.builder(
          controller: scrollController,
          itemCount: scrollController.dataGroups.length + (items.isEmpty ? 1 : 2),
          itemBuilder: (context, i) {
            if (items.isEmpty) {
              return onEmptyList ?? Padding(padding: EdgeInsets.only(top: 15, left: 20), child: Text(tranControls.empty_list));
            } else {
              if (i > scrollController.dataGroups.length) {
                if (scrollController.status == NsgLoadingScrollStatus.loading) {
                  return NsgBaseController.getDefaultProgressIndicator();
                } else {
                  return const SizedBox();
                }
              } else {
                var elem = scrollController.dataGroups.getElemet(i);
                if (elem.isDivider) {
                  if (dividerBuilder != null) {
                    return Container(
                        key: elem.key, /*onHeight: (h) => scrollController.heightMap.addAll({i: h}),*/ child: dividerBuilder(elem.value) ?? SizedBox());
                  } else {
                    return Container(key: elem.key, /*onHeight: (h) => scrollController.heightMap.addAll({i: h}),*/ child: elem.group.goupDividerWidget);
                  }
                } else {
                  return Container(
                      key: elem.key, /*onHeight: (h) => scrollController.heightMap.addAll({i: h}),*/ child: itemBuilder(elem.value as T) ?? SizedBox());
                }
              }

              // if (i >= items.length) {
              //   if (scrollController.status == NsgLoadingScrollStatus.loading) {
              //     return NsgBaseController.getDefaultProgressIndicator();
              //   } else {
              //     return const SizedBox();
              //   }
              // } else {
              //   return itemBuilder(items[i]);
              // }
            }
          },
        );
      },
    );
  }

  List<DataGroup> _getGroupsByFieldName(String fieldName, PartOfDate partOfDate) {
    List<DataGroup> groupsList = [];
    Map<dynamic, List<NsgDataItem>> groupsMap = {};
    for (var item in items) {
      bool equialDate = false;
      String formatedDate = "";
      if (item.getField(fieldName) is NsgDataDateField) {
        formatedDate =
            NsgDateFormat.dateFormat(item.getFieldValue(fieldName), format: partOfDate.formatTime, locale: Localizations.localeOf(Get.context!).languageCode);

        equialDate = (item.getField(fieldName) is NsgDataDateField && groupsMap.containsKey(formatedDate));

        if (equialDate) {
          groupsMap[formatedDate] != null ? groupsMap[formatedDate]!.add(item) : groupsMap[formatedDate] = [item];
        } else {
          groupsMap.addAll({
            formatedDate: [item]
          });
        }
      } else {
        if (groupsMap.containsKey(item.getFieldValue(fieldName))) {
          groupsMap[item.getFieldValue(fieldName)] != null
              ? groupsMap[item.getFieldValue(fieldName)]!.add(item)
              : groupsMap[item.getFieldValue(fieldName)] = [item];
        } else {
          groupsMap.addAll({
            item.getFieldValue(fieldName): [item]
          });
        }
      }
    }
    for (var key in groupsMap.keys) {
      groupsList.add(DataGroup(data: groupsMap[key]!.toList(), groupFieldName: fieldName));
    }
    return groupsList;
  }
}

extension DataGroupUi on DataGroup {
  Widget get goupDividerWidget {
    if (dividerBuilder != null) {
      return dividerBuilder!(groupName, groupValue);
    } else {
      return Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: nsgtheme.colorSecondary, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [Center(child: Text(groupName))]));
    }
  }
}

enum PartOfDate {
  second,
  minute,
  hour,
  day,
  month,
  year;

  const PartOfDate();

  String get formatTime {
    switch (this) {
      case second:
        return "HH:mm:ss dd.MM.yyyy";
      case minute:
        return "HH:mm dd.MM.yyyy";
      case hour:
        return "HH dd.MM.yyyy";
      case day:
        return "dd.MM.yyyy";
      case month:
        return "MM.yyyy";
      case year:
        return "yyyy";
    }
  }
}
