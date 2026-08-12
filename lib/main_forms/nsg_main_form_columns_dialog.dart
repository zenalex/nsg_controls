import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/main_forms/nsg_main_form_controller.dart';
import 'package:nsg_controls/nsg_button.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_icons.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgMainFormColumnsDialog {
  NsgMainFormColumnsDialog({required this.controller});

  final NsgMainFormController controller;

  Future<void> show(BuildContext context) async {
    final model = _ColumnsDialogModel(controller: controller);
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ColumnsMaterialDialog(model: model),
      );
    } finally {
      model.dispose();
    }
  }
}

class _ColumnsDialogModel extends ChangeNotifier {
  _ColumnsDialogModel({required this.controller}) {
    controller.fieldsList.fields.forEach((key, field) {
      if (controller.serviceFields.contains(key) || controller.serviceFields.contains(field.name)) return;
      if (field is NsgDataReferenceListField) return;
      fields.add(MapEntry(key, field));
      visible[field] = controller.isColumnVisible(field);
    });
    fields.sort((a, b) => controller.columnsConfig.getItemOrder(a.value).nsgCompareTo(controller.columnsConfig.getItemOrder(b.value), zeroValueLast: true));
    _normalizeLayout();
    searchController.addListener(notifyListeners);
  }

  final NsgMainFormController controller;
  final List<MapEntry<String, NsgDataField>> fields = [];
  final Map<NsgDataField, bool> visible = {};
  final TextEditingController searchController = TextEditingController();

  String titleOf(String key, NsgDataField field) {
    if (field.presentation.isNotEmpty) return field.presentation;
    final norm = field.name.replaceAll(' ', '_').toLowerCase();
    if (norm.isNotEmpty) return norm;
    return key.replaceAll(' ', '_').toLowerCase();
  }

  String get searchQuery => searchController.text.trim().toLowerCase();

  bool get canReorder => searchQuery.isEmpty;

  List<MapEntry<String, NsgDataField>> get displayedFields {
    final q = searchQuery;
    if (q.isEmpty) return fields;
    return fields.where((e) => titleOf(e.key, e.value).toLowerCase().contains(q)).toList();
  }

  List<MapEntry<String, NsgDataField>> get _enabledFields => fields.where((e) => visible[e.value] == true).toList();

  /// Порядковый номер среди включённых колонок. Для выключенных — 0 (в UI «-»).
  int orderOf(NsgDataField field) {
    if (visible[field] != true) return 0;
    final index = _enabledFields.indexWhere((e) => e.value == field);
    return index < 0 ? 0 : index + 1;
  }

  void _normalizeLayout() {
    final enabled = fields.where((e) => visible[e.value] == true).toList();
    final disabled = fields.where((e) => visible[e.value] != true).toList();
    fields
      ..clear()
      ..addAll(enabled)
      ..addAll(disabled);
  }

  void setVisible(NsgDataField field, bool value) {
    visible[field] = value;
    _normalizeLayout();
    notifyListeners();
  }

  void setAllDisplayed(bool value) {
    for (final entry in displayedFields) {
      visible[entry.value] = value;
    }
    _normalizeLayout();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (!canReorder) return;
    final item = fields.removeAt(oldIndex);
    fields.insert(newIndex, item);
    _normalizeLayout();
    notifyListeners();
  }

  void moveToOrder(NsgDataField field, int order) {
    if (visible[field] != true) return;
    final enabled = _enabledFields;
    final disabled = fields.where((e) => visible[e.value] != true).toList();
    final currentIndex = enabled.indexWhere((e) => e.value == field);
    if (currentIndex < 0 || enabled.isEmpty) return;
    final target = order.clamp(1, enabled.length) - 1;
    final item = enabled.removeAt(currentIndex);
    enabled.insert(target, item);
    fields
      ..clear()
      ..addAll(enabled)
      ..addAll(disabled);
    notifyListeners();
  }

  Future<void> confirm() async {
    var order = 1;
    for (final entry in fields) {
      final field = entry.value;
      final isVisible = visible[field] ?? true;
      controller.columnsConfig.setItemVisible(field, isVisible);
      controller.columnsConfig.setItemOrder(field, isVisible ? order++ : 0);
    }
    await controller.saveColumnsConfig();
    controller.applyColumnsConfigToTable();
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    searchController.dispose();
    super.dispose();
  }
}

class _ColumnsMaterialDialog extends StatelessWidget {
  const _ColumnsMaterialDialog({required this.model});

  final _ColumnsDialogModel model;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final radius = BorderRadius.circular(nsgtheme.borderRadius);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      backgroundColor: nsgtheme.colorMainBack,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: SizedBox(
        width: size.width,
        height: size.height * 0.92,
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final canReorder = model.canReorder;
            final items = model.displayedFields;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tranControls.column_order_and_disable,
                              style: TextStyle(color: nsgtheme.colorText, fontSize: nsgtheme.sizeL, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              canReorder ? tranControls.drag_columns_to_reorder : 'Перетаскивание недоступно при поиске. Измените номер вручную.',
                              style: TextStyle(color: nsgtheme.colorTertiary, fontSize: nsgtheme.sizeS),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(NsgIcons.close, color: nsgtheme.colorText),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: model.searchController,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: nsgtheme.colorText, fontSize: nsgtheme.sizeM),
                      cursorColor: nsgtheme.colorPrimary,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: nsgtheme.colorSecondary,
                        isDense: true,
                        hintText: 'Поиск колонки…',
                        hintStyle: TextStyle(color: nsgtheme.colorTertiary, fontSize: nsgtheme.sizeM),
                        prefixIcon: Icon(NsgIcons.search, color: nsgtheme.colorTertiary, size: 20),
                        suffixIcon: model.searchQuery.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () => model.searchController.clear(),
                                icon: Icon(NsgIcons.close, color: nsgtheme.colorTertiary, size: 18),
                              ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: nsgtheme.colorTertiary.withValues(alpha: 0.45)),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Builder(
                    builder: (context) {
                      final allEnabled = model.displayedFields.isNotEmpty && model.displayedFields.every((e) => model.visible[e.value] == true);
                      return OutlinedButton.icon(
                        onPressed: model.displayedFields.isEmpty ? null : () => model.setAllDisplayed(!allEnabled),
                        icon: Icon(
                          allEnabled ? Icons.hide_source : Icons.checklist,
                          size: 18,
                          color: allEnabled ? nsgtheme.colorTertiary : nsgtheme.colorPrimary,
                        ),
                        label: Text(
                          allEnabled ? 'Выключить все' : 'Включить все',
                          style: TextStyle(color: allEnabled ? nsgtheme.colorTertiary : nsgtheme.colorPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: (allEnabled ? nsgtheme.colorTertiary : nsgtheme.colorPrimary).withValues(alpha: 0.5)),
                          foregroundColor: allEnabled ? nsgtheme.colorTertiary : nsgtheme.colorPrimary,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: canReorder
                      ? ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          itemCount: items.length,
                          buildDefaultDragHandles: false,
                          onReorderItem: model.reorder,
                          proxyDecorator: (child, index, animation) => child,
                          itemBuilder: (context, index) {
                            final entry = items[index];
                            final field = entry.value;
                            final isVisible = model.visible[field] ?? true;
                            return _ColumnToggleTile(
                              key: ValueKey(field.name),
                              index: index,
                              order: model.orderOf(field),
                              title: model.titleOf(entry.key, field),
                              value: isVisible,
                              canReorder: true,
                              onChanged: (value) => model.setVisible(field, value),
                              onOrderSubmitted: isVisible ? (order) => model.moveToOrder(field, order) : null,
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final entry = items[index];
                            final field = entry.value;
                            final isVisible = model.visible[field] ?? true;
                            return _ColumnToggleTile(
                              key: ValueKey(field.name),
                              index: index,
                              order: model.orderOf(field),
                              title: model.titleOf(entry.key, field),
                              value: isVisible,
                              canReorder: false,
                              onChanged: (value) => model.setVisible(field, value),
                              onOrderSubmitted: isVisible ? (order) => model.moveToOrder(field, order) : null,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: NsgButton(
                          onPressed: () => Navigator.of(context).pop(),
                          text: 'Отмена',
                          backColor: nsgtheme.colorTertiary,
                          color: nsgtheme.colorPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NsgButton(
                          onPressed: () async {
                            await model.confirm();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          text: 'Сохранить',
                          backColor: nsgtheme.colorPrimary,
                          color: nsgtheme.colorPrimaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ColumnToggleTile extends StatelessWidget {
  const _ColumnToggleTile({
    super.key,
    required this.index,
    required this.order,
    required this.title,
    required this.value,
    required this.canReorder,
    required this.onChanged,
    required this.onOrderSubmitted,
  });

  final int index;
  final int order;
  final String title;
  final bool value;
  final bool canReorder;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int>? onOrderSubmitted;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(nsgtheme.borderRadius);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () => onChanged(!value),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: nsgtheme.colorSecondary,
              borderRadius: radius,
              border: Border.all(color: value ? nsgtheme.colorPrimary.withValues(alpha: 0.45) : nsgtheme.colorTertiary.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                if (canReorder && value)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(NsgIcons.reorder, size: 18, color: nsgtheme.colorTertiary),
                  )
                else
                  Icon(NsgIcons.reorder, size: 18, color: nsgtheme.colorTertiary.withValues(alpha: 0.35)),
                const SizedBox(width: 10),
                _OrderBadge(order: order, enabled: value, editable: !canReorder && value && onOrderSubmitted != null, onSubmitted: onOrderSubmitted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: nsgtheme.colorText, fontSize: nsgtheme.sizeM, fontWeight: value ? FontWeight.w600 : FontWeight.w400),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(value: value, activeThumbColor: nsgtheme.colorPrimary, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({required this.order, required this.enabled, required this.editable, required this.onSubmitted});

  final int order;
  final bool enabled;
  final bool editable;
  final ValueChanged<int>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final bg = nsgtheme.colorPrimary.withValues(alpha: enabled ? 0.15 : 0.06);
    final fg = enabled ? nsgtheme.colorPrimary : nsgtheme.colorTertiary;

    if (!editable || order <= 0) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(
          order > 0 ? '$order' : '—',
          style: TextStyle(color: fg, fontSize: nsgtheme.sizeS, fontWeight: FontWeight.w700),
        ),
      );
    }

    return _EditableOrderField(order: order, background: bg, foreground: fg, onSubmitted: onSubmitted);
  }
}

class _EditableOrderField extends StatefulWidget {
  const _EditableOrderField({required this.order, required this.background, required this.foreground, required this.onSubmitted});

  final int order;
  final Color background;
  final Color foreground;
  final ValueChanged<int>? onSubmitted;

  @override
  State<_EditableOrderField> createState() => _EditableOrderFieldState();
}

class _EditableOrderFieldState extends State<_EditableOrderField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.order}');
  }

  @override
  void didUpdateWidget(covariant _EditableOrderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order && _controller.text != '${widget.order}') {
      _controller.text = '${widget.order}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null) widget.onSubmitted?.call(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 32,
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(color: widget.foreground, fontSize: nsgtheme.sizeS, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          filled: true,
          fillColor: widget.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: nsgtheme.colorPrimary, width: 1),
          ),
        ),
        onSubmitted: (_) => _submit(),
        onEditingComplete: _submit,
        onTapOutside: (_) => _submit(),
      ),
    );
  }
}
