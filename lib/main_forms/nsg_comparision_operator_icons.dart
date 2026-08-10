import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_comparison_operator.dart';

extension NsgComparisonOperatorIcons on NsgComparisonOperator {
  /// Операторы для выбора в UI (без [NsgComparisonOperator.none]).
  static List<NsgComparisonOperator> get selectable => NsgComparisonOperator.allValues.values.where((op) => op.value != 0).toList();

  /// Следующий оператор по кругу, без [NsgComparisonOperator.none] (value == 0).
  NsgComparisonOperator get next {
    final maxValue = NsgComparisonOperator.compare.value;
    final nextValue = (value >= maxValue || value < 1) ? 1 : value + 1;
    return NsgComparisonOperator.allValues[nextValue]!;
  }

  /// Иконка оператора сравнения для отображения типа фильтра в UI.
  IconData get icon {
    switch (value) {
      case 0: // none
        return Icons.filter_alt_off;
      case 1: // equal
        return Icons.drag_handle;
      case 2: // notEqual
        return Icons.difference;
      case 3: // greater
        return Icons.keyboard_arrow_up;
      case 4: // greaterOrEqual
        return Icons.keyboard_double_arrow_up;
      case 5: // less
        return Icons.keyboard_arrow_down;
      case 6: // lessOrEqual
        return Icons.keyboard_double_arrow_down;
      case 7: // inList
        return Icons.list_alt;
      case 8: // beginWith
        return Icons.start;
      case 9: // endWith
        return Icons.keyboard_tab;
      case 10: // contain
        return Icons.search;
      case 11: // containWords
        return Icons.abc;
      case 12: // notContainWords
        return Icons.speaker_notes_off;
      case 13: // inGroup
        return Icons.group;
      case 14: // groupsFrom
        return Icons.account_tree;
      case 15: // notGroupsFrom
        return Icons.account_tree_outlined;
      case 16: // equalOrEmpty
        return Icons.check_box_outline_blank;
      case 17: // notInList
        return Icons.playlist_remove;
      case 18: // notBeginWith
        return Icons.hide_source;
      case 19: // notEndWith
        return Icons.mobiledata_off;
      case 20: // notContain
        return Icons.search_off;
      case 21: // notInGroup
        return Icons.group_off;
      case 22: // notEqualOrEmpty
        return Icons.indeterminate_check_box;
      case 23: // typeIn
        return Icons.category;
      case 24: // typeEqual
        return Icons.category_outlined;
      case 25: // typeNotEqual
        return Icons.layers_clear;
      case 26: // compare
        return Icons.compare_arrows;
      default:
        return Icons.filter_alt;
    }
  }
}
