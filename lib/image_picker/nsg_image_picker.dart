import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:path/path.dart';
import '../nsg_border.dart';
import '../nsg_progress_dialog.dart';
import '../nsg_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'nsg_image_picker_image.dart';

class NsgImagePicker extends StatefulWidget {
  final List<NsgImagePickerObject>? images;
  final bool showAsWidget;
  final List<String> allowedImageFormats;
  final List<String> allowedFileFormats;
  final Function(List<NsgImagePickerObject>) callback;
  const NsgImagePicker(
      {Key? key,
      this.allowedImageFormats = const ['jpeg', 'jpg', 'gif', 'png', 'bmp'],
      this.allowedFileFormats = const ['doc', 'docx', 'rtf', 'xls', 'xlsx', 'pdf', 'rtf'],
      this.images,
      this.showAsWidget = false,
      required this.callback})
      : super(key: key);

  @override
  State<NsgImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<NsgImagePicker> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  List<NsgImagePickerObject> images = [];
  bool galleryPage = true;
  //Function(List<XFile>) callback = Get.arguments;

  Widget _appBar() {
    return NsgAppBar(
      //text: controller.currentItem.isEmpty ? _textTitleNew : _textTitle,
      text: images.isEmpty ? 'Добавление фотографий'.toUpperCase() : 'Сохранение фотографий'.toUpperCase(),
      text2: images.isNotEmpty ? 'вы добавили ${images.length} фото' : null,
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
        widget.callback(images);
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
            images.add(NsgImagePickerObject(image: Image.network(element.path), description: basenameWithoutExtension(element.path)));
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

            if (widget.allowedImageFormats.contains(fileType)) {
              images.add(NsgImagePickerObject(image: Image.file(File(element.path)), description: basenameWithoutExtension(element.path), fileType: fileType));
            } else if (widget.allowedFileFormats.contains(fileType)) {
              images.add(NsgImagePickerObject(file: File(element.path), description: basenameWithoutExtension(element.path), fileType: fileType));
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
            images.add(NsgImagePickerObject(image: Image.file(File(element.path)), description: basenameWithoutExtension(element.path)));
          }
        });
      }
    }
  }

  /// Capture a photo
  Future cameraImage() async {
    final ImagePicker picker = ImagePicker();
    NsgProgressDialog progress = NsgProgressDialog(textDialog: 'Добавляем фото из камеры', canStopped: false);
    progress.show(Get.context);
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      progress.hide(Get.context);
      //Get.offAndToNamed(Routes.imagePickerGalleryPage, arguments: [image]);
      setState(() {
        images.add(NsgImagePickerObject(image: Image.file(File(image.path)), description: basenameWithoutExtension(image.path)));
      });
    } else {
      progress.hide(Get.context);
      setState(() {
        error = 'Ошибка камеры';
      });
    }
  }

  Widget _showFileType(NsgImagePickerObject element) {
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
    for (var element in images) {
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
                            images.remove(element);
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
            Stack(
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
          ],
        ),
      ));
    }
    List<Widget> listWithPlus = list;
    listWithPlus.add(NsgImagePickerButton(
        icon: Icons.add,
        text: 'Добавить фото',
        onPressed: () {
          if (kIsWeb) {
            galleryImage();
          } else if (GetPlatform.isWindows) {
            galleryImage();
          } else {
            setState(() {
              galleryPage = false;
            });
          }
        }));

    return ResponsiveGridList(minSpacing: 10, desiredItemWidth: 150, children: listWithPlus);
  }

  Widget body() {
    if (galleryPage) {
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
    } else {
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
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.images != null) {
      images = widget.images!;
    }
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
  final IconData icon;
  final String text;
  final void Function()? onPressed;
  const NsgImagePickerButton({Key? key, required this.icon, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ControlOptions.instance.colorMain.withOpacity(0.5),
      child: InkWell(
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
              Icon(icon, size: 64, color: ControlOptions.instance.colorInverted),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: NsgText(text, color: ControlOptions.instance.colorInverted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
