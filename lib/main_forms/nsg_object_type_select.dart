import 'package:flutter/material.dart';
import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_light_app_bar.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgObjectTypeSelect extends StatelessWidget {
  const NsgObjectTypeSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return Material(
      child: BodyWrap(
        child: Column(
          children: [
            NsgLightAppBar(
              title: 'Object Type Select',
              leftIcons: [NsgLigthAppBarIcon(icon: NsgIcons.close, onTap: () => NsgNavigator.pop())],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: SizedBox(
                height: 44,
                child: TextFormField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(color: nsgtheme.colorText, fontSize: nsgtheme.sizeM),
                  cursorColor: nsgtheme.colorPrimary,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: nsgtheme.colorSecondary,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    hintText: 'Search',
                    hintStyle: TextStyle(color: nsgtheme.colorTertiary, fontWeight: FontWeight.w500, fontSize: nsgtheme.sizeM),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(NsgIcons.search, color: nsgtheme.colorTertiary, size: 20),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    suffixIcon: ListenableBuilder(
                      listenable: searchController,
                      builder: (context, _) {
                        if (searchController.text.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          padding: const EdgeInsets.only(right: 8),
                          onPressed: () => searchController.clear(),
                          icon: Icon(NsgIcons.close, color: nsgtheme.colorTertiary, size: 18),
                        );
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: nsgtheme.colorTertiary.withValues(alpha: 0.55)),
                      borderRadius: BorderRadius.circular(nsgtheme.borderRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: nsgtheme.colorPrimary, width: 1.5),
                      borderRadius: BorderRadius.circular(nsgtheme.borderRadius),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: ListenableBuilder(
                  listenable: searchController,
                  builder: (context, w) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var item in NsgDataClient.client.registeredDataItems.where(
                          (i) => (i is! NsgEnum) && i.typeName.toLowerCase().contains(searchController.text.toLowerCase()),
                        ))
                          _NsgDataItemListItem(item: item, onTap: (item) => NsgMainFormController.openItemsListDefaultPage(item.runtimeType)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NsgDataItemListItem extends StatelessWidget {
  const _NsgDataItemListItem({required this.item, this.onTap});

  final NsgDataItem item;
  final void Function(NsgDataItem item)? onTap;

  static const _defaultIcons = <IconData>[
    NsgIcons.doc,
    NsgIcons.folder,
    NsgIcons.group,
    NsgIcons.person,
    NsgIcons.settings,
    NsgIcons.select_list,
    NsgIcons.building,
    NsgIcons.calendar,
  ];

  Color get _color {
    final palette = <Color>[
      nsgtheme.colorPrimary,
      nsgtheme.colorBlue,
      nsgtheme.colorNormal,
      nsgtheme.colorWarning,
      nsgtheme.colorError,
      nsgtheme.colorConfirmed,
      nsgtheme.colorGrey,
    ];
    return palette[item.typeName.hashCode.abs() % palette.length];
  }

  IconData get _icon => _defaultIcons[item.typeName.hashCode.abs() % _defaultIcons.length];

  String get _title => item.typeName;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final radius = BorderRadius.circular(nsgtheme.borderRadius);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap?.call(item),
        borderRadius: radius,
        child: Ink(
          width: 148,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: nsgtheme.colorSecondary,
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.35)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(_icon, size: 24, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                _title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: nsgtheme.colorText, fontSize: nsgtheme.sizeS, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
