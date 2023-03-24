import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgFilePickerObject {
  String id;
  String filePath;
  Image? image;
  Uint8List? fileContent;
  File? file;
  NsgFilePickerObjectType fileType = NsgFilePickerObjectType.unknown;
  String description;
  bool isNew;
  bool markToDelete = false;
  NsgFilePickerObject(
      {this.image,
      this.fileType = NsgFilePickerObjectType.unknown,
      this.file,
      this.description = '',
      this.id = '',
      this.filePath = '',
      required this.isNew}) {
    if (isNew) {
      id = Guid.newGuid();
    }
  }
}

enum NsgFilePickerObjectType { unknown, image, pdf, csv, video, other }
