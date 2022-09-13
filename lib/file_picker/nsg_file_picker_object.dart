import 'dart:io';

import 'package:flutter/material.dart';

class NsgFilePickerObject {
  String id;
  String filePath;
  Image? image;
  File? file;
  String? fileType = '';
  String description = '';
  NsgFilePickerObject({this.image, this.fileType, this.file, required this.description, this.id = '', this.filePath = ''});
}
