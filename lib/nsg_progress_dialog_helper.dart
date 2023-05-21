import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';
import 'package:path/path.dart';

class NsgProgressDialogHelper {
  BuildContext context;
  bool showProgress;
  bool isStoppable;
  NsgCancelToken? cancelToken;
  NsgProgressDialog? progress;

  NsgProgressDialogHelper(this.context, {this.isStoppable = false, this.showProgress = false, String? textDialog}) {
    if (showProgress) {
      cancelToken = isStoppable ? NsgCancelToken() : null;
      progress = NsgProgressDialog(canStopped: isStoppable, requestStop: () => true, cancelToken: cancelToken, textDialog: textDialog ?? 'Сохранение данных');
      progress!.show(context);
    }
  }

  Future show() async {
    progress!.show(context);
  }

  void hide() {
    if (progress != null) {
      progress!.hide();
    }
  }
}
