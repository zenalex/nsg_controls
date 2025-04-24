// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'nsg_controls_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NsgControlsLocalizationsEn extends NsgControlsLocalizations {
  NsgControlsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get prepare_photo => 'Prepare the Photo';

  @override
  String get save_photo => 'Save Photo';

  @override
  String get view_photo => 'View Photo';

  @override
  String get unsupported_format => 'unsupported format';

  @override
  String file_size_exceeded(Object fileMaxSize) {
    return 'File size exceeds the maximum limit of $fileMaxSize KB';
  }

  @override
  String get save_file => 'Save File';

  @override
  String get path_error => 'path error';

  @override
  String get failed_download => 'failed download';

  @override
  String get failed_download_try_again => 'Failed to download file try again';

  @override
  String get error => 'Error';

  @override
  String get save_files => 'Save files';

  @override
  String get view_files => 'View files';

  @override
  String get add_photo => 'Add photo';

  @override
  String get upload_photo => 'Upload Photo';

  @override
  String get add_photos => 'Add Photos';

  @override
  String get save_photos => 'Save photos';

  @override
  String get delete_photos => 'Delete photos';

  @override
  String get delete_photo_warning => 'Once deleted, the photo cannot be restored. Do you want to delete it?';

  @override
  String get not_an_image_file => 'This file is not an image';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String photos_added(Object c) {
    return 'You have added $c photo(s)';
  }

  @override
  String get select_date => 'Select Date';

  @override
  String get select_period => 'Select Period';

  @override
  String get year => 'Year';

  @override
  String get quarter => 'Quarter';

  @override
  String get month => 'Month';

  @override
  String get week => 'Week';

  @override
  String get day => 'Day';

  @override
  String get today => 'Today';

  @override
  String get period => 'Period';

  @override
  String get tima => 'Tima';

  @override
  String get text_filter => 'Text Filter';

  @override
  String get text_filter_unchanged => 'Text filter has not changed';

  @override
  String get enter_time => 'Enter Time';

  @override
  String get error_file_download => 'Error file download';

  @override
  String get time => 'Time';

  @override
  String get saveChangesPrompt => 'You have made changes. Save?';

  @override
  String get saveChangesOption => 'You can save the changes';

  @override
  String get continue_editing => 'Continue Editing';

  @override
  String get discardAndExit => 'or exit without saving';

  @override
  String get exitWithoutSaving => 'Exit Without Saving';

  @override
  String get confirm => 'Confirm';

  @override
  String get are_you_sure => 'Are you sure?';

  @override
  String get need_confirmation => 'Need confirmation';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'Ok';
}
