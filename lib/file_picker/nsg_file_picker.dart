import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:path/path.dart';
import '../nsg_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_selector/file_selector.dart' as file;

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

  const NsgFilePicker(
      {Key? key,
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
      this.skipInterface = false})
      : super(key: key);

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
}

class _NsgFilePickerState extends State<NsgFilePicker> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  bool galleryPage = true;
  ScrollController scrollController = ScrollController();

  Widget _appBar() {
    return NsgAppBar(
      text: widget.objectsList.isEmpty ? 'Добавление фотографий'.toUpperCase() : 'Сохранение фотографий'.toUpperCase(),
      text2: widget.objectsList.isNotEmpty ? 'вы добавили ${widget.objectsList.length} фото' : null,
      icon: Icons.arrow_back_ios_new,
      color: ControlOptions.instance.colorInverted,
      colorsInverted: true,
      bottomCircular: true,
      onPressed: () {
        Get.back();
      },
      icon2: Icons.check,
      onPressed2: () {
        widget.callback(widget.objectsList);
        Get.back();
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
        widget.objectsList.clear();
      }
      for (var element in result) {
        widget.objectsList.add(NsgFilePickerObject(
            image: Image.network(element.path),
            description: basenameWithoutExtension(element.path),
            filePath: element.path));
      }
      if (widget.skipInterface) {
        widget.callback(widget.objectsList);
      } else {
        setState(() {});
      }
    } else if (GetPlatform.isWindows) {
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
          widget.objectsList.clear();
        }
      }
      for (var element in result) {
        String? fileType = extension(element.path).replaceAll('.', '');

        if (widget.allowedImageFormats.contains(fileType.toLowerCase())) {
          widget.objectsList.add(NsgFilePickerObject(
              image: Image.file(File(element.path)),
              description: basenameWithoutExtension(element.path),
              fileType: fileType,
              filePath: element.path));
        } else if (widget.allowedFileFormats.contains(fileType.toLowerCase())) {
          widget.objectsList.add(NsgFilePickerObject(
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
        widget.callback(widget.objectsList);
      } else {
        setState(() {});
      }
    } else if (GetPlatform.isMacOS) {
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
          widget.objectsList.clear();
        }
        for (var element in result) {
          String? fileType = extension(element.path).replaceAll('.', '');

          if (widget.allowedImageFormats.contains(fileType.toLowerCase())) {
            widget.objectsList.add(NsgFilePickerObject(
                image: Image.file(File(element.path)),
                description: basenameWithoutExtension(element.path),
                fileType: fileType,
                filePath: element.path));
          } else if (widget.allowedFileFormats.contains(fileType.toLowerCase())) {
            widget.objectsList.add(NsgFilePickerObject(
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
        widget.callback(widget.objectsList);
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
        widget.objectsList.clear();
      }
      for (var element in result) {
        widget.objectsList.add(NsgFilePickerObject(
            image: Image.file(File(element.path)),
            description: basenameWithoutExtension(element.path),
            filePath: element.path));
      }

      if (widget.skipInterface) {
        widget.callback(widget.objectsList);
      } else {
        setState(() {});
      }
    }
  }

  /// Pick an image
  Future pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: [...widget.allowedFileFormats, ...widget.allowedImageFormats]);
    if (result != null) {
      galleryPage = true;
      for (var element in result.files) {
        String? fileType = extension(element.name).replaceAll('.', '');

        var file = File(element.name);
        if ((await file.length()) > widget.fileMaxSize) {
          error = 'Превышен саксимальный размер файла ${(widget.fileMaxSize / 1024).toString()} кБайт';
          setState(() {});
          return;
        }
        if (widget.allowedImageFormats.contains(fileType.toLowerCase())) {
          widget.objectsList.add(NsgFilePickerObject(
              image: Image.file(File(element.name)),
              description: basenameWithoutExtension(element.name),
              fileType: fileType,
              filePath: element.path ?? ''));
        } else if (widget.allowedFileFormats.contains(fileType.toLowerCase())) {
          widget.objectsList.add(NsgFilePickerObject(
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
    }
  }

  /// Capture a photo
  Future cameraImage() async {
    final ImagePicker picker = ImagePicker();
    //NsgProgressDialog progress = NsgProgressDialog(textDialog: 'Добавляем фото из камеры', canStopped: false);
    //progress.show(Get.context);
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        widget.objectsList.add(NsgFilePickerObject(
            image: Image.file(File(image.path)),
            description: basenameWithoutExtension(image.path),
            filePath: image.path));
        galleryPage = false;
      });
    } else {
      setState(() {
        error = 'Ошибка камеры';
      });
    }
  }

  Widget _showFileType(NsgFilePickerObject element) {
    return Container(
        decoration: BoxDecoration(
          color: ControlOptions.instance.colorMain.withOpacity(0.2),
        ),
        width: 36,
        height: 36,
        child: Center(
            child: Opacity(
          opacity: 0.5,
          child: NsgText(
            '${element.fileType}',
            margin: const EdgeInsets.only(top: 10),
            color: ControlOptions.instance.colorMain,
            type: NsgTextType(const TextStyle(fontSize: 48, fontWeight: FontWeight.w500)),
          ),
        )));
  }

  /// Вывод галереи на экран
  Widget _getImages() {
    List<Widget> list = [];
    for (var element in widget.objectsList) {
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
                  child: NsgText(
                    color: ControlOptions.instance.colorInverted,
                    element.description,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: ControlOptions.instance.colorMain.withOpacity(0),
                    child: InkWell(
                      hoverColor: ControlOptions.instance.colorMainDark,
                      onTap: () {
                        Get.dialog(NsgPopUp(
                          title: 'Удаление фотографии',
                          text: 'После удаления, фотографию нельзя будет восстановить. Удалить?',
                          onConfirm: () {
                            widget.objectsList.remove(element);
                            setState(() {});
                            Get.back();
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
                  if (element.image != null) {
                    List<NsgFilePickerObject> imagesList = [];
                    for (var el in widget.objectsList) {
                      if (el.image != null) {
                        imagesList.add(el);
                      }
                    }
                    int currentPage = imagesList.indexOf(element);
                    Get.dialog(
                        NsgPopUp(
                            onCancel: () {
                              Get.back();
                            },
                            onConfirm: () {
                              Get.back();
                            },
                            margin: const EdgeInsets.all(15),
                            title: "Просмотр изображений",
                            width: Get.width,
                            height: Get.height,
                            getContent: () => [
                                  _Gallery(
                                    imagesList: imagesList,
                                    currentPage: currentPage,
                                  )
                                ]),
                        barrierDismissible: true);
                  } else {
                    Get.snackbar('Ошибка', 'Этот файл не является изображением',
                        duration: const Duration(seconds: 3),
                        maxWidth: 300,
                        snackPosition: SnackPosition.bottom,
                        barBlur: 0,
                        overlayBlur: 0,
                        colorText: ControlOptions.instance.colorMainText,
                        backgroundColor: ControlOptions.instance.colorMainDark);
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
          } else if (GetPlatform.isWindows) {
            galleryImage();
          } else {
            galleryImage();
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

  Widget body() {
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
          child: _getImages(),
        )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

/* --------------------------------------------------------------------- Build -------------------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    if (widget.skipInterface) {
      if (kIsWeb) {
        galleryImage();
      } else if (GetPlatform.isWindows) {
        galleryImage();
      } else {
        galleryImage();
      }
      return SizedBox();
    } else {
      return widget.showAsWidget == true
          ? body()
          : BodyWrap(
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.white,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _appBar(),
                    Expanded(
                      child: body(),
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
  const NsgImagePickerButton(
      {Key? key, required this.onPressed, required this.onPressed2, required this.textChooseFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!kIsWeb && GetPlatform.isWindows)
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 12)),
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
                            style: TextStyle(
                                color: ControlOptions.instance.colorInverted,
                                fontWeight: FontWeight.bold,
                                fontSize: 10)),
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
                                child: Text('Камера',
                                    style: TextStyle(
                                        color: ControlOptions.instance.colorInverted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
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
                              Icon(Icons.photo_library_outlined,
                                  size: 24, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text('Галерея',
                                    style: TextStyle(
                                        color: ControlOptions.instance.colorInverted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
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

class _Gallery extends StatefulWidget {
  final List<NsgFilePickerObject> imagesList;
  final int currentPage;
  const _Gallery({Key? key, required this.imagesList, required this.currentPage}) : super(key: key);

  @override
  State<_Gallery> createState() => __GalleryState();
}

String _desc = '';
int _indx = 0;
PageController pageController = PageController();

class __GalleryState extends State<_Gallery> {
  @override
  void initState() {
    super.initState();

    _indx = widget.currentPage;
  }

  @override
  Widget build(BuildContext context) {
    pageController = PageController(initialPage: _indx);
    _desc = widget.imagesList[_indx].description;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_indx + 1} / ${widget.imagesList.length}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: Get.height - 150,
              child: PhotoViewGallery.builder(
                key: GlobalKey(),
                onPageChanged: (value) {
                  _desc = widget.imagesList[value].description;
                  _indx = value;
                },
                pageController: pageController,
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: widget.imagesList[index].image!.image,
                    initialScale: PhotoViewComputedScale.contained * 0.9,
                    // heroAttributes: PhotoViewHeroAttributes(tag: imagesList[index].description),
                  );
                },
                itemCount: widget.imagesList.length,
                loadingBuilder: (context, event) => const NsgProgressBar(),
                backgroundDecoration: BoxDecoration(color: ControlOptions.instance.colorInverted),
                /*pageController: widget.pageController,
                        onPageChanged: onPageChanged,*/
              ),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _indx--;
                        if (_indx < 0) {
                          _indx = widget.imagesList.length - 1;
                        }
                      });
                    },
                    child: const Icon(
                      Icons.arrow_left_outlined,
                      size: 48,
                    ))),
            Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _indx++;
                        if (_indx > widget.imagesList.length - 1) {
                          _indx = 0;
                        }
                      });
                    },
                    child: const Icon(
                      Icons.arrow_right_outlined,
                      size: 48,
                    ))),
          ],
        ),
        Text(
          _desc,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
