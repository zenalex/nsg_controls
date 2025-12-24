import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/file_picker/nsg_video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../nsg_control_options.dart';
import '../widgets/nsg_progressbar.dart';
import 'nsg_file_picker_object.dart';

class NsgGallery extends StatefulWidget {
  final List<NsgFilePickerObject> imagesList;
  final int currentPage;
  const NsgGallery({super.key, required this.imagesList, required this.currentPage});

  @override
  State<NsgGallery> createState() => NsgGalleryState();
}

class NsgGalleryState extends State<NsgGallery> {
  String _desc = '';
  int _indx = 0;
  PageController pageController = PageController();

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
        Text('${_indx + 1} / ${widget.imagesList.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  var obj = widget.imagesList[index];
                  if (obj.fileType == NsgFilePickerObjectType.pdf) {
                    if (obj.isNew) {
                      return PhotoViewGalleryPageOptions.customChild(child: SfPdfViewer.file(File(obj.filePath)));
                    } else {
                      return PhotoViewGalleryPageOptions.customChild(child: SfPdfViewer.network(obj.filePath));
                    }
                  } else if (obj.fileType == NsgFilePickerObjectType.video) {
                    return PhotoViewGalleryPageOptions.customChild(child: NsgVideoPlayer(obj));
                  }
                  return PhotoViewGalleryPageOptions(
                    imageProvider: widget.imagesList[index].image!.image,
                    initialScale: PhotoViewComputedScale.contained * 0.9,
                    // heroAttributes: PhotoViewHeroAttributes(tag: imagesList[index].description),
                  );
                },
                itemCount: widget.imagesList.length,
                loadingBuilder: (context, event) => const NsgProgressBar(),
                backgroundDecoration: BoxDecoration(color: nsgtheme.colorModalBack),
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
                child: Icon(Icons.arrow_left_outlined, size: 48, color: nsgtheme.colorPrimary),
              ),
            ),
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
                child: Icon(Icons.arrow_right_outlined, size: 48, color: nsgtheme.colorPrimary),
              ),
            ),
          ],
        ),
        Text(_desc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
