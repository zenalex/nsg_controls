import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imagedit;
import 'package:nsg_controls/nsg_controls.dart';

import '../helpers.dart';
import '../widgets/nsg_light_app_bar.dart';
import '../widgets/nsg_simple_progress_bar.dart';

class NsgCrop {
  Future<List<List<int>>?> cropImages(BuildContext context,
      {required List<List<int>> imageList, double? ratio = 1 / 1, bool isCircle = false, bool isFree = true, Color backColor = Colors.white}) async {
    List<Uint8List> imageDataList = [];
    for (var el in imageList) {
      final mainImage = imagedit.decodeImage(Uint8List.fromList(el));
      final background = imagedit.Image(width: mainImage!.width + 500, height: mainImage.height + 500);

      for (var pixel in background) {
        pixel.setRgba(backColor.red, backColor.green, backColor.blue, backColor.alpha);
      }

      imagedit.Image mergeImage = imagedit.compositeImage(background, mainImage, center: true);

      //imageDataList.add(Uint8List.fromList(el));
      imageDataList.add(imagedit.encodePng(mergeImage));
    }
    Future<List<Uint8List>?> imdd = Navigator.push(
        context,
        CupertinoPageRoute(
            builder: ((context) => NsgCropPage(
                  imageDataList: imageDataList,
                  aspectRatio: ratio,
                  isFree: isFree,
                  isCircle: isCircle,
                )))).then((value) {
      return value;
    });
    return await imdd;
  }
}

// ignore: must_be_immutable
class NsgCropPage extends StatefulWidget {
  NsgCropPage(
      {Key? key,
      required this.imageDataList,
      //required this.img,
      this.isCircle = false,
      this.isFree = true,
      this.aspectRatio = 16 / 9,
      this.interactive = true})
      : super(key: key);

  final bool isCircle;
  //final Uint8List img;
  List<Uint8List> imageDataList;
  final double? aspectRatio;
  final bool isFree;
  final bool interactive;

  @override
  NsgCropPageState createState() => NsgCropPageState();
}

class NsgCropPageState extends State<NsgCropPage> {
  final CropController _controller = CropController();

  var _currentImage = 0;
  //late List<Uint8List> _croppedDataList;
  set currentImage(int value) {
    setState(() {
      _currentImage = value;
    });
    _controller.image = widget.imageDataList[_currentImage];
  }

  @override
  void initState() {
    //_croppedDataList = widget.imageDataList;
    super.initState();
  }

  String text = tran.loading;
  bool showSplash = true;

  @override
  Widget build(BuildContext context) {
    return BodyWrap(
        child: Scaffold(
      body: Column(
        children: [
          NsgLightAppBar(
            title: text,
            leftIcons: [
              NsgLigthAppBarIcon(
                icon: Icons.arrow_back_ios_new,
                onTap: () {
                  if (!showSplash) {
                    Navigator.pop(context, null);
                  }
                },
              )
            ],
            rightIcons: [
              NsgLigthAppBarIcon(
                icon: Icons.check,
                onTap: () {
                  if (!showSplash) {
                    Navigator.pop(context, widget.imageDataList);
                  }
                },
              )
            ],
          ),
          Expanded(
              child: Stack(alignment: Alignment.bottomCenter, children: [
            Crop(
              image: widget.imageDataList[_currentImage],
              controller: _controller,
              onCropped: (image) {
                /*final img = Image.memory(image, 
                        width: double.infinity,
                        fit: BoxFit.cover,
                        );*/
                // _croppedDataList[_currentImage] = image;
                widget.imageDataList[_currentImage] = image;
                currentImage = _currentImage;
              },
              initialRectBuilder: (rect, rect2) => Rect.fromLTRB(rect.left + 24, rect.top + 32, rect.right - 24, rect.bottom - 32),
              withCircleUi: widget.isCircle,
              baseColor: ControlOptions.instance.colorMainLighter,
              maskColor: Colors.black.withAlpha(150),
              radius: 20,
              onMoved: (newRect) {},
              onStatusChanged: (status) {
                if (status == CropStatus.ready) {
                  _controller.aspectRatio = widget.aspectRatio;
                  text = tran.prepare_photo;
                  showSplash = false;
                  setState(() {});
                }
                if (status == CropStatus.cropping) {
                  //splash
                  text = tran.loading;
                  showSplash = true;
                  setState(() {});
                }
                if (status == CropStatus.loading) {
                  //splash
                  text = tran.loading;
                  showSplash = true;
                  setState(() {});
                }
              },
              cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.blue),
              interactive: widget.interactive,
              fixCropRect: !widget.isFree,
              progressIndicator: const NsgSimpleProgressBar(
                size: 100,
                width: 10,
              ),
            ),
            Positioned(
                child: NsgCropToolsMenu(
              buttons: [
                NsgCropToolsMenuItem(
                  icon: Icons.crop,
                  onTap: () {
                    _controller.crop();
                  },
                )
              ],
            )),
            //getSpash(showSplash),
          ])),
          if (widget.imageDataList.length > 1)
            NsgCropGallery(
              images: widget.imageDataList,
              onItemTap: (index) {
                if (_currentImage != index) {
                  currentImage = index;
                }
              },
              deleteImage: (newList) {
                if (newList.isNotEmpty) {
                  widget.imageDataList = newList;
                  currentImage = 0;
                } else {
                  Navigator.pop(context, null);
                }
              },
            )
        ],
      ),
    ));
  }

  Widget getSpash(bool showSplash) {
    Widget splash;
    if (showSplash) {
      splash = Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withAlpha(170),
          child: const NsgSimpleProgressBar(
            size: 100,
            width: 10,
          ));
    } else {
      splash = Container();
    }
    return splash;
  }
}

class NsgCropToolsMenuItem extends StatefulWidget {
  const NsgCropToolsMenuItem({super.key, this.isSelected = false, required this.icon, this.onTap});

  final bool isSelected;
  final void Function()? onTap;
  final IconData icon;

  @override
  State<NsgCropToolsMenuItem> createState() => _NsgCropToolsMenuItemState();
}

class _NsgCropToolsMenuItemState extends State<NsgCropToolsMenuItem> {
  late bool isHover;

  @override
  void initState() {
    isHover = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (value) {
        isHover = value;
        setState(() {});
      },
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, color: getBackColor()),
        child: Icon(
          widget.icon,
          color: getIconColor(),
        ),
      ),
    );
  }

  Color getBackColor() {
    if (widget.isSelected) {
      return ControlOptions.instance.colorMainLight;
    } else {
      if (isHover) {
        return ControlOptions.instance.colorMainLighter;
      } else {
        return Colors.transparent;
      }
    }
  }

  Color getIconColor() {
    if (widget.isSelected) {
      return ControlOptions.instance.colorMain;
    } else {
      if (isHover) {
        return Colors.white;
      } else {
        return Colors.white;
      }
    }
  }
}

class NsgCropToolsMenu extends StatefulWidget {
  const NsgCropToolsMenu({super.key, this.buttons = const []});

  final List<NsgCropToolsMenuItem> buttons;

  @override
  State<NsgCropToolsMenu> createState() => _NsgCropToolsMenuState();
}

class _NsgCropToolsMenuState extends State<NsgCropToolsMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ControlOptions.instance.colorMain.withAlpha(200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.buttons.asMap().entries.map((entry) {
            return NsgCropToolsMenuItem(
              icon: entry.value.icon,
              onTap: entry.value.onTap,
              isSelected: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NsgCropGallery extends StatelessWidget {
  const NsgCropGallery({super.key, required this.images, this.deleteImage, this.onItemTap});

  final List<Uint8List> images;
  final Function(List<Uint8List> newList)? deleteImage;
  final Function(int index)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(
            color: ControlOptions.instance.colorMainLight,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15)),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: getImages().length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
                margin: const EdgeInsets.all(10),
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: getImages()[index]);
          }),
    ); //выстраиваем сетку из фотографий и иконки +
  }

  List<Widget> getImages() {
    List<Widget> list = [];

    for (int i = 0; i < images.length; i++) {
      list.add(SelectPhotoItem(
        photoData: images[i],
        index: i,
        onTap: (index) {
          if (onItemTap != null) {
            onItemTap!(index);
          }
        },
        onPressDelete: (index) {
          images.removeAt(index);
          if (deleteImage != null) {
            deleteImage!(images);
          }
          //callback
        },
      ));
    }
    return list;
  }
}

class SelectPhotoItem extends StatefulWidget {
  const SelectPhotoItem({super.key, required this.photoData, this.onPressDelete, this.onTap, required this.index});

  final Uint8List photoData;
  final int index;
  final void Function(int index)? onPressDelete;
  final void Function(int index)? onTap;

  @override
  State<SelectPhotoItem> createState() => _SelectPhotoItemState();
}

class _SelectPhotoItemState extends State<SelectPhotoItem> {
  Color iconColor = ControlOptions.instance.colorMain;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!(widget.index);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.memory(
              widget.photoData,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            top: -10,
            right: -10,
            child: InkWell(
              onTap: () {
                if (widget.onPressDelete != null) {
                  widget.onPressDelete!(widget.index);
                }
              },
              onHover: (value) {
                value ? iconColor = Colors.red : iconColor = ControlOptions.instance.colorMain;
              },
              child: Icon(
                Icons.cancel,
                color: iconColor,
              ),
            ))
      ],
    ));
  }
}

class NsgCropPageStyle {
  const NsgCropPageStyle({this.mainButtonsColor, this.titleStyle});
  final TextStyle? titleStyle;
  final Color? mainButtonsColor;

  NsgCropPageStyleMain style() {
    return NsgCropPageStyleMain(
        mainButtonsColor: mainButtonsColor ?? ControlOptions.instance.colorMainLight,
        titleStyle: titleStyle ?? TextStyle(fontSize: ControlOptions.instance.sizeL, fontWeight: FontWeight.w500, fontFamily: 'Inter'));
  }
}

class NsgCropPageStyleMain {
  const NsgCropPageStyleMain({required this.mainButtonsColor, required this.titleStyle});
  final TextStyle titleStyle;
  final Color mainButtonsColor;
}
