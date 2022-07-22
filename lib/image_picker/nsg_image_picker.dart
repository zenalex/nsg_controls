import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:path/path.dart';
import '../nsg_button.dart';
import '../nsg_control_options.dart';
import '../nsg_progress_dialog.dart';
import '../nsg_text.dart';
import '../widgets/body_wrap.dart';
import '../widgets/nsg_appbar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'nsg_image_picker_image.dart';

class NsgImagePicker extends StatefulWidget {
  final List<NsgImagePickerImage>? images;
  final bool showAsWidget;

  final Function(List<NsgImagePickerImage>) callback;
  const NsgImagePicker({Key? key, this.images, this.showAsWidget = false, required this.callback}) : super(key: key);

  @override
  State<NsgImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<NsgImagePicker> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  List<NsgImagePickerImage> images = [];
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
            images.add(NsgImagePickerImage(image: Image.network(element.path), description: basenameWithoutExtension(result[0].path)));
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
            images.add(NsgImagePickerImage(image: Image.file(File(element.path)), description: basenameWithoutExtension(result[0].path)));
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
            images.add(NsgImagePickerImage(image: Image.file(File(element.path)), description: basenameWithoutExtension(result[0].path)));
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
        images.add(NsgImagePickerImage(image: Image.file(File(image.path)), description: basenameWithoutExtension(image.path)));
      });
    } else {
      progress.hide(Get.context);
      setState(() {
        error = 'Ошибка камеры';
      });
    }
  }

  /// Вывод галереи на экран
  Widget _getImages() {
    List<Widget> list = [];
    for (var element in images) {
      list.add(Column(
        children: [
          NsgText(
            margin: const EdgeInsets.only(bottom: 5),
            element.description,
            maxLines: 2,
            overflow: TextOverflow.clip,
          ),
          //NsgInput(dataItem: dataItem, fieldName: fieldName),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain.withOpacity(0.5))),
                child: Row(
                  children: [
                    Expanded(
                      child: Image(
                        image: element.image.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Material(
                  color: ControlOptions.instance.colorMain.withOpacity(0.5),
                  child: InkWell(
                    hoverColor: ControlOptions.instance.colorMain,
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
                      padding: const EdgeInsets.all(5),
                      child: Icon(Icons.close, size: 18, color: ControlOptions.instance.colorInverted),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _getImages(),
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
