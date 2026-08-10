import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/formfields/nsg_date_picker.dart';
import 'package:nsg_controls/formfields/nsg_input_type.dart';
import 'package:nsg_controls/main_forms/nsg_comparision_operator_icons.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:nsg_controls/nsg_selection.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgFieldFilter {
  NsgFieldFilter({required this.field}) {
    if (field is NsgDataReferenceField) {
      columnType = (field as NsgDataReferenceField).referentElementType;
    } else if (field is NsgDataEnumReferenceField) {
      columnType = (field as NsgDataEnumReferenceField).referentType;
    } else if (field is NsgDataReferenceListField) {
      columnType = (field as NsgDataReferenceListField).referentElementType;
    } else {
      columnType = field.defaultValue.runtimeType;
    }
    if (isBool) {
      _filterValue = false;
      operator = NsgComparisonOperator.equal;
    }
  }

  final NsgDataField field;

  TextEditingController textC = TextEditingController();
  Type columnType = String;
  bool isEnable = false;
  NsgComparisonOperator operator = NsgComparisonOperator.contain;
  NsgDataItem? _filterItemValue;
  dynamic _filterValue;

  bool get isBool => field is NsgDataBoolField || columnType == bool;
  bool get isInt => field is NsgDataIntField || columnType == int;
  bool get isDouble => field is NsgDataDoubleField || columnType == double;
  bool get isDateTime => field is NsgDataDateField || columnType == DateTime;
  bool get isEnum => field is NsgDataEnumReferenceField;
  bool get isReference => field is NsgDataReferenceField;
  bool get isString => field is NsgDataStringField || columnType == String;

  /// UI выбора typed-значения (bool / enum / reference) при equal-подобных операторах.
  bool get isEqualityOperator =>
      operator == NsgComparisonOperator.equal ||
      operator == NsgComparisonOperator.notEqual ||
      operator == NsgComparisonOperator.equalOrEmpty ||
      operator == NsgComparisonOperator.notEqualOrEmpty;

  void setFilterItemValue(NsgDataItem value) {
    _filterItemValue = value;
    _filterValue = value;
  }

  void clearFilterItemValue() {
    _filterItemValue = null;
    if (_filterValue is NsgDataItem) {
      _filterValue = null;
    }
  }

  bool toggleFilterEnable({bool Function()? isFilterVisible}) {
    isFilterVisible = isFilterVisible ?? () => false;
    final wasVisible = isFilterVisible();
    isEnable = !isEnable;
    return wasVisible != isFilterVisible();
  }

  void toggleOperator() {
    if (isBool) {
      operator = NsgComparisonOperator.equal;
      return;
    }
    operator = operator.next;
  }

  NsgCompare get compare => NsgCompare()..add(name: field.name, value: filterValue, comparisonOperator: operator);

  /// Значение фильтра в зависимости от [operator] и [columnType].
  dynamic get filterValue {
    if (isDateTime) return _filterValue ?? field.defaultValue;
    if (isInt || isDouble) return _typedFromText;
    if (isBool) return _filterValue ?? false;
    if ((isEnum || isReference) && isEqualityOperator) return _filterItemValue ?? _filterValue;

    switch (operator.value) {
      case 8: // beginWith
      case 9: // endWith
      case 10: // contain
      case 11: // containWords
      case 12: // notContainWords
      case 18: // notBeginWith
      case 19: // notEndWith
      case 20: // notContain
        return textC.text;

      case 7: // inList
      case 17: // notInList
        return _filterItemValue ?? _filterValue ?? _typedFromText;

      case 13: // inGroup
      case 14: // groupsFrom
      case 15: // notGroupsFrom
      case 21: // notInGroup
      case 23: // typeIn
      case 24: // typeEqual
      case 25: // typeNotEqual
      case 26: // compare
        return _filterItemValue ?? _filterValue;

      default:
        return _filterItemValue ?? _filterValue ?? _typedFromText;
    }
  }

  /// Парсинг [textC.text] в [columnType].
  dynamic get _typedFromText {
    final text = textC.text;
    if (columnType == String || isString) return text;
    if (isInt) return int.tryParse(text) ?? field.defaultValue;
    if (isDouble) {
      return double.tryParse(text.replaceAll(',', '.')) ?? field.defaultValue;
    }
    if (isBool) {
      final lower = text.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
      return field.defaultValue;
    }
    if (isDateTime) {
      return DateTime.tryParse(text) ?? field.defaultValue;
    }
    return text;
  }

  /// Виджет ввода значения фильтра по типу поля и оператору.
  Widget buildFilterInput({required BuildContext context, required VoidCallback onChanged}) {
    if (isDateTime) {
      return _buildDateTimeInput(context, onChanged);
    }
    if (isInt) {
      return _buildNumberInput(onChanged, allowDecimal: false);
    }
    if (isDouble) {
      return _buildNumberInput(onChanged, allowDecimal: true);
    }
    if (isBool) {
      return _buildBoolInput(onChanged);
    }
    if (isEqualityOperator) {
      if (isEnum) return _buildEnumInput(context, onChanged);
      if (isReference) return _buildReferenceInput(context, onChanged);
    }
    return TextFormField(
      controller: textC,
      enabled: isEnable,
      style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorBase.c0),
      decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 4)),
      onChanged: (_) => onChanged(),
    );
  }

  Widget _buildNumberInput(VoidCallback onChanged, {required bool allowDecimal}) {
    return TextFormField(
      controller: textC,
      enabled: isEnable,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [if (allowDecimal) FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')) else FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorBase.c0),
      decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 4)),
      onChanged: (_) => onChanged(),
    );
  }

  Widget _buildBoolInput(VoidCallback onChanged) {
    final value = (_filterValue as bool?) ?? false;
    return Center(
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: !isEnable
            ? null
            : () {
                _filterValue = !value;
                onChanged();
              },
        icon: Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildDateTimeInput(BuildContext context, VoidCallback onChanged) {
    final date = (_filterValue as DateTime?) ?? DateTime.now();
    final hasValue = _filterValue is DateTime && !NsgDateHelper.isEmptyDate(_filterValue as DateTime);
    final label = hasValue ? NsgDateFormat.dateFormat(date, format: 'dd.MM.yyyy HH:mm', locale: Localizations.localeOf(context).languageCode) : '';
    return InkWell(
      onTap: !isEnable
          ? null
          : () async {
              final initial = hasValue ? date : DateTime.now();
              NsgDatePicker(initialTime: initial, simple: true, margin: EdgeInsets.zero, onClose: (_) {}).showPopup(context, initial, (pickedDate) async {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(hasValue ? date : pickedDate));
                if (time == null) {
                  _filterValue = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                } else {
                  _filterValue = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, time.hour, time.minute);
                }
                onChanged();
              });
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorBase.c0),
              ),
            ),
            Icon(Icons.calendar_month, size: 18, color: nsgtheme.colorBase.c0),
          ],
        ),
      ),
    );
  }

  Widget _buildEnumInput(BuildContext context, VoidCallback onChanged) {
    final values = NsgEnum.fromValue(columnType, 0).getAll();
    final selected = _filterItemValue is NsgEnum ? _filterItemValue as NsgEnum : (_filterValue is NsgEnum ? _filterValue as NsgEnum : null);
    return PopupMenuButton<NsgEnum>(
      enabled: isEnable,
      tooltip: selected?.name ?? '',
      initialValue: selected,
      onSelected: (value) {
        setFilterItemValue(value);
        onChanged();
      },
      itemBuilder: (context) => values.map((e) => PopupMenuItem<NsgEnum>(value: e, child: Text(e.name))).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorBase.c0),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: nsgtheme.colorBase.c0),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInput(BuildContext context, VoidCallback onChanged) {
    return InkWell(
      onTap: !isEnable ? null : () => _openReferenceSelection(context, onChanged),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _filterItemValue?.toString() ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorBase.c0),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: nsgtheme.colorBase.c0),
          ],
        ),
      ),
    );
  }

  void _openReferenceSelection(BuildContext context, VoidCallback onChanged) {
    final sc = resolveSelectionController();
    if (sc == null) return;
    sc.refreshData();
    final form = NsgSelection(inputType: NsgInputType.reference, controller: sc, selectedElement: _filterItemValue);
    form.selectFromArray(field.presentation.isNotEmpty ? field.presentation : field.name, (item) {
      setFilterItemValue(item);
      onChanged();
    }, context: context);
  }

  @override
  String toString() {
    return "FieldFilter<${columnType.toString()}>(${operator.name})";
  }

  NsgBaseController? resolveSelectionController() {
    NsgBaseController? sc;
    if (NsgDataClient.client.isRegistered(columnType)) {
      var di = NsgDataClient.client.getNewObject(columnType);
      sc = di.defaultController;
    }
    sc ??= NsgDefaultController(
      dataType: columnType,
      controllerMode: NsgDataControllerMode(storageType: NsgDataClient.client.getNewObject(columnType).storageType),
    );
    sc.selectedItem = _filterItemValue;
    return sc;
  }
}
