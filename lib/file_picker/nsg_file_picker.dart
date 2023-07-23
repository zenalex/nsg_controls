import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player_win/video_player_win.dart';
import '../nsg_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_selector/file_selector.dart' as file;
import 'package:dio/dio.dart' as dio;

import '../widgets/nsg_dialog.dart';
import '../widgets/nsg_snackbar.dart';

/// Пикер и загрузчик изображений и файлов заданных форматов
class NsgFilePicker extends StatefulWidget {
  final bool showAsWidget;
  final List<String> allowedImageFormats;
  final List<String> allowedVideoFormats;
  final List<String> allowedFileFormats;
  final bool useFilePicker;

  ///Максимальная ширина картинки. При превышении, картинка будет пережата.
  final double imageMaxWidth;

  ///Максимальная высота картинки. При превышении, картинка будет пережата
  final double imageMaxHeight;

  ///Качество сжатия картинки в jpeg (100 - макс)
  final int imageQuality;

  ///Максимально разрешенный размер файла для выбора. При превышении размера файла, его выбор будет запрещен
  final double fileMaxSize;

  ///Фунция, вызываемая при подтверждении сохранения картинок пользователем
  final Function(List<NsgFilePickerObject>) callback;

  ///Максисально допустимое количество присоединяемых файлов
  ///Например, можно использовать для задания картинки профиля, установив ограничение равное 1
  ///По умолчанию равно нулю - не ограничено
  final int maxFilesCount;
  final String textChooseFile;

  ///Сохраненные объекты (картинки и документы)
  final List<NsgFilePickerObject> objectsList;

  final bool oneFile;
  final bool skipInterface;

  final bool needCrop;
  final bool fromGallery;

  NsgFilePicker(
      {Key? key,
      this.needCrop = false,
      this.allowedImageFormats = const ['jpeg', 'jpg', 'gif', 'png', 'bmp'],
      this.allowedVideoFormats = const ['mp4'],
      this.allowedFileFormats = const ['doc', 'docx', 'rtf', 'xls', 'xlsx', 'pdf', 'rtf'],
      this.showAsWidget = false,
      this.useFilePicker = false,
      this.imageMaxWidth = 1440.0,
      this.imageMaxHeight = 1440.0,
      this.imageQuality = 70,
      this.fileMaxSize = 1000000.0,
      this.maxFilesCount = 0,
      required this.callback,
      required this.objectsList,
      this.textChooseFile = 'Добавить фото',
      this.oneFile = false,
      this.fromGallery = true,
      this.skipInterface = false})
      : super(key: key) {
    _resisterComponents();
  }

  static bool _isComponentsRegistered = false;
  static _resisterComponents() {
    if (!_isComponentsRegistered) {
      if (!kIsWeb && Platform.isWindows) {
        WindowsVideoPlayer.registerWith();
      }
      _isComponentsRegistered = true;
    }
  }

  // popup() {
  //   Get.dialog(
  //       NsgPopUp(
  //         title: 'Загрузите фотографию',
  //         contentTop: SizedBox(width: 300, height: 300, child: this),
  //       ),
  //       barrierDismissible: true);
  // }

  @override
  State<NsgFilePicker> createState() => _NsgFilePickerState();

  static List<String> globalAllowedImageFormats = const ['jpeg', 'jpg', 'gif', 'png', 'bmp'];
  static List<String> globalAllowedVideoFormats = const ['mp4'];
  static List<String> globalAllowedFileFormats = const ['doc', 'docx', 'rtf', 'xls', 'xlsx', 'pdf', 'rtf', 'csv'];

  static NsgFilePickerObjectType getFileType(String ext) {
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
}

class _NsgFilePickerState extends State<NsgFilePicker> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  bool galleryPage = true;
  ScrollController scrollController = ScrollController();
  List<NsgFilePickerObject> objectsList = [];
  List<NsgFilePickerObject> needToCropObj = [];

  Widget _appBar(BuildContext context) {
    return NsgAppBar(
      text: objectsList.isEmpty ? 'Добавление фотографий'.toUpperCase() : 'Сохранение фотографий'.toUpperCase(),
      text2: objectsList.isNotEmpty ? 'вы добавили ${objectsList.length} фото' : null,
      icon: Icons.arrow_back_ios_new,
      color: ControlOptions.instance.colorInverted,
      colorsInverted: true,
      bottomCircular: true,
      onPressed: () {
        NsgNavigator.instance.back(context);
      },
      icon2: Icons.check,
      onPressed2: () {
        widget.callback(objectsList);
        NsgNavigator.instance.back(context);
      },
    );
  }

  /// Pick an image
  Future galleryImage() async {
    if (kIsWeb) {
      var result = await ImagePicker().pickMultiImage(
        imageQuality: widget.imageQuality,
        maxWidth: widget.imageMaxWidth,
        maxHeight: widget.imageMaxHeight,
      );

      galleryPage = true;

      /// Если стоит ограничение на 1 файл
      if (widget.oneFile) {
        result = [result[0]];
        objectsList.clear();
      }
      for (var element in result) {
        var obj =
            NsgFilePickerObject(isNew: true, image: Image.network(element.path), description: basenameWithoutExtension(element.path), filePath: element.path);
        obj.fileContent = await element.readAsBytes();
        objectsList.add(obj);
      }
      if (widget.skipInterface) {
        widget.callback(objectsList);
      } else {
        setState(() {});
      }
    } else if (!kIsWeb && Platform.isWindows) {
      var result = await ImagePicker().pickMultiImage(
        imageQuality: widget.imageQuality,
        maxWidth: widget.imageMaxWidth,
        maxHeight: widget.imageMaxHeight,
      );

      galleryPage = true;

      /// Если стоит ограничение на 1 файл
      if (widget.oneFile) {
        if (result.isNotEmpty) {
          result = [result[0]];
          if (objectsList.isNotEmpty) {
            objectsList.clear();
          }
        }
      }

      for (var element in result) {
        var fileType = NsgFilePicker.getFileType(extension(element.path).replaceAll('.', '').toLowerCase());
        //   var fileType = NsgFilePicker.getFileType(extension(element.name).toLowerCase());

        if (fileType == NsgFilePickerObjectType.image) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              image: Image.file(File(element.path)),
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              filePath: element.path));
        } else if (fileType != NsgFilePickerObjectType.unknown) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              file: File(element.path),
              image: null,
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              filePath: element.path));
        } else {
          error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          setState(() {});
        }
      }
      if (widget.skipInterface) {
        widget.callback(objectsList);
      } else {
        setState(() {});
      }
    } else if (!kIsWeb && Platform.isMacOS) {
      var jpgsTypeGroup = const file.XTypeGroup(
        label: 'JPEGs',
        extensions: <String>['jpg', 'jpeg'],
      );
      var pngTypeGroup = const file.XTypeGroup(
        label: 'PNGs',
        extensions: <String>['png'],
      );
      List<XFile> result = await file.openFiles(acceptedTypeGroups: <file.XTypeGroup>[
        jpgsTypeGroup,
        pngTypeGroup,
      ]);

      if (result.isNotEmpty) {
        galleryPage = true;

        /// Если стоит ограничение на 1 файл
        if (widget.oneFile) {
          result = [result[0]];
          objectsList.clear();
        }
        for (var element in result) {
          var fileType = NsgFilePicker.getFileType(extension(element.path).replaceAll('.', ''));

          if (fileType == NsgFilePickerObjectType.image) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                image: Image.file(File(element.path)),
                description: basenameWithoutExtension(element.path),
                fileType: fileType,
                filePath: element.path));
          } else if (fileType != NsgFilePickerObjectType.unknown) {
            objectsList.add(NsgFilePickerObject(
                isNew: true,
                file: File(element.path),
                image: null,
                description: basenameWithoutExtension(element.path),
                fileType: fileType,
                filePath: element.path));
          } else {
            error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
            setState(() {});
          }
        }
      }
      if (widget.skipInterface) {
        widget.callback(objectsList);
      } else {
        setState(() {});
      }
    } else {
      var result = await ImagePicker().pickMultiImage(
        imageQuality: widget.imageQuality,
        maxWidth: widget.imageMaxWidth,
        maxHeight: widget.imageMaxHeight,
      );

      galleryPage = true;

      /// Если стоит ограничение на 1 файл
      if (widget.oneFile) {
        if (result.isNotEmpty) result = [result[0]];
        objectsList.clear();
      }
      for (var element in result) {
        var fileType = NsgFilePicker.getFileType(extension(element.path).replaceAll('.', ''));

        if (fileType == NsgFilePickerObjectType.image) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              image: Image.file(File(element.path)),
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              filePath: element.path));
        } else if (fileType != NsgFilePickerObjectType.unknown) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              file: File(element.path),
              image: null,
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              filePath: element.path));
        } else {
          error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          setState(() {});
        }
      }

      if (widget.skipInterface) {
        widget.callback(objectsList);
      } else {
        setState(() {});
      }
    }
  }

  /// Pick an image
  Future pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [...widget.allowedFileFormats, ...widget.allowedImageFormats, ...widget.allowedVideoFormats]);
    if (result != null) {
      galleryPage = true;
      for (var element in result.files) {
        var fileType = NsgFilePicker.getFileType(extension(element.name).replaceAll('.', '').toLowerCase());

        var file = File(element.name);
        if ((await file.length()) > widget.fileMaxSize) {
          error = 'Превышен максимальный размер файла ${(widget.fileMaxSize / 1024).toString()} кБайт';
          setState(() {});
          return;
        }
        if (fileType == NsgFilePickerObjectType.image) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              image: Image.file(File(element.name)),
              description: basenameWithoutExtension(element.name),
              fileType: fileType,
              filePath: element.path ?? ''));
        } else if (fileType != NsgFilePickerObjectType.unknown) {
          objectsList.add(NsgFilePickerObject(
              isNew: true,
              file: File(element.name),
              image: null,
              description: basenameWithoutExtension(element.name),
              fileType: fileType,
              filePath: element.path ?? ''));
        } else {
          error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
          setState(() {});
        }
      }
      if (widget.skipInterface) {
        widget.callback(objectsList);
      } else {
        setState(() {});
      }
    }
  }

  /// Capture a photo
  Future cameraImage() async {
    final ImagePicker picker = ImagePicker();
    //NsgProgressDialog progress = NsgProgressDialog(textDialog: 'Добавляем фото из камеры', canStopped: false);
    //progress.show(Get.context);
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    // var result = await ImagePicker().pickMultiImage(
    //   imageQuality: widget.imageQuality,
    //   maxWidth: widget.imageMaxWidth,
    //   maxHeight: widget.imageMaxHeight,
    // );

    var result = [];
    if (image != null) {
      result = [image];
    }

    galleryPage = true;

    /// Если стоит ограничение на 1 файл
    if (widget.oneFile) {
      if (result.isNotEmpty) result = [result[0]];
      objectsList.clear();
    }
    for (var element in result) {
      var fileType = NsgFilePicker.getFileType(extension(element.path).replaceAll('.', ''));

      if (fileType == NsgFilePickerObjectType.image) {
        objectsList.add(NsgFilePickerObject(
            isNew: true,
            image: Image.file(File(element.path)),
            description: basenameWithoutExtension(element.path),
            fileType: fileType,
            filePath: element.path));
      } else if (fileType != NsgFilePickerObjectType.unknown) {
        objectsList.add(NsgFilePickerObject(
            isNew: true,
            file: File(element.path),
            image: null,
            description: basenameWithoutExtension(element.path),
            fileType: fileType,
            filePath: element.path));
      } else {
        error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
        setState(() {});
      }
    }

    if (widget.skipInterface) {
      widget.callback(objectsList);
    } else {
      setState(() {});
    }
  }

  Widget _showFileType(NsgFilePickerObject element) {
    return Container(
        height: 100,
        decoration: BoxDecoration(
          color: ControlOptions.instance.colorMain.withOpacity(0.2),
        ),
        child: Center(
            child: Opacity(
          opacity: 0.5,
          child: NsgText(
            extension(element.filePath).replaceAll('.', ''),
            margin: const EdgeInsets.only(top: 10),
            color: ControlOptions.instance.colorMain,
            type: NsgTextType(const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          ),
        )));
  }

  Future saveFile(NsgFilePickerObject fileObject) async {
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
    var fileName = await FilePicker.platform
        .saveFile(dialogTitle: 'Сохранить файл', type: fileType, allowedExtensions: [extension(fileObject.filePath).replaceAll('.', '')]);
    if (fileName == null) return;
    var ext = extension(fileName);
    if (ext.isEmpty) {
      fileName += extension(fileObject.filePath);
    }

    //TODO: add progress
    dio.Dio io = dio.Dio();
    await io.download(fileObject.filePath, fileName, onReceiveProgress: (receivedBytes, totalBytes) {
      //setState(() {
      // downloading = true;
      // progress =
      //     ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
    });
    await launchUrlString('file:$fileName');
  }

  /// Вывод галереи на экран
  Widget _getImages(BuildContext context) {
    List<Widget> list = [];
    for (var element in objectsList) {
      list.add(Container(
        decoration: BoxDecoration(border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: ControlOptions.instance.colorMain.withOpacity(1)),
                  padding: const EdgeInsets.fromLTRB(5, 0, 30, 0),
                  alignment: Alignment.centerLeft,
                  height: 40,
                  child: Text(
                    element.description,
                    maxLines: 3,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 10,
                      color: ControlOptions.instance.colorInverted,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: ControlOptions.instance.colorMain.withOpacity(0),
                    child: InkWell(
                      hoverColor: ControlOptions.instance.colorMainDark,
                      onTap: () {
                        saveFile(element);
                      },
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.all(5),
                        child: Icon(Icons.save_as, size: 18, color: ControlOptions.instance.colorInverted),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: ControlOptions.instance.colorMain.withOpacity(0),
                    child: InkWell(
                      hoverColor: ControlOptions.instance.colorMainDark,
                      onTap: () {
                        NsgDialog().show(
                            context: context,
                            child: NsgPopUp(
                              title: 'Удаление фотографии',
                              text: 'После удаления, фотографию нельзя будет восстановить. Удалить?',
                              onConfirm: () {
                                objectsList.remove(element);
                                setState(() {});
                                NsgNavigator.instance.back(context);
                              },
                            ));
                      },
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.all(5),
                        child: Icon(Icons.close, size: 18, color: ControlOptions.instance.colorInverted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                //hoverColor: ControlOptions.instance.colorMain,
                onTap: () {
                  if (element.fileType != NsgFilePickerObjectType.other && element.fileType != NsgFilePickerObjectType.unknown) {
                    List<NsgFilePickerObject> imagesList = [];
                    for (var el in objectsList) {
                      if (el.fileType != NsgFilePickerObjectType.other && el.fileType != NsgFilePickerObjectType.unknown) {
                        imagesList.add(el);
                      }
                    }
                    int currentPage = imagesList.indexOf(element);
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
                                    imagesList: imagesList,
                                    currentPage: currentPage,
                                  )
                                ]));
                  } else {
                    nsgSnackbar(context, text: 'Этот файл не является изображением');
                    //   Get.snackbar('Ошибка', 'Этот файл не является изображением',
                    //       duration: const Duration(seconds: 3),
                    //       maxWidth: 300,
                    //       snackPosition: SnackPosition.bottom,
                    //       barBlur: 0,
                    //       overlayBlur: 0,
                    //       colorText: ControlOptions.instance.colorMainText,
                    //       backgroundColor: ControlOptions.instance.colorMainDark);
                    // }
                  }
                },
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: element.image != null
                              ? Image(
                                  image: element.image!.image,
                                  fit: BoxFit.cover,
                                )
                              : _showFileType(element),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
    }
    List<Widget> listWithPlus = list;
    listWithPlus.add(NsgImagePickerButton(
        textChooseFile: widget.textChooseFile,
        onPressed: () {
          if (kIsWeb) {
            galleryImage();
          } else if (!kIsWeb && Platform.isWindows) {
            pickFile();
          } else {
            if (widget.fromGallery) {
              galleryImage();
            } else {
              cameraImage();
            }
          }
        },
        onPressed2: () {
          galleryImage();
        }));

    return RawScrollbar(
        minOverscrollLength: 100,
        minThumbLength: 100,
        thickness: 16,
        trackBorderColor: ControlOptions.instance.colorMainDark,
        trackColor: ControlOptions.instance.colorMainDark,
        thumbColor: ControlOptions.instance.colorMain,
        radius: const Radius.circular(0),
        thumbVisibility: true,
        trackVisibility: true,
        controller: scrollController,
        child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ResponsiveGridList(scroll: false, minSpacing: 10, desiredItemWidth: 100, children: listWithPlus),
            )));
  }

  Widget body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (error != '')
          NsgText(
            margin: const EdgeInsets.only(top: 10),
            error,
            backColor: ControlOptions.instance.colorError.withOpacity(0.2),
          ),
        Flexible(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _getImages(context),
        )),
      ],
    );
  }

  @override
  void initState() {
    objectsList = widget.objectsList;
    super.initState();
  }

/* --------------------------------------------------------------------- Build -------------------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    if (widget.skipInterface) {
      if (kIsWeb) {
        if (widget.useFilePicker) {
          pickFile();
        } else {
          galleryImage();
        }
      } else if (!kIsWeb && Platform.isWindows) {
        if (widget.useFilePicker) {
          pickFile();
        } else {
          galleryImage();
        }
      } else {
        if (widget.fromGallery) {
          galleryImage();
        } else {
          cameraImage();
        }
      }
      return const SizedBox();
    } else {
      return widget.showAsWidget == true
          ? body(context)
          : BodyWrap(
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.white,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _appBar(context),
                    Expanded(
                      child: body(context),
                    ),

                    //SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
    }
  }
}

class NsgImagePickerButton extends StatelessWidget {
  final void Function() onPressed;
  final void Function() onPressed2;
  final String textChooseFile;
  const NsgImagePickerButton({Key? key, required this.onPressed, required this.onPressed2, required this.textChooseFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!kIsWeb && Platform.isWindows)
        ? InkWell(
            hoverColor: ControlOptions.instance.colorMain,
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                color: ControlOptions.instance.colorMain,
              ),
              width: 100,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 24, color: ControlOptions.instance.colorInverted),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(textChooseFile,
                        textAlign: TextAlign.center, style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: ControlOptions.instance.colorMainDark),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ControlOptions.instance.colorMainDark,
                  ),
                  width: 100,
                  height: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(textChooseFile,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      Icon(Icons.arrow_downward, size: 16, color: ControlOptions.instance.colorInverted),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        hoverColor: ControlOptions.instance.colorMain,
                        onTap: onPressed,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ControlOptions.instance.colorMain,
                          ),
                          height: 46,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 24, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child:
                                    Text('Камера', style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InkWell(
                        hoverColor: ControlOptions.instance.colorMain,
                        onTap: onPressed2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ControlOptions.instance.colorMain,
                          ),
                          height: 46,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 24, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child:
                                    Text('Галерея', style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
  }
}
