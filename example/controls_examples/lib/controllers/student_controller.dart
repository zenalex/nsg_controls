import 'package:nsg_data/nsg_data.dart';

import '../model/student.dart';

class StudentController extends NsgDataController<Student> {
  StudentController() : super(requestOnInit: false, autoRepeate: true, autoRepeateCount: 10);

  @override
  Future afterRequestItems(List<NsgDataItem> newItemsList) async {
    if (newItemsList.isEmpty) {
      await createNewItemAsync();
    }
    return super.afterRequestItems(newItemsList);
  }
}
