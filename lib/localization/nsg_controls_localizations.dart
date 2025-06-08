import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'nsg_controls_localizations_en.dart';
import 'nsg_controls_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NsgControlsLocalizations
/// returned by `NsgControlsLocalizations.of(context)`.
///
/// Applications need to include `NsgControlsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/nsg_controls_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NsgControlsLocalizations.localizationsDelegates,
///   supportedLocales: NsgControlsLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the NsgControlsLocalizations.supportedLocales
/// property.
abstract class NsgControlsLocalizations {
  NsgControlsLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NsgControlsLocalizations? of(BuildContext context) {
    return Localizations.of<NsgControlsLocalizations>(
        context, NsgControlsLocalizations);
  }

  static const LocalizationsDelegate<NsgControlsLocalizations> delegate =
      _NsgControlsLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка'**
  String get loading;

  /// No description provided for @prepare_photo.
  ///
  /// In ru, this message translates to:
  /// **'Подготовьте фотографию'**
  String get prepare_photo;

  /// No description provided for @save_photo.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение фото'**
  String get save_photo;

  /// No description provided for @view_photo.
  ///
  /// In ru, this message translates to:
  /// **'Просмотр изображений'**
  String get view_photo;

  /// No description provided for @unsupported_format.
  ///
  /// In ru, this message translates to:
  /// **'неподдерживаемый формат'**
  String get unsupported_format;

  /// No description provided for @file_size_exceeded.
  ///
  /// In ru, this message translates to:
  /// **'Превышен максимальный размер файла {fileMaxSize} кБайт'**
  String file_size_exceeded(Object fileMaxSize);

  /// No description provided for @save_file.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить файл'**
  String get save_file;

  /// No description provided for @path_error.
  ///
  /// In ru, this message translates to:
  /// **'ошибка пути'**
  String get path_error;

  /// No description provided for @failed_download.
  ///
  /// In ru, this message translates to:
  /// **'ошибка загрузки'**
  String get failed_download;

  /// No description provided for @failed_download_try_again.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки файла. Попробуйте еще раз'**
  String get failed_download_try_again;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @save_files.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение файлов'**
  String get save_files;

  /// No description provided for @view_files.
  ///
  /// In ru, this message translates to:
  /// **'Просмотр файлов'**
  String get view_files;

  /// No description provided for @add_photo.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get add_photo;

  /// No description provided for @upload_photo.
  ///
  /// In ru, this message translates to:
  /// **'Загрузите фотографию'**
  String get upload_photo;

  /// No description provided for @add_photos.
  ///
  /// In ru, this message translates to:
  /// **'Добавление фотографий'**
  String get add_photos;

  /// No description provided for @save_photos.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение фотографий'**
  String get save_photos;

  /// No description provided for @delete_photos.
  ///
  /// In ru, this message translates to:
  /// **'Удаление фотографии'**
  String get delete_photos;

  /// No description provided for @delete_photo_warning.
  ///
  /// In ru, this message translates to:
  /// **'После удаления, фотографию нельзя будет восстановить. Удалить?'**
  String get delete_photo_warning;

  /// No description provided for @not_an_image_file.
  ///
  /// In ru, this message translates to:
  /// **'Этот файл не является изображением'**
  String get not_an_image_file;

  /// No description provided for @camera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get gallery;

  /// No description provided for @photos_added.
  ///
  /// In ru, this message translates to:
  /// **'вы добавили {c} фото'**
  String photos_added(Object c);

  /// No description provided for @select_date.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату'**
  String get select_date;

  /// No description provided for @select_period.
  ///
  /// In ru, this message translates to:
  /// **'Выберите период'**
  String get select_period;

  /// No description provided for @year.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get year;

  /// No description provided for @quarter.
  ///
  /// In ru, this message translates to:
  /// **'Квартал'**
  String get quarter;

  /// No description provided for @month.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get month;

  /// No description provided for @week.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get week;

  /// No description provided for @day.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get day;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @period.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get period;

  /// No description provided for @tima.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get tima;

  /// No description provided for @text_filter.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по тексту'**
  String get text_filter;

  /// No description provided for @text_filter_unchanged.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по тексту не изменился'**
  String get text_filter_unchanged;

  /// No description provided for @enter_time.
  ///
  /// In ru, this message translates to:
  /// **'Введите время'**
  String get enter_time;

  /// No description provided for @error_file_download.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка скачивания файла'**
  String get error_file_download;

  /// No description provided for @time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get time;

  /// No description provided for @saveChangesPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Вы внесли изменения. Сохранить?'**
  String get saveChangesPrompt;

  /// No description provided for @saveChangesOption.
  ///
  /// In ru, this message translates to:
  /// **'Вы можете сохранить изменения'**
  String get saveChangesOption;

  /// No description provided for @continue_editing.
  ///
  /// In ru, this message translates to:
  /// **'продолжить редактирование'**
  String get continue_editing;

  /// No description provided for @discardAndExit.
  ///
  /// In ru, this message translates to:
  /// **'или выйти назад без сохранения'**
  String get discardAndExit;

  /// No description provided for @exitWithoutSaving.
  ///
  /// In ru, this message translates to:
  /// **'Выйти без сохранения'**
  String get exitWithoutSaving;

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirm;

  /// No description provided for @are_you_sure.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены?'**
  String get are_you_sure;

  /// No description provided for @need_confirmation.
  ///
  /// In ru, this message translates to:
  /// **'Нужно подтверждение'**
  String get need_confirmation;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'Ок'**
  String get ok;

  /// No description provided for @empty_list.
  ///
  /// In ru, this message translates to:
  /// **'Пустой список'**
  String get empty_list;

  /// No description provided for @there_are_count_elements_more_use_search.
  ///
  /// In ru, this message translates to:
  /// **'Есть еще {count} элементов. Воспользуйтесь поиском.'**
  String there_are_count_elements_more_use_search(Object count);
}

class _NsgControlsLocalizationsDelegate
    extends LocalizationsDelegate<NsgControlsLocalizations> {
  const _NsgControlsLocalizationsDelegate();

  @override
  Future<NsgControlsLocalizations> load(Locale locale) {
    return SynchronousFuture<NsgControlsLocalizations>(
        lookupNsgControlsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_NsgControlsLocalizationsDelegate old) => false;
}

NsgControlsLocalizations lookupNsgControlsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return NsgControlsLocalizationsEn();
    case 'ru':
      return NsgControlsLocalizationsRu();
  }

  throw FlutterError(
      'NsgControlsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
