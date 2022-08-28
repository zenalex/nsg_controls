import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/nsg_data.dart';

class NsgProgressDialogHelper {
  bool showProgress;
  bool isStoppable;
  NsgCancelToken? cancelToken;
  NsgProgressDialog? progress;

  NsgProgressDialogHelper({this.isStoppable = false, this.showProgress = false}) {
    if (showProgress) {
      cancelToken = isStoppable ? NsgCancelToken() : null;
      progress = NsgProgressDialog(canStopped: true, requestStop: () => true, cancelToken: cancelToken);
      progress!.show();
    }
  }

  void hide() {
    if (progress != null) {
      progress!.hide();
    }
  }
}
