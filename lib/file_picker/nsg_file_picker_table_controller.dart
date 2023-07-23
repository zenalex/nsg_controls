import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nsg_controls/file_picker/nsg_file_picker_interface.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_controls/widgets/nsg_dialog.dart';
import 'package:nsg_controls/widgets/nsg_error_widget.dart';
import 'package:nsg_data/nsg_data.dart';

///Контроллер, для работы с картинками, хранящимися в табличной части объекта
class NsgFilePickerTableController<T extends NsgDataItem> extends NsgDataTableController<T> with NsgFilePickerInterface {
  var _files = <NsgFilePickerObject>[];
  @override
  List<NsgFilePickerObject> get files => _files;
  @override
  set files(List<NsgFilePickerObject> value) {
    _files = value;
  }

  String descriptionFieldName = '';

  NsgFilePickerTableController({required super.masterController, required super.tableFieldName});

  @override
  Future<NsgDataItem> fileObjectToDataItem(NsgFilePickerObject fileObject, File? imageFile) async {
    throw Exception('fileObjectToDataItem is not implemented');
  }

  @override
  Future<NsgFilePickerObject> dataItemToFileObject(NsgDataItem dataItem) async {
    throw Exception('dataItemToFileObject is not implemented');
  }

  @override
  Future<bool> saveImages(BuildContext context) async {
    var progress = NsgProgressDialog(textDialog: 'Сохранение файлов');
    progress.show(context);
    var ids = <String>[];
    var table = NsgDataTable(owner: masterController!.selectedItem!, fieldName: tableFieldName);
    try {
      for (var img in files) {
        ids.add(img.id);
        if (img.isNew && img.id.isNotEmpty && (img.fileContent != null || img.filePath.isNotEmpty)) {
          //TODO: убрать imageFile
          File? imageFile = kIsWeb || img.filePath.isEmpty ? null : File(img.filePath);

          var pic = await fileObjectToDataItem(img, imageFile);
          if (!table.rows.any((e) => e.id == pic.id)) {
            table.rows.add(pic);
          }
        }
      }
      //Удаляем "лишние" картинки
      //TODO: УДАЛЕНИЕ ФАЙЛОВ!!!!!
      var itemsToDelete = table.rows.where((se) => !ids.contains(se.id)).toList();
      for (var row in itemsToDelete) {
        if (row.newTableLogic) {
          row.docState = NsgDataItemDocState.deleted;
        } else {
          table.rows.remove(row);
        }
      }
      progress.hide();
      // Get.back();
    } catch (ex) {
      progress.hide();
      NsgErrorWidget.showError(context, ex as Exception);
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
            title: "Просмотр файлов",
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
