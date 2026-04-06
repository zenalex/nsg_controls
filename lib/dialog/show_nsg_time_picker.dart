import 'package:flutter/material.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/formfields/nsg_time_picker.dart';
import 'package:nsg_controls/helpers.dart';
import 'package:nsg_controls/nsg_button.dart';
import 'package:nsg_controls/nsg_control_options.dart';

Future<TimeOfDay?> showNsgTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  TimeOfDay? minimumTime,
  TimeOfDay? maximumTime,
  String? label,
}) async {
  final date = DateTime.now();
  TimeOfDay? selectedTime;
  ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  return await showNsgDialog<TimeOfDay>(
    context: context,
    child: ListenableBuilder(
      listenable: errorMessage,
      builder: (context, child) => Column(
        children: [
          TimePickerContent(
            initialTime: DateTime(date.year, date.month, date.day, initialTime.hour, initialTime.minute),
            onChange: (time) {
              selectedTime = TimeOfDay.fromDateTime(time);
            },
          ),
          if (errorMessage.value != null) Text(errorMessage.value!, style: TextStyle(color: nsgtheme.colorError)),
        ],
      ),
    ),
    buttons: [
      NsgButton(
        onPressed: () {
          if (selectedTime == null) {
            Navigator.of(context).pop();
            return;
          }
          if (minimumTime != null && !(selectedTime!.isAfter(minimumTime) || selectedTime!.isAtSameTimeAs(minimumTime))) {
            errorMessage.value = 'Time must be after ${minimumTime.format(context)}';
            return;
          }
          if (maximumTime != null && !(selectedTime!.isBefore(maximumTime) || selectedTime!.isAtSameTimeAs(maximumTime))) {
            errorMessage.value = 'Time must be before ${maximumTime.format(context)}';
            return;
          }
          Navigator.of(context).pop(selectedTime);
        },
        text: tranControls.confirm,
      ),
    ],
  );
}
