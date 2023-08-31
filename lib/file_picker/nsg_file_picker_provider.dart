import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart' as file;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nsg_controls/file_picker/nsg_file_picker_object.dart';
import 'package:nsg_controls/nsg_control_options.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';

class NsgFilePickerProvider {
  static List<String> globalAllowedImageFormats = const ['jpeg', 'jpg', 'gif', 'png', 'bmp'];
  static List<String> globalAllowedVideoFormats = const ['mp4'];
  static List<String> globalAllowedFileFormats = const ['doc', 'docx', 'rtf', 'xls', 'xlsx', 'pdf', 'rtf', 'csv'];

  static NsgFilePickerObjectType getFileTypeByExtension(String ext) {
    if (globalAllowedImageFormats.contains(ext)) {
      return NsgFilePickerObjectType.image;
    }
    if (globalAllowedVideoFormats.contains(ext)) {
      return NsgFilePickerObjectType.video;
    }
    if (globalAllowedFileFormats.contains(ext)) {
      if (ext == 'pdf') {
        return NsgFilePickerObjectType.pdf;
      } else {
        return NsgFilePickerObjectType.other;
      }
    }

    return NsgFilePickerObjectType.unknown;
  }

  static NsgFilePickerObjectType getFileTypeByPath(String path) {
    var ext = extension(path).replaceAll('.', '').toLowerCase();
    return getFileTypeByExtension(ext);
  }

  final List<String> allowedImageFormats;
  final List<String> allowedVideoFormats;
  final List<String> allowedFileFormats;

  ///Максимальная ширина картинки. При превышении, картинка будет пережата.
  final double imageMaxWidth;

  ///Максимальная высота картинки. При превышении, картинка будет пережата
  final double imageMaxHeight;

  ///Качество сжатия картинки в jpeg (100 - макс)
  final int imageQuality;

  ///Максимально разрешенный размер файла для выбора. При превышении размера файла, его выбор будет запрещен
  final double fileMaxSize;
  final int maxFilesCount;

  final NsgFilePickerObjectType mobileSelectionType;

  final String savePrefix;

  final bool ignoreMaxSize;

  const NsgFilePickerProvider(
      {this.allowedImageFormats = const ['jpeg', 'jpg', 'gif', 'png', 'bmp'],
      this.allowedVideoFormats = const ['mp4'],
      this.allowedFileFormats = const ['doc', 'docx', 'rtf', 'xls', 'xlsx', 'pdf', 'rtf'],
      this.imageMaxWidth = 1440.0,
      this.imageMaxHeight = 1440.0,
      this.imageQuality = 70,
      this.fileMaxSize = 1000000.0,
      this.ignoreMaxSize = false,
      this.savePrefix = 'NsgFile',
      this.maxFilesCount = 0,
      this.mobileSelectionType = NsgFilePickerObjectType.image});

  Future<List<NsgFilePickerObject>> autoSelectPicker({bool oneFile = false, ESourceType eSourceType = ESourceType.auto, BuildContext? mainContext}) async {
    if (kIsWeb) {
      return galleryImage(oneFile: oneFile);
    } else if (GetPlatform.isWindows || GetPlatform.isMacOS) {
      return pickFile(oneFile: oneFile);
    } else {
      if (eSourceType == ESourceType.auto && mainContext != null) {
        var type = await showSourceTypeDialog(mainContext);
        if (type != null) {
          eSourceType = type;
        } else {
          return [];
        }
      } else {
        eSourceType = ESourceType.gallery;
      }
      switch (eSourceType) {
        case ESourceType.camera:
          return cameraImage(oneFile: oneFile);
        case ESourceType.gallery:
          return galleryImage(oneFile: oneFile);
        case ESourceType.files:
          return pickFile(oneFile: oneFile);
        default:
          return pickFile(oneFile: oneFile);
      }
    }
  }

  Future<List<NsgFilePickerObject>> galleryImage({bool oneFile = false}) async {
    List<NsgFilePickerObject> objectsList = [];
    String? error;
    if (kIsWeb) {
      /* ----------------------------------------------- Галерея в браузере ----------------------------------------------- */
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: [...allowedFileFormats, ...allowedImageFormats, ...allowedVideoFormats], allowMultiple: !oneFile);
      if (result != null) {
        for (var element in result.files) {
          Uint8List? fileBytes = element.bytes;
          String fileName = element.name;
          var fileType = getFileTypeByPath(fileName);
          if (fileType == NsgFilePickerObjectType.image) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                image: Image.memory(fileBytes!),
                fileContent: fileBytes,
                description: basenameWithoutExtension(fileName),
                fileType: fileType,
                filePath: fileName));
          } else if (fileType != NsgFilePickerObjectType.unknown) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                file: File(fileBytes.toString()),
                fileContent: fileBytes,
                image: null,
                description: basenameWithoutExtension(fileName),
                fileType: fileType,
                filePath: fileName));
          } else {
            error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          }
        }
      }
    } else if (GetPlatform.isWindows || GetPlatform.isLinux) {
      /* --------------------------------------------- Галерея Windows и Linux -------------------------------------------- */
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: [...allowedFileFormats, ...allowedImageFormats, ...allowedVideoFormats], allowMultiple: !oneFile);

      if (result != null) {
        for (var element in result.files) {
          var fileType = getFileTypeByPath(element.name);
          Uint8List? fileContent;
          if (element.path != null) {
            fileContent = await File(element.path!).readAsBytes();
          }

          if (!GetPlatform.isLinux) {
            if (fileType == NsgFilePickerObjectType.image) {
              objectsList.add(NsgFilePickerObject(
                  isNew: true,
                  image: Image.file(File(element.name.toString())),
                  description: basenameWithoutExtension(element.name.toString()),
                  fileType: fileType,
                  fileContent: fileContent,
                  filePath: element.path ?? ''));
            } else if (fileType != NsgFilePickerObjectType.unknown) {
              objectsList.add(NsgFilePickerObject(
                  isNew: true,
                  file: File(element.name),
                  image: null,
                  fileContent: fileContent,
                  description: basenameWithoutExtension(element.name),
                  fileType: fileType,
                  filePath: element.path ?? ''));
            } else {
              error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
            }
          }
          if (GetPlatform.isLinux) {
            if (fileType == NsgFilePickerObjectType.image) {
              objectsList.add(NsgFilePickerObject(
                  isNew: true,
                  image: Image.file(File(element.path.toString())),
                  description: basenameWithoutExtension(element.path.toString()),
                  fileType: fileType,
                  fileContent: fileContent,
                  filePath: element.path.toString()));
            } else if (fileType != NsgFilePickerObjectType.unknown) {
              objectsList.add(NsgFilePickerObject(
                  isNew: true,
                  file: File(element.name),
                  image: null,
                  fileContent: fileContent,
                  description: basenameWithoutExtension(element.name),
                  fileType: fileType,
                  filePath: element.path ?? ''));
            } else {
              error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
            }
          }
        }
      }

      /* ---------------------------------------------- Галерея на мобильных ---------------------------------------------- */
    } else if (GetPlatform.isMacOS) {
      /* ------------------------------------------- Галерея MacOS (файл пикер) ------------------------------------------- */
      var jpgsTypeGroup = const file.XTypeGroup(
        label: 'JPEGs',
        extensions: <String>['jpg', 'jpeg'],
      );
      var pngTypeGroup = const file.XTypeGroup(
        label: 'PNGs',
        extensions: <String>['png'],
      );
      var pdfTypeGroup = const file.XTypeGroup(
        label: 'PDFs',
        extensions: <String>['pdf'],
      );
      List<XFile> result = await file.openFiles(acceptedTypeGroups: <file.XTypeGroup>[jpgsTypeGroup, pngTypeGroup, pdfTypeGroup]);

      if (result.isNotEmpty) {
        /// Если стоит ограничение на 1 файл
        if (oneFile) {
          result = [result[0]];
          objectsList.clear();
        }
        for (var element in result) {
          var fileType = getFileTypeByPath(element.path);
          var fileContent = await element.readAsBytes();
          if (fileType == NsgFilePickerObjectType.image) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                image: Image.file(File(element.path)),
                description: basenameWithoutExtension(element.path),
                fileType: fileType,
                fileContent: fileContent,
                filePath: element.path));
          } else if (fileType != NsgFilePickerObjectType.unknown) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                file: File(element.path),
                image: null,
                fileContent: fileContent,
                description: basenameWithoutExtension(element.path),
                fileType: fileType,
                filePath: element.path));
          } else {
            error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          }
        }
      }
    } else {
      /* ---------------------------------------------- Галерея на мобильных ---------------------------------------------- */
      List<XFile> result = [];

      if (mobileSelectionType == NsgFilePickerObjectType.image) {
        if (oneFile) {
          var image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: imageQuality,
            maxWidth: imageMaxWidth,
            maxHeight: imageMaxHeight,
          );
          if (image != null) {
            result = [image];
          }
        } else {
          result = await ImagePicker().pickMultiImage(
            imageQuality: imageQuality,
            maxWidth: imageMaxWidth,
            maxHeight: imageMaxHeight,
          );
        }
      } else if (mobileSelectionType == NsgFilePickerObjectType.video) {
        var video = await ImagePicker().pickVideo(source: ImageSource.gallery);
        if (video != null) {
          result = [video];
        }
      }

      /// Если стоит ограничение на 1 файл
      if (oneFile) {
        if (result.isNotEmpty) result = [result[0]];
        objectsList.clear();
      }
      for (var element in result) {
        var fileType = getFileTypeByExtension(extension(element.path).replaceAll('.', ''));

        if (fileType == NsgFilePickerObjectType.image) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              image: Image.file(File(element.path)),
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              fileContent: await element.readAsBytes(),
              filePath: element.path));
        } else if (fileType != NsgFilePickerObjectType.unknown) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              file: File(element.path),
              image: null,
              fileContent: await element.readAsBytes(),
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              filePath: element.path));
        } else {
          error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
        }
      }
    }

    if (error == null) {
      return (objectsList);
    } else {
      throw Exception(error);
    }
  }

  /// Pick an image
  Future<List<NsgFilePickerObject>> pickFile({bool oneFile = false}) async {
    String? error;
    List<NsgFilePickerObject> objectsList = [];
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [...allowedFileFormats, ...allowedImageFormats, ...allowedVideoFormats], allowMultiple: !oneFile);
    if (result != null) {
      for (var element in result.files) {
        var fileType = getFileTypeByPath(element.name);

        if (kIsWeb) {
          var file = File(element.bytes.toString());

          if (!ignoreMaxSize && (await file.length()) > fileMaxSize) {
            error = 'Превышен максимальный размер файла ${(fileMaxSize / 1024).toString()} кБайт';
          }
          if (fileType == NsgFilePickerObjectType.image) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                image: Image.network(element.path.toString()),
                description: basenameWithoutExtension(element.name),
                fileType: fileType,
                filePath: ''));
          } else if (fileType != NsgFilePickerObjectType.unknown) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                file: File(element.bytes!.toString()),
                image: null,
                description: basenameWithoutExtension(element.bytes.toString()),
                fileType: fileType,
                filePath: ''));
          } else {
            error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          }
        } else if (GetPlatform.isWindows) {
          if (element.path != null) {
            var file = File(element.path!);

            if (!ignoreMaxSize && (await file.length()) > fileMaxSize) {
              error = 'Превышен максимальный размер файла ${(fileMaxSize / 1024).toString()} кБайт';
            }
            if (fileType == NsgFilePickerObjectType.image) {
              objectsList.add(NsgFilePickerObject(
                  isNew: true,
                  file: file,
                  fileContent: await file.readAsBytes(),
                  image: Image.file(file),
                  description: basenameWithoutExtension(element.name.toString()),
                  fileType: fileType,
                  filePath: element.path ?? ''));
            } else if (fileType != NsgFilePickerObjectType.unknown) {
              objectsList.add(NsgFilePickerObject(
                  isNew: true,
                  file: file,
                  image: null,
                  description: basenameWithoutExtension(element.name),
                  fileType: fileType,
                  fileContent: await file.readAsBytes(),
                  filePath: element.path ?? ''));
            } else {
              error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
            }
          } else {
            error = '${element.path} - ошибка пути';
          }
        }
        if (GetPlatform.isLinux || GetPlatform.isMacOS || GetPlatform.isAndroid || GetPlatform.isIOS) {
          Uint8List? fileContent;
          if (element.path != null) {
            fileContent = await File(element.path!).readAsBytes();
          }
          if (fileType == NsgFilePickerObjectType.image) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                image: Image.file(File(element.path.toString())),
                description: basenameWithoutExtension(element.name.toString()),
                fileType: fileType,
                fileContent: fileContent,
                filePath: element.path ?? ''));
          } else if (fileType != NsgFilePickerObjectType.unknown) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                file: File(element.name),
                image: null,
                fileContent: fileContent,
                description: basenameWithoutExtension(element.name),
                fileType: fileType,
                filePath: element.path ?? ''));
          } else {
            error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          }
        }
      }
    }

    if (error == null) {
      return (objectsList);
    } else {
      throw Exception(error);
    }
  }

  /// Capture a photo
  Future<List<NsgFilePickerObject>> cameraImage({bool oneFile = false}) async {
    List<NsgFilePickerObject> objectsList = [];
    String? error;

    List<XFile> result = [];

    if (mobileSelectionType == NsgFilePickerObjectType.image) {
      var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: imageMaxWidth,
        maxHeight: imageMaxHeight,
      );
      if (image != null) {
        result = [image];
      }
    } else if (mobileSelectionType == NsgFilePickerObjectType.video) {
      var video = await ImagePicker().pickVideo(source: ImageSource.camera);
      //TODO: Не работает пикер видео!
      if (video != null) {
        result = [video];
      }
    }

    /// Если стоит ограничение на 1 файл
    if (oneFile) {
      if (result.isNotEmpty) result = [result[0]];
      objectsList.clear();
    }
    for (var element in result) {
      var fileType = getFileTypeByExtension(extension(element.path).replaceAll('.', ''));

      if (fileType == NsgFilePickerObjectType.image) {
        objectsList.add(NsgFilePickerObject(
            isNew: true,
            image: Image.file(File(element.path)),
            description: basenameWithoutExtension(element.path),
            fileType: fileType,
            fileContent: await element.readAsBytes(),
            filePath: element.path));
      } else if (fileType != NsgFilePickerObjectType.unknown) {
        objectsList.add(NsgFilePickerObject(
            isNew: true,
            file: File(element.path),
            image: null,
            fileContent: await element.readAsBytes(),
            description: basenameWithoutExtension(element.path),
            fileType: fileType,
            filePath: element.path));
      } else {
        error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
      }
    }

    if (error == null) {
      return (objectsList);
    } else {
      throw Exception(error);
    }
  }

  Future saveFile(NsgFilePickerObject fileObject, {String? customFileName, String? customPrefix}) async {
    FileType fileType = FileType.any;
    switch (fileObject.fileType) {
      case NsgFilePickerObjectType.image:
        fileType = FileType.image;
        break;
      case NsgFilePickerObjectType.video:
        fileType = FileType.video;
        break;
      case NsgFilePickerObjectType.pdf:
        fileType = FileType.any;
        break;
      default:
        fileType = FileType.any;
    }
    if (!kIsWeb) {
      if (!GetPlatform.isAndroid && !GetPlatform.isIOS) {
        var fileName = await FilePicker.platform
            .saveFile(dialogTitle: 'Сохранить файл', type: fileType, allowedExtensions: [extension(fileObject.filePath).replaceAll('.', '')]);
        if (fileName == null) return;
        var ext = extension(fileName);
        if (ext.isEmpty) {
          fileName += extension(fileObject.filePath);
        }

        dio.Dio io = dio.Dio();
        await io.download(fileObject.filePath, fileName, onReceiveProgress: (receivedBytes, totalBytes) {});
        //fileName = '/Users/zenalex/Downloads/ttt.docx';
        fileName = Uri.encodeFull(fileName);
        await launchUrlString('file:$fileName');
      } else {
        String fileName = customFileName ?? '${customPrefix ?? savePrefix}${extension(fileObject.filePath)}';
        Directory appDir;
        if (Platform.isIOS) {
          appDir = await getApplicationDocumentsDirectory();
        } else {
          appDir = Directory('/storage/emulated/0/Download');
        }

        String filePath = '${appDir.path}/$fileName';
        dio.Dio io = dio.Dio();
        await io.download(fileObject.filePath, filePath, onReceiveProgress: (receivedBytes, totalBytes) {});
      }
    }
    if (kIsWeb) {
      try {
        final response = await http.get(Uri.parse(fileObject.filePath));

        if (response.statusCode == 200) {
          final blob = html.Blob([response.bodyBytes]);

          final url = html.Url.createObjectUrlFromBlob(blob);

          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", customFileName ?? '${customPrefix ?? savePrefix}${extension(fileObject.filePath)}');
          anchor.click();

          html.Url.revokeObjectUrl(url);
        } else {
          Get.snackbar('failed download', 'Failed to download file try again');
        }
      } catch (e) {
        Get.snackbar('error', 'Error while downloading file: $e');
      }
    }
  }

  Future<ESourceType?> showSourceTypeDialog(BuildContext context) async {
    ESourceType? eSourceType = ESourceType.gallery;
    if (GetPlatform.isMobile) {
      eSourceType = await showModalBottomSheet<ESourceType>(
          context: context,
          builder: (context) {
            return Card(
                color: nsgtheme.colorBase.c20,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, ESourceType.gallery);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: ControlOptions.instance.colorBase),
                            child: Icon(Icons.image_outlined, size: 50, color: ControlOptions.instance.colorPrimary)),
                      ),
                      const Padding(padding: EdgeInsets.only(right: 10)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, ESourceType.camera);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: ControlOptions.instance.colorBase),
                            child: Icon(Icons.photo_camera, size: 50, color: ControlOptions.instance.colorPrimary)),
                      ),
                      const Padding(padding: EdgeInsets.only(right: 10)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, ESourceType.files);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: ControlOptions.instance.colorBase),
                            child: Icon(Icons.file_open_rounded, size: 50, color: ControlOptions.instance.colorPrimary)),
                      ),
                    ],
                  ),
                ));
          });
    }
    return eSourceType;
  }
}

enum ESourceType { gallery, camera, files, auto }
