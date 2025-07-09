import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nsg_data/nsg_data.dart';

import 'nsg_file_picker_provider.dart';

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
  ESourceType eSourceType;
  NsgFilePickerObject({
    this.image,
    this.fileType = NsgFilePickerObjectType.unknown,
    this.file,
    this.description = '',
    this.id = '',
    this.filePath = '',
    required this.isNew,
    this.fileContent,
    this.eSourceType = ESourceType.auto,
  }) {
    if (isNew) {
      id = Guid.newGuid();
    }
  }
}

enum NsgFilePickerObjectType { unknown, image, pdf, csv, video, other }
