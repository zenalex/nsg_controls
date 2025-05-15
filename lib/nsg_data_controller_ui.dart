import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/new_path_route.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';

extension NsgDataUIExtension<T extends NsgDataItem> on NsgDataUI<T> {
  ///Виджет списка объектов
  Widget getListWidget(Widget? Function(T item) itemBuilder,
      {Widget? onEmptyList, String? grFieldName, Widget? Function(dynamic value)? dividerBuilder, PartOfDate partOfDate = PartOfDate.day}) {
    return obx(
      (state) {
        DataGroupList dataGroups;
        if (grFieldName != null) {
          dataGroups = DataGroupList(_getGroupsByFieldName(grFieldName, partOfDate), needDivider: true);
        } else {
          dataGroups = DataGroupList([DataGroup(data: items, groupFieldName: "")]);
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: dataGroups.length + (items.isEmpty ? 1 : 2),
          itemBuilder: (context, i) {
            if (items.isEmpty) {
              return onEmptyList ?? Padding(padding: EdgeInsets.only(top: 15, left: 20), child: Text(tranControls.empty_list));
            } else {
              if (i > dataGroups.length) {
                if (scrollController.status == NsgLoadingScrollStatus.loading) {
                  return NsgBaseController.getDefaultProgressIndicator();
                } else {
                  return const SizedBox();
                }
              } else {
                var elem = dataGroups.getElemet(i);
                if (elem.isDivider) {
                  if (dividerBuilder != null) {
                    return dividerBuilder(elem.value);
                  } else {
                    return elem.group.goupDividerWidget;
                  }
                } else {
                  return itemBuilder(elem.value as T);
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

class DataGroupList {
  DataGroupList(this.groups, {this.needDivider = false}) {
    Map<DataGroup, ({int first, int last})> map = {};
    int firstIndex = 0;
    for (var gr in groups) {
      map.addAll({gr: (first: firstIndex, last: firstIndex + gr.data.length - (needDivider ? 0 : 1))});
      _length = firstIndex + gr.data.length - (needDivider ? 0 : 1);
      firstIndex += gr.data.length + (needDivider ? 1 : 0);
    }
    _sizes = map;
  }

  bool needDivider;
  List<DataGroup> groups;

  Map<DataGroup, ({int first, int last})> _sizes = {};
  int _length = 0;

  int get length => _length;

  ({dynamic value, DataGroup group, bool isDivider}) getElemet(int index) {
    var group = _sizes.entries.firstWhereOrNull((i) => i.value.first <= index && index <= i.value.last);
    if (group != null) {
      if (index - group.value.first > 0 || !needDivider) {
        return (value: group.key.data[index - group.value.first - (needDivider ? 1 : 0)], group: group.key, isDivider: false);
      }
      return (value: group.key.groupValue, group: group.key, isDivider: true);
    }
    throw (RangeError("index $index out of range"));
  }
}

class DataGroup {
  const DataGroup({required this.data, required this.groupFieldName, this.dividerBuilder, this.forDateFilters = PartOfDate.day});
  final List<NsgDataItem> data;
  final String groupFieldName;
  final Widget Function(String grName, dynamic fieldValue)? dividerBuilder;
  final PartOfDate forDateFilters;

  String get groupName {
    if (groupValue != null) {
      try {
        return groupValue.toString();
      } catch (ex) {
        return "error";
      }
    }
    return "";
  }

  dynamic get groupValue {
    if (data.isNotEmpty) {
      try {
        if (data.first.getField(groupFieldName) is NsgDataReferenceField) {
          return data.first.getReferent(groupFieldName);
        } else if (data.first.getField(groupFieldName) is NsgDataEnumReferenceField) {
          return data.first.getReferent(groupFieldName);
        } else if (data.first.getField(groupFieldName) is NsgDataBoolField) {
          return data.first.getFieldValue(groupFieldName);
        } else if (data.first.getField(groupFieldName) is NsgDataStringField ||
            data.first.getField(groupFieldName) is NsgDataIntField ||
            data.first.getField(groupFieldName) is NsgDataDoubleField) {
          return data.first.getFieldValue(groupFieldName);
        } else if (data.first.getField(groupFieldName) is NsgDataDateField) {
          return data.first.getFieldValue(groupFieldName);
        } else {
          throw Exception("Не указан тип поля ввода, тип данных неизвестен");
        }
      } catch (ex) {
        return null;
      }
    }
    return null;
  }

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
