import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgProgressDialogHelper {
  bool showProgress;
  bool isStoppable;
  NsgCancelToken? cancelToken;
  NsgProgressDialog? progress;

  NsgProgressDialogHelper({this.isStoppable = false, this.showProgress = false, String? textDialog}) {
    if (showProgress) {
      cancelToken = isStoppable ? NsgCancelToken() : null;
      progress = NsgProgressDialog(canStopped: true, requestStop: () => true, cancelToken: cancelToken, textDialog: textDialog ?? 'Сохранение данных');
    }
  }

  Future show() async {
    progress!.show();
  }

  void hide() {
    if (progress != null) {
      progress!.hide();
    }
  }
}
