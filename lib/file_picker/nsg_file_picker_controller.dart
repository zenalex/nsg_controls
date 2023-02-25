import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgFilePickerController<T extends NsgDataItem> extends NsgDataController<T> {
  var images = <NsgFilePickerObject>[];
  String descriptionFieldName = '';

  Future<T> fileObjectToDataItem(NsgFilePickerObject fileObject, File imageFile) async {
    throw Exception('fileObjectToDataItem is not implemented');
  }

  Future<NsgFilePickerObject> dataItemToFileObject(T dataItem) async {
    throw Exception('dataItemToFileObject is not implemented');
  }

  Future<bool> saveImages() async {
    var progress = NsgProgressDialog(textDialog: 'Сохранение фото');
    progress.show();
    var ids = <String>[];
    try {
      for (var img in images) {
        if (img.image == null) continue;
        if (img.isNew && img.id.isNotEmpty) {
          File imageFile = kIsWeb ? File.fromUri(Uri(path: img.filePath)) : File(img.filePath);

          var pic = await fileObjectToDataItem(img, imageFile);
          await pic.post();
        }
        ids.add(img.id);
      }
      //Удаляем "лишние" картинки
      var itemsToDelete = items.where((e) => !ids.contains(e.id)).toList();
      if (itemsToDelete.isNotEmpty) {
        deleteItems(itemsToDelete);
      }
      progress.hide();
      // Get.back();
    } on Exception catch (ex) {
      progress.hide();
      NsgErrorWidget.showError(ex);
      rethrow;
    }
    return true;
  }

  @override
  Future refreshData({List<NsgUpdateKey>? keys}) async {
    await super.refreshData(keys: keys);
    images.clear();

    for (var element in items) {
      images.add(await dataItemToFileObject(element));
    }
    return;
  }
}
