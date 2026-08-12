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

  /// Устанавливает значение фильтра извне и синхронизирует поля ввода.
  void setValue(dynamic value) {
    if (value == null) {
      clearValue();
      return;
    }

    if (value is NsgDataItem) {
      setFilterItemValue(value);
      return;
    }

    clearFilterItemValue();

    if (isBool) {
      _filterValue = value == true || value == 1 || value.toString().trim().toLowerCase() == 'true';
      return;
    }

    if (isDateTime) {
      if (value is DateTime) {
        _filterValue = value;
      } else if (value is String) {
        _filterValue = DateTime.tryParse(value) ?? field.defaultValue;
      } else {
        _filterValue = value;
      }
      return;
    }

    _filterValue = value;
    if (isDouble && value is num) {
      textC.text = value.toString().replaceAll('.', ',');
    } else {
      textC.text = value.toString();
    }
  }

  /// Сбрасывает значение фильтра и очищает связанные поля ввода.
  void clearValue() {
    clearFilterItemValue();
    _filterValue = isBool ? false : null;
    textC.clear();
  }

  bool toggleFilterEnable({bool Function()? isFilterVisible}) {
    isFilterVisible = isFilterVisible ?? () => false;
    final wasVisible = isFilterVisible();
    isEnable = !isEnable;
    return wasVisible != isFilterVisible();
  }

  bool setFilterEnable(bool value, {bool Function()? isFilterVisible}) {
    isFilterVisible = isFilterVisible ?? () => false;
    final wasVisible = isFilterVisible();
    isEnable = value;
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
    Widget child;
    TextAlign textAlign = TextAlign.left;
    AlignmentGeometry alignment = Alignment.centerLeft;

    if (isDateTime) {
      child = _buildDateTimeInput(context, onChanged);
    } else if (isInt) {
      textAlign = TextAlign.right;
      alignment = Alignment.centerRight;
      child = _buildNumberInput(onChanged, allowDecimal: false, textAlign: textAlign);
    } else if (isDouble) {
      textAlign = TextAlign.right;
      alignment = Alignment.centerRight;
      child = _buildNumberInput(onChanged, allowDecimal: true, textAlign: textAlign);
    } else if (isBool) {
      alignment = Alignment.center;
      child = _buildBoolInput(onChanged);
    } else if (isEqualityOperator && isEnum) {
      child = _buildEnumInput(context, onChanged);
    } else if (isEqualityOperator && isReference) {
      child = _buildReferenceInput(context, onChanged);
    } else {
      textAlign = TextAlign.center;
      alignment = Alignment.center;
      child = _buildTextInput(onChanged, textAlign: textAlign);
    }

    return _wrapFilterField(child: child, alignment: alignment);
  }

  TextStyle get _valueTextStyle =>
      TextStyle(fontSize: nsgtheme.sizeS, color: isEnable ? nsgtheme.colorBase.c0 : nsgtheme.colorBase.c0.withValues(alpha: 0.45), height: 1.2);

  TextStyle get _hintTextStyle => TextStyle(fontSize: nsgtheme.sizeS, color: nsgtheme.colorBase.c0.withValues(alpha: 0.35), height: 1.2);

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: _hintTextStyle,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      filled: false,
    );
  }

  Widget _wrapFilterField({required Widget child, AlignmentGeometry alignment = Alignment.centerLeft}) {
    final borderColor = isEnable ? nsgtheme.colorPrimary.withValues(alpha: 0.45) : nsgtheme.colorBase.c0.withValues(alpha: 0.15);
    final fillColor = isEnable ? nsgtheme.colorBase.c100.withValues(alpha: 0.65) : nsgtheme.colorBase.c100.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnable ? 1 : 0.7,
        child: Container(
          height: 32,
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextInput(VoidCallback onChanged, {TextAlign textAlign = TextAlign.left}) {
    return TextFormField(
      controller: textC,
      enabled: isEnable,
      textAlign: textAlign,
      textAlignVertical: TextAlignVertical.top,
      style: _valueTextStyle,
      decoration: _inputDecoration(hint: '…'),
      onChanged: (_) => onChanged(),
    );
  }

  Widget _buildNumberInput(VoidCallback onChanged, {required bool allowDecimal, TextAlign textAlign = TextAlign.right}) {
    return TextFormField(
      controller: textC,
      enabled: isEnable,
      textAlign: textAlign,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [if (allowDecimal) FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')) else FilteringTextInputFormatter.digitsOnly],
      style: _valueTextStyle,
      decoration: _inputDecoration(hint: '0'),
      onChanged: (_) => onChanged(),
    );
  }

  Widget _buildBoolInput(VoidCallback onChanged) {
    final value = (_filterValue as bool?) ?? false;
    return Center(
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        onPressed: !isEnable
            ? null
            : () {
                _filterValue = !value;
                onChanged();
              },
        icon: Icon(value ? Icons.check_circle : Icons.cancel, color: value ? Colors.green : Colors.red, size: 22),
      ),
    );
  }

  Widget _buildDateTimeInput(BuildContext context, VoidCallback onChanged) {
    final date = (_filterValue as DateTime?) ?? DateTime.now();
    final hasValue = _filterValue is DateTime && !NsgDateHelper.isEmptyDate(_filterValue as DateTime);
    final label = hasValue ? NsgDateFormat.dateFormat(date, format: 'dd.MM.yyyy HH:mm', locale: Localizations.localeOf(context).languageCode) : '';
    return InkWell(
      borderRadius: BorderRadius.circular(6),
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.isEmpty ? 'дд.мм.гггг' : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: label.isEmpty ? _hintTextStyle : _valueTextStyle,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.calendar_month, size: 16, color: nsgtheme.colorPrimary),
        ],
      ),
    );
  }

  Widget _buildEnumInput(BuildContext context, VoidCallback onChanged) {
    final values = NsgEnum.fromValue(columnType, 0).getAll();
    final selected = _filterItemValue is NsgEnum ? _filterItemValue as NsgEnum : (_filterValue is NsgEnum ? _filterValue as NsgEnum : null);
    return PopupMenuButton<NsgEnum>(
      enabled: isEnable,
      tooltip: selected?.name ?? '',
      padding: EdgeInsets.zero,
      initialValue: selected,
      onSelected: (value) {
        setFilterItemValue(value);
        onChanged();
      },
      itemBuilder: (context) => values.map((e) => PopupMenuItem<NsgEnum>(value: e, child: Text(e.name))).toList(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selected?.name ?? 'Выберите…',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected == null ? _hintTextStyle : _valueTextStyle,
            ),
          ),
          Icon(Icons.arrow_drop_down, size: 20, color: nsgtheme.colorPrimary),
        ],
      ),
    );
  }

  Widget _buildReferenceInput(BuildContext context, VoidCallback onChanged) {
    final text = _filterItemValue?.toString() ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: !isEnable ? null : () => _openReferenceSelection(context, onChanged),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.isEmpty ? 'Выберите…' : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.isEmpty ? _hintTextStyle : _valueTextStyle,
            ),
          ),
          Icon(Icons.arrow_drop_down, size: 20, color: nsgtheme.colorPrimary),
        ],
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
