import 'package:nsg_data/helpers/nsg_data_format.dart';

import 'nsg_control_options.dart';

extension NsgDate on DateTime {
  bool get isEmpty {
    return isBefore(DateTime(1955)) || isAfter(DateTime(8000));
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  String format(String? format) {
    return NsgDateFormat.dateFormat(this, format: format ?? ControlOptions.instance.dateformat);
  }
}
