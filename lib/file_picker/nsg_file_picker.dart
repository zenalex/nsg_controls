import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:path/path.dart';
import 'package:video_player_win/video_player_win.dart';
import '../helpers.dart';
import '../nsg_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Пикер и загрузчик изображений и файлов заданных форматов
class NsgFilePicker extends StatefulWidget {
  final bool showAsWidget;
  final bool useFilePicker;

  final NsgFilePickerProvider filePicker;

  ///Фунция, вызываемая при подтверждении сохранения картинок пользователем
  final Function(List<NsgFilePickerObject>) callback;

  ///Максисально допустимое количество присоединяемых файлов
  ///Например, можно использовать для задания картинки профиля, установив ограничение равное 1
  ///По умолчанию равно нулю - не ограничено
  final int maxFilesCount;
  final String? textChooseFile;

  ///Сохраненные объекты (картинки и документы)
  final List<NsgFilePickerObject> objectsList;

  final bool oneFile;

  final bool needCrop;
  final bool fromGallery;

  NsgFilePicker({
    Key? key,
    this.filePicker = const NsgFilePickerProvider(),
    this.needCrop = false,
    this.showAsWidget = false,
    this.useFilePicker = false,
    this.maxFilesCount = 0,
    required this.callback,
    required this.objectsList,
    this.textChooseFile,
    this.oneFile = false,
    this.fromGallery = true,
  }) : super(key: key) {
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
  //         title: tran.upload_photo,
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
  List<NsgFilePickerObject> objectsList = [];
  List<NsgFilePickerObject> needToCropObj = [];

  Widget _appBar() {
    return NsgAppBar(
      text: objectsList.isEmpty ? tran.add_photos.toUpperCase() : tran.save_photos.toUpperCase(),
      text2: objectsList.isNotEmpty ? tran.photos_added(objectsList.length) : null,
      icon: Icons.arrow_back_ios_new,
      color: ControlOptions.instance.colorInverted,
      colorsInverted: true,
      bottomCircular: true,
      onPressed: () {
        Get.back();
      },
      icon2: Icons.check,
      onPressed2: () {
        widget.callback(objectsList);
        Get.back();
      },
    );
  }

  Widget _showFileType(NsgFilePickerObject element) {
    return Container(
      height: 100,
      decoration: BoxDecoration(color: ControlOptions.instance.colorMain.withAlpha(51)),
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: NsgText(
            extension(element.filePath).replaceAll('.', ''),
            margin: const EdgeInsets.only(top: 10),
            color: ControlOptions.instance.colorMain,
            type: NsgTextType(const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  /// Вывод галереи на экран
  Widget _getImages() {
    List<Widget> list = [];
    for (var element in objectsList) {
      if (element.markToDelete) continue;
      list.add(
        Container(
          decoration: BoxDecoration(border: Border.all(width: 2, color: ControlOptions.instance.colorMain)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(color: ControlOptions.instance.colorMain.withAlpha(255)),
                    padding: const EdgeInsets.fromLTRB(5, 0, 30, 0),
                    alignment: Alignment.centerLeft,
                    height: 40,
                    child: Text(
                      element.description,
                      maxLines: 3,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 10, color: ControlOptions.instance.colorInverted),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: ControlOptions.instance.colorMain.withAlpha(0),
                      child: InkWell(
                        hoverColor: ControlOptions.instance.colorMainDark,
                        onTap: () {
                          widget.filePicker.saveFile(element);
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
                      color: ControlOptions.instance.colorMain.withAlpha(0),
                      child: InkWell(
                        hoverColor: ControlOptions.instance.colorMainDark,
                        onTap: () {
                          Get.dialog(
                            NsgPopUp(
                              title: tran.delete_photos,
                              text: tran.delete_photo_warning,
                              onConfirm: () {
                                element.markToDelete = true;
                                //objectsList.remove(element);
                                setState(() {});
                                //Get.back();
                              },
                            ),
                          );
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
                      Get.dialog(
                        NsgPopUp(
                          onCancel: () {
                            Get.back();
                          },
                          onConfirm: () {
                            Get.back();
                          },
                          margin: const EdgeInsets.all(15),
                          title: tran.view_photo,
                          width: Get.width,
                          height: Get.height,
                          getContent: () => [NsgGallery(imagesList: imagesList, currentPage: currentPage)],
                        ),
                        barrierDismissible: true,
                      );
                    } else {
                      Get.snackbar(
                        tran.error,
                        tran.not_an_image_file,
                        duration: const Duration(seconds: 3),
                        maxWidth: 300,
                        snackPosition: SnackPosition.bottom,
                        barBlur: 0,
                        overlayBlur: 0,
                        colorText: ControlOptions.instance.colorMainText,
                        backgroundColor: ControlOptions.instance.colorMainDark,
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: element.image != null ? Image(image: element.image!.image, fit: BoxFit.cover) : _showFileType(element),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    List<Widget> listWithPlus = list;
    listWithPlus.add(
      NsgImagePickerButton(
        textChooseFile: widget.textChooseFile ?? tran.add_photo,
        onPressed: () async {
          var ans = await widget.filePicker.autoSelectPicker();
          //widget.objectsList.clear();
          widget.objectsList.addAll(ans);
          setState(() {});
        },
        onPressed2: () async {
          var ans = await widget.filePicker.galleryImage();
          widget.objectsList.addAll(ans);
          setState(() {});
        },
      ),
    );

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
        ),
      ),
    );
  }

  Widget body() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (error != '') NsgText(margin: const EdgeInsets.only(top: 10), error, backColor: ControlOptions.instance.colorError.withAlpha(51)),
        Flexible(
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: _getImages()),
        ),
      ],
    );
  }

  @override
  void initState() {
    //assert(widget.objectsList == const[], 'List<NsgFilePickerObject>.empty()');
    try {
      objectsList = widget.objectsList;
      objectsList.add(NsgFilePickerObject(isNew: true));
      objectsList.removeLast();
    } catch (ex) {
      throw Exception('Вместо const[] в objectsList нужно добавлять List<NsgFilePickerObject>.empty(growable: true)');
    }
    super.initState();
  }

  /* --------------------------------------------------------------------- Build -------------------------------------------------------------------- */
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
                  Expanded(child: body()),

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
  final String textChooseFile;
  const NsgImagePickerButton({Key? key, required this.onPressed, required this.onPressed2, required this.textChooseFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!kIsWeb && GetPlatform.isWindows)
        ? InkWell(
            hoverColor: ControlOptions.instance.colorMain,
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(color: ControlOptions.instance.colorMain),
              width: 100,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 24, color: ControlOptions.instance.colorInverted),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      textChooseFile,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
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
                  decoration: BoxDecoration(color: ControlOptions.instance.colorMainDark),
                  width: 100,
                  height: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          textChooseFile,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
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
                          decoration: BoxDecoration(color: ControlOptions.instance.colorMain),
                          height: 46,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 24, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                  tran.camera,
                                  style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
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
                          decoration: BoxDecoration(color: ControlOptions.instance.colorMain),
                          height: 46,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 24, color: ControlOptions.instance.colorInverted),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                  tran.gallery,
                                  style: TextStyle(color: ControlOptions.instance.colorInverted, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
