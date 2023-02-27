import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  //Функция вызывается при тапе на иконке картинки в тексте. Должно вызывыать открытие окна просмотра или обработки файла/излображения
  void tapFile(NsgFilePickerObject? fileObject) {
    if (fileObject == null) return;
    var curIndex = 0;
    for (var e in images) {
      if (e.id == fileObject.id) {
        break;
      }
      curIndex++;
    }
    if (curIndex >= images.length) {
      curIndex = 0;
    }

    Get.dialog(
        NsgPopUp(
            onCancel: () {
              Get.back();
            },
            onConfirm: () {
              Get.back();
            },
            margin: const EdgeInsets.all(15),
            title: "Просмотр изображений",
            width: Get.width,
            height: Get.height,
            getContent: () => [
                  NsgGallery(
                    imagesList: images,
                    currentPage: curIndex,
                  )
                ]),
        barrierDismissible: true);
  }
}
