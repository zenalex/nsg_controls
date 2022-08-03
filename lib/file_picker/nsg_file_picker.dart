import 'dart:io';
import 'dart:async';
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
import 'nsg_file_picker_object.dart';

/// Пикер и загрузчик изображений и файлов заданных форматов
class NsgFilePicker extends StatefulWidget {
  final bool showAsWidget;
  final List<String> allowedImageFormats;
  final List<String> allowedFileFormats;
  final Function(List<NsgFilePickerObject>) callback;
  const NsgFilePicker(
      {Key? key,
      this.allowedImageFormats = const ['jpeg', 'jpg', 'gif', 'png', 'bmp'],
      this.allowedFileFormats = const ['doc', 'docx', 'rtf', 'xls', 'xlsx', 'pdf', 'rtf'],
      this.showAsWidget = false,
      required this.callback})
      : super(key: key);

  @override
  State<NsgFilePicker> createState() => _NsgFilePickerState();
}

class _NsgFilePickerState extends State<NsgFilePicker> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  List<NsgFilePickerObject> objectsList = [];
  bool galleryPage = true;
  ScrollController scrollController = ScrollController();

  //Function(List<XFile>) callback = Get.arguments;

  Widget _appBar() {
    return NsgAppBar(
      //text: controller.currentItem.isEmpty ? _textTitleNew : _textTitle,
      text: objectsList.isEmpty ? 'Добавление фотографий'.toUpperCase() : 'Сохранение фотографий'.toUpperCase(),
      text2: objectsList.isNotEmpty ? 'вы добавили ${objectsList.length} фото' : null,
      icon: Icons.arrow_back_ios_new,
      color: ControlOptions.instance.colorInverted,
      colorsInverted: true,
      bottomCircular: true,
      onPressed: () {
        //controller.itemPageCancel();
        Get.back();
      },
      icon2: Icons.check,
      onPressed2: () {
        widget.callback(objectsList);
        Get.back();
      },
    );
  }

  /// Pick an image
  Future galleryImage() async {
    if (kIsWeb) {
      final result = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1440,
        maxHeight: 1440,
      );
      if (result != null) {
        setState(() {
          galleryPage = true;
          for (var element in result) {
            objectsList.add(NsgFilePickerObject(image: Image.network(element.path), description: basenameWithoutExtension(element.path)));
          }
        });
      }
    } else if (GetPlatform.isWindows) {
      final result = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1440,
        maxHeight: 1440,
      );
      if (result != null) {
        setState(() {
          galleryPage = true;
          for (var element in result) {
            String? fileType = extension(element.path).replaceAll('.', '');

            if (widget.allowedImageFormats.contains(fileType.toLowerCase())) {
              objectsList
                  .add(NsgFilePickerObject(image: Image.file(File(element.path)), description: basenameWithoutExtension(element.path), fileType: fileType));
            } else if (widget.allowedFileFormats.contains(fileType.toLowerCase())) {
              objectsList
                  .add(NsgFilePickerObject(file: File(element.path), image: null, description: basenameWithoutExtension(element.path), fileType: fileType));
            } else {
              error = '${fileType.toString().toUpperCase()} - неподдерживаемый формат';
              setState(() {});
            }
          }
        });
      }
    } else {
      final result = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1440,
        maxHeight: 1440,
      );

      if (result != null) {
        setState(() {
          galleryPage = true;
          for (var element in result) {
            objectsList.add(NsgFilePickerObject(image: Image.file(File(element.path)), description: basenameWithoutExtension(element.path)));
          }
        });
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
        objectsList.add(NsgFilePickerObject(image: Image.file(File(image.path)), description: basenameWithoutExtension(image.path)));
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
        width: 150,
        height: 150,
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
                            objectsList.remove(element);
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
                    for (var el in objectsList) {
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
                        snackPosition: SnackPosition.BOTTOM,
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
    listWithPlus.add(NsgImagePickerButton(onPressed: () {
      if (kIsWeb) {
        galleryImage();
      } else if (GetPlatform.isWindows) {
        galleryImage();
      } else {
        cameraImage();
      }
    }, onPressed2: () {
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
              child: ResponsiveGridList(scroll: false, minSpacing: 10, desiredItemWidth: 150, children: listWithPlus),
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
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _getImages(),
        )),
      ],
    );
    /*else {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: NsgText('Добавление фотографий'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NsgImagePickerButton(
                      icon: Icons.photo_library_outlined,
                      text: 'Галерея',
                      onPressed: () {
                        galleryImage();
                      },
                    ),
                    if (!kIsWeb)
                      if (Platform.isAndroid || Platform.isIOS)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: NsgImagePickerButton(
                            icon: Icons.photo_camera_outlined,
                            text: 'Камера',
                            onPressed: () {
                              cameraImage();
                            },
                          ),
                        ),
                  ],
                ),
                Text(
                  error,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      );
    }*/
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

class NsgImagePickerButton extends StatelessWidget {
  final void Function() onPressed;
  final void Function() onPressed2;
  const NsgImagePickerButton({Key? key, required this.onPressed, required this.onPressed2}) : super(key: key);

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
              width: 150,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 64, color: ControlOptions.instance.colorInverted),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: NsgText('Добавить фото', color: ControlOptions.instance.colorInverted),
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
                  width: 175,
                  height: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 32, color: ControlOptions.instance.colorInverted),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: NsgText('Добавить фото', color: ControlOptions.instance.colorInverted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
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
                          height: 72,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 32, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: NsgText('Камера', color: ControlOptions.instance.colorInverted),
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
                          height: 72,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 32, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: NsgText('Галерея', color: ControlOptions.instance.colorInverted),
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
        NsgText('${_indx + 1} / ${widget.imagesList.length}'),
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
        NsgText(_desc),
      ],
    );
  }
}
