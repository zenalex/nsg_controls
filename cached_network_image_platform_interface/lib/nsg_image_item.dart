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

  double get size {
    switch (this) {
      case small:
        return 150;
      case large:
        return 1000;
      case medium:
        return 300;
    }
  }
}
