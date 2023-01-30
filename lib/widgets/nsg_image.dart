import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:nsg_data/controllers/nsgImageController.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgImage extends StatelessWidget {
  ///Элемент данных, поле которого отображаем в качестве картинки
  final bool masterSlaveMode;

  ///Имя поля-master объекта по значению которого будет осуществляться поиск в подчиненном контроллере
  ///item.masterFieldName == controller.item.id
  final String masterFieldName;

  ///Имя поля-slave объекта по значению которого будет осуществляться поиск в подчиненном контроллере
  final String slaveFieldName;

  ///Элемент данных, поле которого отображаем в качестве картинки
  ///или master элемент, по которому будет проиходить поиск элемента-картинки по связке detailField
  final NsgDataItem item;

  ///Имя поля-картинки для отображения
  final String fieldName;

  ///Контроллер загрузки картинок
  final NsgImageController controller;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? height;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color? color;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect? centerSlice;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;

  /// The rendering quality of the image.
  ///
  /// If the image is of a high quality and its pixels are perfectly aligned
  /// with the physical screen pixels, extra quality enhancement may not be
  /// necessary. If so, then [FilterQuality.none] would be the most efficient.
  ///
  /// If the pixels are not perfectly aligned with the screen pixels, or if the
  /// image itself is of a low quality, [FilterQuality.none] may produce
  /// undesirable artifacts. Consider using other [FilterQuality] values to
  /// improve the rendered image quality in this case. Pixels may be misaligned
  /// with the screen pixels as a result of transforms or scaling.
  ///
  /// See also:
  ///
  ///  * [FilterQuality], the enum containing all possible filter quality
  ///    options.
  final FilterQuality filterQuality;

  /// Виджет на время загрузки картинки
  final Widget? child;

  /// Виджет, если картинка не задана
  final Widget? noImage;

  NsgImage(
      {Key? key,
      this.masterSlaveMode = false,
      this.masterFieldName = '',
      this.slaveFieldName = '',
      required this.item,
      required this.fieldName,
      required this.controller,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.isAntiAlias = false,
      this.filterQuality = FilterQuality.low,
      this.child,
      this.noImage})
      : super(key: key) {
    if (masterSlaveMode) {
      assert(masterFieldName.isNotEmpty, 'Если задан режим master-slave, masterFieldName не может быть пустым');
    } else {
      assert(item.getField(fieldName) is NsgDataImageField);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.lateImageRead) {
      return lateRegime();
    } else {
      return syncRegime();
    }
  }

  ///Режим одновременной загрузки картинок
  Widget syncRegime() {
    return controller.obxBase((state) {
      NsgDataItem? imageItem = item;
      if (masterSlaveMode) {
        var slaveName = slaveFieldName;
        if (slaveName.isEmpty) {
          slaveName = NsgDataClient.client.getNewObject(controller.dataType).primaryKeyField;
        }
        if (controller.status.isLoading) {
          return const CircularProgressIndicator();
        }
        imageItem = controller.items.firstWhereOrNull((e) => e[slaveName] == item[masterFieldName]);
      }

      if (controller.lateImageRead && imageItem != null) {
        controller.addImageToQueue(ImageQueueParam(imageItem.id.toString(), fieldName));
      }

      if (imageItem == null || (imageItem[fieldName] as Uint8List).isEmpty) {
        return noImage ??
            SizedBox(
              width: width,
              height: height,
            );
      }
      var data = imageItem[fieldName] as Uint8List;
      if (data.isEmpty) {
        return noImage ??
            SizedBox(
              width: width,
              height: height,
            );
      } else {
        return FadeIn(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          child: Image.memory(
            data,
            width: width,
            height: height,
            color: color,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            centerSlice: centerSlice,
            isAntiAlias: isAntiAlias,
            filterQuality: filterQuality,
          ),
        );
      }
    }, onLoading: child);
  }

  ///Режим отложенной загрузки картинок
  Widget lateRegime() {
    return controller.obx(
      (c) {
        if (controller.status.isLoading) {
          return child ?? const CircularProgressIndicator();
        }
        NsgDataItem? imageItem = item;
        if (masterSlaveMode) {
          var slaveName = slaveFieldName;
          if (slaveName.isEmpty) {
            slaveName = NsgDataClient.client.getNewObject(controller.dataType).primaryKeyField;
          }
          if (controller.status.isLoading) {
            return const CircularProgressIndicator();
          }
          imageItem = controller.items.firstWhereOrNull((e) => e[slaveName] == item[masterFieldName] || e[slaveName] == (item[masterFieldName] + '.'));
        }

        if (controller.lateImageRead && imageItem != null && (imageItem[fieldName] as Uint8List).isEmpty) {
          controller.addImageToQueue(ImageQueueParam(imageItem.id.toString(), fieldName));
        }
        var builderId = imageItem == null ? '' : imageItem.id.toString();
        return GetBuilder(
            id: NsgUpdateKey(id: builderId, type: NsgUpdateKeyType.element),
            init: controller,
            global: false,
            //autoRemove: true,
            //assignId: true,
            builder: (c) {
              if (imageItem == null || (imageItem[fieldName] as Uint8List).isEmpty) {
                return noImage ??
                    SizedBox(
                      width: width,
                      height: height,
                    );
              }
              var data = imageItem[fieldName] as Uint8List;
              if (data.isEmpty) {
                return noImage ??
                    SizedBox(
                      width: width,
                      height: height,
                    );
              } else {
                return FadeIn(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  child: Image.memory(
                    data,
                    width: width,
                    height: height,
                    color: color,
                    fit: fit,
                    alignment: alignment,
                    repeat: repeat,
                    centerSlice: centerSlice,
                    isAntiAlias: isAntiAlias,
                    filterQuality: filterQuality,
                  ),
                );
              }
            });
      },
    );
  }

  // void vrem(){
  // var builderId = imageItem == null ? '':imageItem.id.toString();
  //     return GetBuilder(
  //        id: builderId,
  //        init: controller,
  //        builder: (c) {
  //         if (controller.status.isLoading){
  //           return const CircularProgressIndicator();
  //         }
  //        }
}
