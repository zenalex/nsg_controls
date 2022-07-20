import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'nsg_progress_dialog.dart';

class NsgImagePicker extends StatefulWidget {
  final List<XFile>? images;
  final bool showAsWidget;
  const NsgImagePicker({Key? key, this.images, this.showAsWidget = false}) : super(key: key);

  @override
  State<NsgImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<NsgImagePicker> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  List<XFile> images = [];

  Function(List<XFile>) callback = Get.arguments;

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
        callback(images);
        Get.back();
      },
    );
  }

  /// Pick an image
  Future galleryImage() async {
    if (Platform.isWindows) {
      /*      final ImagePickerPlatform picker = ImagePickerPlatform.instance;
        final PickedFile? image = await picker.pickImage(source: ImageSource.gallery);*/

      final result = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1440,
      );
      if (result != null) {
        setState(() {
          images = result;
        });
      }
    } else {
      /*final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.camera);*/

      final result = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1440,
      );

      if (result != null) {
        setState(() {
          images = result;
        });
        //Get.toNamed(Routes.imagePickerGalleryPage, arguments: result);
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
        images = [image];
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
      list.add(Stack(
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(width: 1, color: ControlOptions.instance.colorMain.withOpacity(0.5))),
            child: Row(
              children: [
                Expanded(
                  child: Image.file(
                    File(element.path),
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
                  images.remove(element);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Icon(Icons.close, size: 18, color: ControlOptions.instance.colorInverted),
                ),
              ),
            ),
          )
        ],
      ));
    }
    return ResponsiveGridList(minSpacing: 10, desiredItemWidth: 150, children: list);
  }

  Widget body() {
    if (images.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _getImages(),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: NsgButton(
                        icon: Icons.photo_library_outlined,
                        borderRadius: 5,
                        text: 'Галерея',
                        color: ControlOptions.instance.colorInverted,
                        onPressed: () {
                          galleryImage();
                        }),
                  ),
                  if (Platform.isAndroid || Platform.isIOS)
                    Expanded(
                      child: NsgButton(
                          icon: Icons.photo_camera_outlined,
                          borderRadius: 5,
                          text: 'Камера',
                          color: ControlOptions.instance.colorInverted,
                          onPressed: () {
                            cameraImage();
                          }),
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
    if (images.isEmpty && !Platform.isAndroid && !Platform.isIOS) {
      galleryImage();
    }

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
