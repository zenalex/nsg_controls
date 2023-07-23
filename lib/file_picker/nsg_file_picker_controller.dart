import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nsg_controls/file_picker/nsg_file_picker_interface.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
import 'package:nsg_data/nsg_data.dart';

import '../widgets/nsg_dialog.dart';

class NsgFilePickerController<T extends NsgDataItem> extends NsgDataController<T> with NsgFilePickerInterface {
  var _files = <NsgFilePickerObject>[];
  @override
  List<NsgFilePickerObject> get files => _files;
  @override
  set files(List<NsgFilePickerObject> value) {
    _files = value;
  }

  String descriptionFieldName = '';

  @override
  Future<NsgDataItem> fileObjectToDataItem(NsgFilePickerObject fileObject, File imageFile) async {
    throw Exception('fileObjectToDataItem is not implemented');
  }

  @override
  Future<NsgFilePickerObject> dataItemToFileObject(NsgDataItem dataItem) async {
    throw Exception('dataItemToFileObject is not implemented');
  }

  @override
  Future<bool> saveImages(BuildContext context) async {
    var progress = NsgProgressDialog(textDialog: 'Сохранение фото');
    progress.show(context);
    var ids = <String>[];

    try {
      for (var img in files) {
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
      NsgErrorWidget.showError(context, ex);
      rethrow;
    }
    return true;
  }

  @override
  Future refreshData({List<NsgUpdateKey>? keys, NsgDataRequestParams? filter}) async {
    await super.refreshData(keys: keys, filter: filter);
    files.clear();

    for (var element in items) {
      files.add(await dataItemToFileObject(element));
    }
    return;
  }

  ///Функция вызывается при тапе на иконке картинки в тексте. Должно вызывыать открытие окна просмотра или обработки файла/излображения
  @override
  void tapFile(BuildContext context, NsgFilePickerObject? fileObject) {
    if (fileObject == null) return;
    var curIndex = 0;
    for (var e in files) {
      if (e.id == fileObject.id) {
        break;
      }
      curIndex++;
    }
    if (curIndex >= files.length) {
      curIndex = 0;
    }

    NsgDialog().show(
        context: context,
        child: NsgPopUp(
            onCancel: () {
              NsgNavigator.instance.back(context);
            },
            onConfirm: () {
              NsgNavigator.instance.back(context);
            },
            margin: const EdgeInsets.all(15),
            title: "Просмотр изображений",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            getContent: () => [
                  NsgGallery(
                    imagesList: files,
                    currentPage: curIndex,
                  )
                ]));
  }
}
