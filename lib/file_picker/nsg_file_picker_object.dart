import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgFilePickerObject {
  String id;
  String filePath;
  Image? image;
  List<int>? fileContent;
  File? file;
  NsgFilePickerObjectType fileType = NsgFilePickerObjectType.unknown;
  String description = '';
  bool isNew = true;
  bool markToDelete = false;
  NsgFilePickerObject(
      {this.image,
      this.fileType = NsgFilePickerObjectType.unknown,
      this.file,
      required this.description,
      this.id = '',
      this.filePath = '',
      required this.isNew}) {
    if (isNew) {
      id = Guid.newGuid();
    }
  }
}

enum NsgFilePickerObjectType { unknown, image, pdf, video, other }
