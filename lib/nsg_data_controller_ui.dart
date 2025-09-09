import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:nsg_data/ui/nsg_loading_scroll_controller.dart';

extension NsgDataUIExtension<T extends NsgDataItem> on NsgDataUI<T> {
  ///Виджет списка объектов
  ///Если задать `grFieldName` в контроллере!!! - то сгруппирует элементы по заданному полю.
  ///Автоматически добавит в начало сортировку по `grFieldName`
  ///в направлении `sortDirection` (по умолчанию `NsgSortingDirection.ascending`).
  ///После добавит `sortingParams`, а затем `getRequestFilter.sorting`.
  ///В случае, если `grFieldName` - дата, будет считать объеты различными согласно `partOfDate`.
  ///Для каждой группы будет выведен заголовок `dividerBuilder`, а если список пуст - `onEmptyList`.
  ///
  ///```
  /// matchC.getListWidget(
  ///             (match) {
  ///               return
  ///                 child: MatchNewCard(
  ///                   matchItem: match
  ///                 );
  ///             },
  ///             dividerBuilder: (currentDate) {
  ///               currentDate as DateTime;
  ///               return Container(
  ///                 margin: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
  ///                 padding: const EdgeInsets.all(5),
  ///                 width: double.infinity,
  ///                 decoration: BoxDecoration(color: nsgtheme.colorSecondary, borderRadius: BorderRadius.circular(6)),
  ///                 child: Text(
  ///                   '${NsgDateFormat.dateFormat(currentDate, format: (currentDate.year < DateTime.now().year)
  ///                     ? 'dd MMMM yyyy, EE'
  ///                     : 'dd MMMM, EE', locale: FutbolistaApp.defaultLocale.languageCode)}'.toUpperCase(),
  ///                   textAlign: TextAlign.center,
  ///                 ),
  ///               );
  ///             },
  ///   ),
  ///```
  Widget getListWidget(
    Widget? Function(T item) itemBuilder, {
    Widget? onEmptyList,
    Widget? Function(dynamic value)? dividerBuilder,
    PartOfDate partOfDate = PartOfDate.day,
    Key? key,
  }) => obx((state) {
    DataGroupList dataGroups;
    if (grFieldName != null) {
      dataGroups = DataGroupList(_getGroupsByFieldName(grFieldName!, partOfDate), needDivider: true);
    } else {
      dataGroups = DataGroupList([DataGroup(data: items, groupFieldName: "")]);
    }

    //scrollController.heightMap.clear();
    scrollController.dataGroups = dataGroups;

    // Defer scroll restoration to avoid RenderSliverList mutation during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && scrollController.lastOffset != 0.0) {
        scrollController.jumpTo(scrollController.lastOffset);
      }
    });

    return ListView.builder(
      controller: scrollController,
      itemCount: scrollController.dataGroups.length + (items.isEmpty ? 1 : 2),
      itemBuilder: (context, i) {
        if (items.isEmpty) {
          return onEmptyList ?? Padding(padding: EdgeInsets.only(top: 15, left: 20), child: Text(tran.empty_list));
        } else {
          if (i >= scrollController.dataGroups.length) {
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
                  key: elem.key,
                  /*onHeight: (h) => scrollController.heightMap.addAll({i: h}),*/ child: dividerBuilder(elem.value) ?? SizedBox(),
                );
              } else {
                return Container(key: elem.key, /*onHeight: (h) => scrollController.heightMap.addAll({i: h}),*/ child: elem.group.goupDividerWidget);
              }
            } else {
              return Container(
                key: elem.key,
                /*onHeight: (h) => scrollController.heightMap.addAll({i: h}),*/ child: itemBuilder(elem.value as T) ?? SizedBox(),
              );
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
  });

  List<DataGroup> _getGroupsByFieldName(String fieldName, PartOfDate partOfDate) {
    List<DataGroup> groupsList = [];
    Map<dynamic, List<NsgDataItem>> groupsMap = {};
    List<NsgDataItem> addedList = [];
    for (var item in items) {
      if (addedList.contains(item)) {
        printWarning("Double Item ${items.indexOf(item) + 1} & ${addedList.length + 1} - $item");
        continue;
      }
      addedList.add(item);
      bool equialDate = false;
      String formatedDate = "";
      if (item.getField(fieldName) is NsgDataDateField) {
        formatedDate = NsgDateFormat.dateFormat(
          item.getFieldValue(fieldName),
          format: partOfDate.formatTime,
          locale: Localizations.localeOf(Get.context!).languageCode,
        );

        equialDate = (item.getField(fieldName) is NsgDataDateField && groupsMap.containsKey(formatedDate));

        if (equialDate) {
          groupsMap[formatedDate] != null ? groupsMap[formatedDate]!.add(item) : groupsMap[formatedDate] = [item];
        } else {
          groupsMap.addAll({
            formatedDate: [item],
          });
        }
      } else {
        if (groupsMap.containsKey(item.getFieldValue(fieldName))) {
          groupsMap[item.getFieldValue(fieldName)] != null
              ? groupsMap[item.getFieldValue(fieldName)]!.add(item)
              : groupsMap[item.getFieldValue(fieldName)] = [item];
        } else {
          groupsMap.addAll({
            item.getFieldValue(fieldName): [item],
          });
        }
      }
    }
    for (var key in groupsMap.keys) {
      groupsList.add(DataGroup(data: groupsMap[key]!.toList(), groupFieldName: fieldName, partOfDate: partOfDate));
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
        child: Row(children: [Center(child: Text(groupName))]),
      );
    }
  }
}
