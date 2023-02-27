import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgFilePickerObject {
  //TODO: сделать признак нового объекта и задавать id всегда при его создании
  String id;
  String filePath;
  Image? image;
  List<int>? fileContent;
  File? file;
  String? fileType = '';
  String description = '';
  bool isNew = true;
  bool markToDelete = false;
  NsgFilePickerObject({this.image, this.fileType, this.file, required this.description, this.id = '', this.filePath = '', required this.isNew}) {
    if (isNew) {
      id = Guid.newGuid();
    }
  }
}
