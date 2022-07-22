import 'dart:io';

import 'package:flutter/material.dart';

class NsgImagePickerObject {
  Image? image;
  File? file;
  String? fileType = '';
  String description = '';
  NsgImagePickerObject({this.image, this.fileType, this.file, required this.description});
}
