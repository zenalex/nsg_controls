import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'nsg_file_picker_object.dart';

class NsgVideoPlayer extends StatefulWidget {
  final NsgFilePickerObject fileObject;
  const NsgVideoPlayer(this.fileObject, {super.key});

  @override
  State<NsgVideoPlayer> createState() => NsgVideoPlayerState();
}

class NsgVideoPlayerState extends State<NsgVideoPlayer> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    if (widget.fileObject.isNew) {
      controller = VideoPlayerController.file(File(widget.fileObject.filePath));
    } else {
      controller = VideoPlayerController.network(widget.fileObject.filePath);
    }
    controller.initialize().then((value) {
      if (controller.value.isInitialized) {
        controller.play();
        setState(() {});
      }
    }).catchError((e) {
      print("controller.initialize() error occurs: $e");
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(controller);
  }
}
