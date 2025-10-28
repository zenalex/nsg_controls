import 'package:nsg_data/nsg_data.dart';

abstract class NsgImageItem extends NsgDataItem {
  String globalFilePath(ImageSize size);

  /// Файл
  List<int> get fileBytesWriteOnly;
}

enum ImageSize {
  small,
  medium,
  large;
}
