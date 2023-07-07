import 'dart:io';

import 'package:nsg_data/nsg_data.dart';

import 'nsg_file_picker_object.dart';

mixin NsgFilePickerInterface {
  Future<NsgDataItem> fileObjectToDataItem(NsgFilePickerObject fileObject, File imageFile);

  Future<NsgFilePickerObject> dataItemToFileObject(NsgDataItem dataItem);
  Future<bool> saveImages();
  void tapFile(NsgFilePickerObject? fileObject);

  List<NsgFilePickerObject> get files;
  set files(List<NsgFilePickerObject> value);
}
