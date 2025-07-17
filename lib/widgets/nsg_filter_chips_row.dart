import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/nsg_style_button.dart';
import 'package:nsg_data/controllers/nsg_controller_regime.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgFilterChipsRow extends StatefulWidget {
  const NsgFilterChipsRow({
    super.key,
    required this.chipsList,
    this.onClearTap,
    this.listSelectedFilters = const [],
    this.padding = const EdgeInsets.only(left: 20),
  });
  final List<NsgFilterChips> chipsList;
  final List<bool> listSelectedFilters;
  final void Function(State state)? onClearTap;
  final EdgeInsets padding;

  @override
  State<NsgFilterChipsRow> createState() => _NsgFilterChipsRowState();
}

class _NsgFilterChipsRowState extends State<NsgFilterChipsRow> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    return Scrollbar(
      controller: controller,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          key: GlobalKey(),
          children: [
            Padding(padding: widget.padding),
            ...widget.chipsList,
            if (widget.listSelectedFilters.where((element) => element == true).length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NsgTextButton(
                  onTap: () {
                    if (widget.onClearTap != null) {
                      widget.onClearTap!(this);
                    }
                  },
                  text: tran.cancel,
                  color: nsgtheme.colorError,
                  padding: EdgeInsets.zero,
                ),
              ),
            if (widget.listSelectedFilters.where((element) => element == true).length > 1) const Padding(padding: EdgeInsets.only(left: 50)),
          ],
        ),
      ),
    );
  }
}

class NsgFilterChips extends StatefulWidget {
  const NsgFilterChips({
    super.key,
    this.onItemTap,
    this.onClearFilter,
    required this.builder,
    required this.title,
    this.fieldName,
    required this.filterItem,
    this.controller,
    this.multipleSelect = true,
    this.defaultValue,
    this.onEditingComplete,
    this.maxWidth,
    this.presentation,
    this.selectionForm = '',
    this.style = const NsgFilterChipsStyle(),
  });

  final String title;
  final double? maxWidth;

  ///If null, chips will be always have unactive color. You can use NsgFilterValues.empty if you want set empty obj
  final dynamic defaultValue;
  final Widget Function(BuildContext context, NsgDataItem item, bool isSelected) builder;
  final NsgDataItem filterItem;

  ///Only if field is NsgDataListReferenceField.
  final bool multipleSelect;
  final String? fieldName;
  final void Function(NsgDataItem item)? onItemTap;

  final void Function(List<NsgDataItem> item)? onEditingComplete;
  final void Function()? onClearFilter;
  final NsgFilterChipsStyle style;
  final NsgBaseController? controller;
  final String Function(NsgDataItem item)? presentation;

  ///Имя формы для открытия при открытии пользователем чипса. Если задано имя, то форма будет открыта вместо формы по умолчани/
  final String selectionForm;

  @override
  State<NsgFilterChips> createState() => _NsgFilterChipsState();
}

class _NsgFilterChipsState extends State<NsgFilterChips> {
  late EFilterFieldType filterType;
  bool isSelected = false;
  List<NsgDataItem>? dataItemsList;
  NsgBaseController? sc;
  String presentation = '';
  bool multipleSelect = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.fieldName != null) {
      if (widget.filterItem.getField(widget.fieldName!) is NsgDataReferenceField) {
        filterType = EFilterFieldType.nsgItem;
      } else if (widget.filterItem.getField(widget.fieldName!) is NsgDataEnumReferenceField) {
        filterType = EFilterFieldType.nsgEnum;
      } else if (widget.filterItem.getField(widget.fieldName!) is NsgDataReferenceListField) {
        filterType = EFilterFieldType.nsgItemsList;
      } else {
        filterType = EFilterFieldType.unknown;
      }
    } else {
      filterType = EFilterFieldType.nsgItemSingle;
    }

    sc = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    if (filterType == EFilterFieldType.nsgItemsList || filterType == EFilterFieldType.unknown) {
      multipleSelect = widget.multipleSelect;
    }
    presentation = '';
    if (widget.defaultValue != null) {
      if (filterType == EFilterFieldType.nsgItem) {
        if (widget.defaultValue == NsgFilterValues.empty) {
          isSelected =
              (widget.filterItem.getField(widget.fieldName!) as NsgDataReferenceField).getReferent(widget.filterItem) !=
              widget.filterItem.getReferent(widget.fieldName!)!.getNewObject();
        } else {
          isSelected = widget.filterItem[widget.fieldName!] != (widget.defaultValue as NsgDataItem).id;
        }
        var item = (widget.filterItem.getField(widget.fieldName!) as NsgDataReferenceField).getReferent(widget.filterItem);
        presentation = widget.presentation != null ? widget.presentation!(item!) : item.toString();
      } else if (filterType == EFilterFieldType.nsgItemSingle) {
        if (widget.defaultValue == NsgFilterValues.empty) {
          isSelected = widget.filterItem != widget.filterItem.getNewObject();
        } else {
          isSelected = widget.filterItem.id != (widget.defaultValue as NsgDataItem).id;
        }
        presentation = widget.presentation != null ? widget.presentation!(widget.filterItem) : widget.filterItem.toString();
        if (!isSelected) presentation = "";
      } else if (filterType == EFilterFieldType.nsgItemsList) {
        dataItemsList = (widget.filterItem.getField(widget.fieldName!) as NsgDataReferenceListField).getReferent(widget.filterItem) ?? [];

        if (widget.defaultValue == NsgFilterValues.empty) {
          isSelected = dataItemsList!.isNotEmpty;
        } else {
          isSelected = dataItemsList != (widget.defaultValue as List<NsgDataItem>);
        }
        presentation = '';
        for (var element in dataItemsList!) {
          presentation += '${presentation != '' ? ', ' : ''}${widget.presentation != null ? widget.presentation!(element) : element.toString()}';
        }
      } else if (filterType == EFilterFieldType.nsgEnum) {
        //var fv = widget.filterItem[widget.fieldName!];
        isSelected = widget.filterItem[widget.fieldName!] != (widget.defaultValue as NsgEnum).value;
        presentation = (widget.filterItem.getField(widget.fieldName!) as NsgDataEnumReferenceField).getReferent(widget.filterItem).toString();
      }
    }

    return NsgMainChips(
      icon: NsgIcons.chevron_down,
      onTap: () => showFilterSheet(context),
      onReset: () {
        resetFilter();
        setState(() {});
      },
      isSelected: isSelected,
      maxWidth: widget.maxWidth,
      style: widget.style,
      title: presentation != '' ? presentation : widget.title,
    );
  }

  void _initializeSelectionController() {
    if (sc == null) {
      if (filterType == EFilterFieldType.nsgItem || filterType == EFilterFieldType.nsgItemsList || filterType == EFilterFieldType.nsgItemSingle) {
        sc = widget.filterItem.defaultController;
        if (sc == null) {
          if (filterType != EFilterFieldType.nsgItemSingle) {
            assert(widget.filterItem.getField(widget.fieldName!) is NsgDataBaseReferenceField, widget.fieldName!);
            sc = NsgDefaultController(
              dataType: (widget.filterItem.getField(widget.fieldName!) as NsgDataBaseReferenceField).referentElementType,
              controllerMode: NsgDataControllerMode(storageType: widget.filterItem.storageType),
            );
          } else {
            sc = NsgDefaultController(
              dataType: widget.filterItem.runtimeType,
              controllerMode: NsgDataControllerMode(storageType: widget.filterItem.storageType),
            );
          }
        }

        sc!.controllerFilter.isOpen = true;
        sc!.controllerFilter.controller = sc!;
        sc!.refreshData();
        sc!.regime = NsgControllerRegime.selection;
      }
    } else {
      sc!.controllerFilter.isOpen = true;
      sc!.controllerFilter.controller = sc!;
      sc!.refreshData();
      sc!.regime = NsgControllerRegime.selection;
    }
  }

  showFilterSheet(BuildContext context) async {
    TextEditingController textEditController = TextEditingController();
    dynamic backupItem;
    if (filterType == EFilterFieldType.nsgItem) {
      var value = (widget.filterItem.getField(widget.fieldName!) as NsgDataReferenceField).getReferent(widget.filterItem);
      if (value != null) backupItem = value.clone();
    } else if (filterType == EFilterFieldType.nsgItemSingle) {
      backupItem = widget.filterItem;
    } else if (filterType == EFilterFieldType.nsgItemsList) {
      var value = (widget.filterItem.getField(widget.fieldName!) as NsgDataReferenceListField).getReferent(widget.filterItem) ?? [];
      backupItem = value.toList();
    } else if (filterType == EFilterFieldType.nsgEnum) {
      var value = (widget.filterItem.getField(widget.fieldName!) as NsgDataEnumReferenceField).getReferent(widget.filterItem);
      if (value != null) backupItem = value;
    }
    _initializeSelectionController();
    if (widget.selectionForm.isNotEmpty) {
      sc!.onSelected = (item) {
        sc!.regime = NsgControllerRegime.view;
        sc!.onSelected = null;
        onItemTap(item, context);
      };
      Get.toNamed(widget.selectionForm);
    } else {
      await showModalBottomSheet(
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        constraints: BoxConstraints(maxWidth: nsgtheme.appMinWidth, maxHeight: MediaQuery.sizeOf(context).height - 40),
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Dialog(
              backgroundColor: ControlOptions.instance.colorBase,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              insetPadding: const EdgeInsets.all(0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: nsgtheme.colorBase.c100),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (multipleSelect)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(NsgIcons.chevron_left, size: 20, color: nsgtheme.colorTertiary),
                                    ),
                                  ),
                                Text(
                                  widget.title,
                                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 20 / 16, fontSize: nsgtheme.sizeL),
                                ),
                              ],
                            ),
                            if (widget.defaultValue != null) getClearButton(),
                          ],
                        ),
                      ),
                      if (filterType == EFilterFieldType.nsgItem || filterType == EFilterFieldType.nsgItemsList || filterType == EFilterFieldType.nsgItemSingle)
                        Padding(
                          padding: EdgeInsets.only(top: multipleSelect ? 12 : 20, right: 20, left: 20, bottom: multipleSelect ? 12 : 20),
                          child: SizedBox(
                            height: 44,
                            child: TextField(
                              controller: textEditController,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(NsgIcons.search, color: nsgtheme.colorTertiary, size: 20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  gapPadding: 8,
                                  borderSide: BorderSide(color: ControlOptions.instance.colorTertiary),
                                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  gapPadding: 8,
                                  borderSide: BorderSide(color: ControlOptions.instance.colorPrimary),
                                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                                ),
                                suffixIcon: IconButton(
                                  padding: const EdgeInsets.only(bottom: 0, right: 12, left: 8),
                                  onPressed: (() {
                                    textEditController.text = '';
                                    sc!.controllerFilter.searchString = textEditController.text;
                                    sc!.refreshData();
                                    //setState(() {});
                                  }),
                                  icon: Icon(NsgIcons.close, color: nsgtheme.colorTertiary, size: 20),
                                ),
                                // prefixIcon: Icon(Icons.search),
                                hintText: tran.search,
                                hintStyle: TextStyle(color: ControlOptions.instance.colorSecondary, fontWeight: FontWeight.w500),
                              ),
                              textAlignVertical: TextAlignVertical.bottom,
                              style: TextStyle(color: ControlOptions.instance.colorBase.c100),
                              onChanged: (val) {
                                sc!.controllerFilter.searchString = textEditController.text;

                                sc!.controllerFilter.refreshControllerWithDelay();
                              },
                            ),
                          ),
                        ),
                      if (multipleSelect)
                        Row(
                          children: [
                            Expanded(
                              child: sc!.obx(
                                (state) => SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: getHorItems()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SingleChildScrollView(
                            child:
                                (filterType == EFilterFieldType.nsgItem ||
                                        filterType == EFilterFieldType.nsgItemsList ||
                                        filterType == EFilterFieldType.nsgItemSingle) &&
                                    sc != null
                                ? sc!.obx(
                                    (state) => Column(
                                      children: getItemsWidgets(sc: sc, context: context),
                                    ),
                                  )
                                : Column(children: getItemsWidgets(context: context)),
                          ),
                        ),
                      ),
                      if (multipleSelect)
                        Row(
                          children: [
                            Expanded(
                              child: NsgButton(
                                text: tran.cancel,
                                onTap: () {
                                  if (backupItem != null) {
                                    widget.filterItem[widget.fieldName!] = backupItem;
                                  }

                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Expanded(
                              child: NsgButton(
                                text: tran.ok,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      setState(() {});
    }
  }

  List<Widget> getItemsWidgets({NsgBaseController? sc, required BuildContext context}) {
    List<Widget> list = [];
    if (filterType == EFilterFieldType.nsgItem || filterType == EFilterFieldType.nsgItemSingle) {
      var itemsList = sc!.dataItemList;
      for (var item in itemsList) {
        list.add(
          InkWell(
            onTap: () => onItemTap(item, context),
            child: widget.builder(
              context,
              item,
              filterType == EFilterFieldType.nsgItem ? widget.filterItem[widget.fieldName!] == item.id : widget.filterItem.id == item.id,
            ),
          ),
        );
      }
    } else if (filterType == EFilterFieldType.nsgEnum) {
      var enumItem = widget.filterItem.getReferent(widget.fieldName!) as NsgEnum;
      for (var item in enumItem.getAll()) {
        list.add(InkWell(onTap: () => onItemTap(item, context), child: widget.builder(context, item, widget.filterItem[widget.fieldName!] == item.value)));
      }
    } else if (filterType == EFilterFieldType.nsgItemsList) {
      var itemsList = sc!.dataItemList;
      for (var item in itemsList) {
        if (dataItemsList!.contains(item)) {
          list.add(InkWell(onTap: () => onItemTap(item, context), child: widget.builder(context, item, dataItemsList!.contains(item))));
        }
      }
      for (var item in itemsList) {
        if (!dataItemsList!.contains(item)) {
          list.add(InkWell(onTap: () => onItemTap(item, context), child: widget.builder(context, item, dataItemsList!.contains(item))));
        }
      }
    }

    return list;
  }

  void onItemTap(NsgDataItem item, BuildContext context) {
    if (widget.onItemTap != null) {
      widget.onItemTap!(item);
    } else {
      if (filterType == EFilterFieldType.nsgItem) {
        widget.filterItem.setFieldValue(widget.fieldName!, item.id);
        Navigator.pop(context);
      } else if (filterType == EFilterFieldType.nsgItemSingle) {
        widget.filterItem.copyFieldValues(item);
        Navigator.pop(context);
      } else if (filterType == EFilterFieldType.nsgEnum) {
        widget.filterItem.setFieldValue(widget.fieldName!, (item as NsgEnum).value);
        Navigator.pop(context);
      } else if (filterType == EFilterFieldType.nsgItemsList) {
        if (widget.multipleSelect) {
          if (dataItemsList!.contains(item)) {
            (widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>).remove(item);
          } else {
            (widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>).add(item);
          }
          if (widget.selectionForm.isNotEmpty) {
            //Для кастомной формы выбора пока не делаем множественный выбор
            Navigator.pop(context);
          } else {
            //В случае формы по умолчанию, не закрываем форму для возможности множественного выбора
            sc!.sendNotify();
          }
        } else {
          (widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>).clear();
          (widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>).add(item);
          //if (context.mounted) {
          //Заменил на Get.context, так как context.mounted был false
          //Пример для теста - организаторы - управление трансляциями - выбрать в фильтре организатора
          if (Get.context != null) {
            Navigator.pop(Get.context!);
          }
        }
      }
    }

    setState(() {});

    if (widget.onEditingComplete != null) {
      if (filterType == EFilterFieldType.nsgItemsList) {
        widget.onEditingComplete!((widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>));
      } else {
        widget.onEditingComplete!([item]);
      }
    }
  }

  void resetFilter() {
    dynamic value;
    if (widget.defaultValue != null) {
      if (filterType == EFilterFieldType.nsgItem) {
        if (widget.defaultValue is NsgFilterValues) {
          if (widget.defaultValue == NsgFilterValues.empty) {
            value = widget.filterItem.getReferent(widget.fieldName!)!.getNewObject();
            widget.filterItem.setFieldValue(widget.fieldName!, value as NsgDataItem);
          }
        } else {
          value = widget.defaultValue as NsgDataItem;
          widget.filterItem.setFieldValue(widget.fieldName!, value as NsgDataItem);
        }
      } else if (filterType == EFilterFieldType.nsgItemSingle) {
        if (widget.defaultValue is NsgFilterValues) {
          if (widget.defaultValue == NsgFilterValues.empty) {
            widget.filterItem.copyFieldValues(widget.filterItem.getNewObject());
          }
        } else {
          widget.filterItem.copyFieldValues(widget.defaultValue);
        }
        value = widget.filterItem;
      } else if (filterType == EFilterFieldType.nsgEnum) {
        value = (widget.defaultValue as NsgEnum).value;
        widget.filterItem.setFieldValue(widget.fieldName!, value as int);
      } else if (filterType == EFilterFieldType.nsgItemsList) {
        if (widget.defaultValue is NsgFilterValues) {
          if (widget.defaultValue == NsgFilterValues.empty) {
            value = [];
            widget.filterItem.setFieldValue(widget.fieldName!, value);
          }
        } else {
          value = widget.defaultValue as List<NsgDataItem>;
          widget.filterItem.setFieldValue(widget.fieldName!, value);
        }
      }
      if (widget.onEditingComplete != null) {
        if (filterType == EFilterFieldType.nsgItemsList) {
          widget.onEditingComplete!([...value]);
        } else if (filterType == EFilterFieldType.nsgEnum) {
          widget.onEditingComplete!([widget.defaultValue]);
        } else {
          widget.onEditingComplete!([value]);
        }
      }
    }
  }

  Widget getClearButton() {
    return NsgTextButton(
      text: tran.cancel,
      color: nsgtheme.colorError,
      onTap: () {
        resetFilter();

        setState(() {});

        Navigator.pop(context);
      },
    );
  }

  List<Widget> getHorItems() {
    List<Widget> list = [];

    list.add(const Padding(padding: EdgeInsets.only(right: 20)));

    dataItemsList = (widget.filterItem.getField(widget.fieldName!) as NsgDataReferenceListField).getReferent(widget.filterItem) ?? [];

    for (var element in dataItemsList!) {
      list.add(
        HorChipsItem(
          item: element,
          maxWidth: 200,
          style: widget.style,
          onItemDelete: (item) {
            if (dataItemsList!.contains(item)) {
              (widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>).remove(item);
              if (widget.onEditingComplete != null) {
                widget.onEditingComplete!(widget.filterItem.getFieldValue(widget.fieldName!) as List<NsgDataItem>);
              }
            }
            sc!.sendNotify();
          },
        ),
      );
    }

    list.add(const Padding(padding: EdgeInsets.only(left: 4)));

    return list;
  }
}

class HorChipsItem extends StatelessWidget {
  const HorChipsItem({super.key, this.style = const NsgFilterChipsStyle(), this.maxWidth, this.onItemDelete, required this.item});

  final NsgFilterChipsStyle style;
  final double? maxWidth;
  final NsgDataItem item;
  final void Function(NsgDataItem item)? onItemDelete;

  @override
  Widget build(BuildContext context) {
    var buildStyle = style.style();
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : BoxConstraints(maxWidth: double.infinity),
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: buildStyle.unactiveColor, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              item.toString(),
              style: TextStyle(color: buildStyle.unactiveColorText, fontWeight: FontWeight.w400, fontSize: nsgtheme.sizeS, overflow: TextOverflow.ellipsis),
            ),
          ),
          const Padding(padding: EdgeInsets.only(left: 8)),
          InkWell(
            onTap: () {
              if (onItemDelete != null) {
                onItemDelete!(item);
              }
            },
            child: Icon(NsgIcons.close, size: 16, color: buildStyle.unactiveColorText),
          ),
        ],
      ),
    );
  }
}

class NsgFilterChipsStyle {
  const NsgFilterChipsStyle({
    this.activeColor,
    this.unactiveColor,
    this.activeColorText,
    this.unactiveColorText,
    this.activeBorderColor,
    this.unactiveBorderColor,
  });
  final Color? activeColor;
  final Color? unactiveColor;
  final Color? activeColorText;
  final Color? unactiveColorText;
  final Color? activeBorderColor;
  final Color? unactiveBorderColor;

  NsgFilterChipsStyleMain style() {
    return NsgFilterChipsStyleMain(
      activeColor: activeColor ?? nsgtheme.colorBase.c100,
      unactiveColor: unactiveColor ?? nsgtheme.colorSecondary,
      activeColorText: activeColorText ?? nsgtheme.colorBase,
      unactiveColorText: unactiveColorText ?? nsgtheme.colorTertiary,
      activeBorderColor: activeBorderColor ?? Colors.transparent,
      unactiveBorderColor: unactiveBorderColor ?? Colors.transparent,
    );
  }
}

class NsgFilterChipsStyleMain {
  const NsgFilterChipsStyleMain({
    required this.activeColor,
    required this.unactiveColor,
    required this.activeColorText,
    required this.unactiveColorText,
    required this.activeBorderColor,
    required this.unactiveBorderColor,
  });
  final Color activeColor;
  final Color unactiveColor;
  final Color activeColorText;
  final Color unactiveColorText;
  final Color activeBorderColor;
  final Color unactiveBorderColor;
}

enum EFilterFieldType { nsgItem, nsgEnum, nsgItemsList, unknown, nsgItemSingle }

enum NsgFilterValues { empty }

class NsgMainChips extends StatelessWidget {
  const NsgMainChips({
    super.key,
    this.maxWidth,
    this.count,
    this.icon,
    this.onTap,
    this.onReset,
    this.title = 'title',
    this.isSelected = false,
    this.style = const NsgFilterChipsStyle(),
    this.margin = const EdgeInsets.only(right: 10, bottom: 10, top: 0),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.height,
  });
  final void Function()? onTap;
  final void Function()? onReset;
  final double? maxWidth;
  final NsgFilterChipsStyle style;
  final bool isSelected;
  final String title;
  final IconData? icon;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final int? count;
  final double? height;

  @override
  Widget build(BuildContext context) {
    var buildStyle = style.style();
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: isSelected ? buildStyle.activeBorderColor : buildStyle.unactiveBorderColor),
        color: isSelected ? buildStyle.activeColor : buildStyle.unactiveColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicWidth(
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : BoxConstraints(maxWidth: double.infinity),
                  padding: isSelected && icon != null ? padding.subtract(EdgeInsets.only(right: padding.right)) : padding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? buildStyle.activeColorText : buildStyle.unactiveColorText,
                            fontWeight: FontWeight.w400,
                            fontSize: nsgtheme.sizeS,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      //if (icon != null) Icon(icon, size: 16, color: isSelected ? buildStyle.activeColorText : buildStyle.unactiveColorText),
                      if (icon != null && !isSelected)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(icon, size: 14, color: buildStyle.unactiveColorText),
                        ),
                      if (count != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isSelected ? buildStyle.activeColorText : buildStyle.unactiveColorText,
                              fontWeight: FontWeight.w400,
                              fontSize: nsgtheme.sizeS,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (icon != null && isSelected)
              InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: onReset,
                child: Container(
                  padding: padding,
                  height: height,
                  child: Icon(Icons.close, size: 14, color: buildStyle.activeColorText),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
