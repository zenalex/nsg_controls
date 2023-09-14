import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:controls_examples/model/generated/irrigation_row.g.dart';
import 'package:controls_examples/model/irrigation_row.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import 'controllers/irrigation_row_controller.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  var controller = Get.find<IrrigationRowController>();
  ScrollController hController = ScrollController();
  ScrollController vController = ScrollController();
  late ScrollableDetails horizontalDetails;
  late ScrollableDetails verticalDetails;

  @override
  void initState() {
    horizontalDetails = ScrollableDetails.horizontal(controller: hController);
    verticalDetails = ScrollableDetails.vertical(controller: vController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BodyWrap(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'CONTROLS EXAMPLES',
                style: TextStyle(fontSize: nsgtheme.sizeH1),
              ),
            ),
            Expanded(child: controller.obx((state) => showTable())),
            Expanded(
                child: TwoDimensionalScrollable(
              horizontalDetails: horizontalDetails,
              verticalDetails: verticalDetails,
              viewportBuilder: (context, verticalPosition, horizontalPosition) {
                return Container(decoration: const BoxDecoration(color: Colors.red), width: 800, height: 1800, child: const Text('data'));
              },
            )),
            // Expanded(
            //   child: TwoDimensionalGridView(
            //     diagonalDragBehavior: DiagonalDragBehavior.free,
            //     delegate: TwoDimensionalChildBuilderDelegate(
            //         maxXIndex: 999,
            //         maxYIndex: 999,
            //         builder: (BuildContext context, ChildVicinity vicinity) {
            //           return Container(
            //             color: vicinity.xIndex.isEven && vicinity.yIndex.isEven
            //                 ? Colors.amber[50]
            //                 : (vicinity.xIndex.isOdd && vicinity.yIndex.isOdd ? Colors.purple[50] : null),
            //             height: 200,
            //             width: 200,
            //             child: Center(child: Text('Row ${vicinity.xIndex}: Column ${vicinity.yIndex}')),
            //           );
            //         }),
            //   ),
            // ),
            button()
          ],
        ),
      ),
    );
  }

  Widget showTable() {
    List<NsgTableColumn> columns = [
      NsgTableColumn(name: IrrigationRowGenerated.nameDay, presentation: 'День', width: 400),
      NsgTableColumn(name: IrrigationRowGenerated.nameHour, presentation: 'Час', width: 400)
    ];
    return NsgTable(columns: columns, controller: controller);
  }

  Widget button() {
    return NsgButton(
      width: 200,
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      text: 'Добавить 5 строк',
      onPressed: () {
        for (var i = 0; i < 5; i++) {
          IrrigationRow item = IrrigationRow();
          item.newRecord();
          item.day = Random().nextInt(7);
          item.hour = Random().nextInt(24);
          controller.items.add(item);
        }
        controller.sendNotify();
      },
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  Widget buildViewport(BuildContext context, ViewportOffset verticalOffset, ViewportOffset horizontalOffset) {
    return SimpleBuilderTableViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class SimpleBuilderTableViewport extends TwoDimensionalViewport {
  const SimpleBuilderTableViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderSimpleBuilderTableViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSimpleBuilderTableViewport renderObject) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderSimpleBuilderTableViewport extends RenderTwoDimensionalViewport {
  RenderSimpleBuilderTableViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate = delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex;
    final int maxColumnIndex;
    maxRowIndex = builderDelegate.maxYIndex!;
    maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = math.max((horizontalPixels / 200).floor(), 0);
    final int leadingRow = math.max((verticalPixels / 200).floor(), 0);
    final int trailingColumn = math.min(
      ((horizontalPixels + viewportWidth) / 200).ceil(),
      maxColumnIndex,
    );
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / 200).ceil(),
      maxRowIndex,
    );

    double xLayoutOffset = (leadingColumn * 200) - horizontalOffset.pixels;
    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset = (leadingRow * 200) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity = ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.tighten(width: 200.0, height: 200.0));

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += 200;
      }
      xLayoutOffset += 200;
    }
    final double verticalExtent = 200 * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );
    final double horizontalExtent = 200 * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
