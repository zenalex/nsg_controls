// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'nsg_controls_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class NsgControlsLocalizationsRu extends NsgControlsLocalizations {
  NsgControlsLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get search => 'Поиск';

  @override
  String get loading => 'Загрузка';

  @override
  String get prepare_photo => 'Подготовьте фотографию';

  @override
  String get save_photo => 'Сохранение фото';

  @override
  String get view_photo => 'Просмотр изображений';

  @override
  String get unsupported_format => 'неподдерживаемый формат';

  @override
  String file_size_exceeded(Object fileMaxSize) {
    return 'Превышен максимальный размер файла $fileMaxSize кБайт';
  }

  @override
  String get save_file => 'Сохранить файл';

  @override
  String get path_error => 'ошибка пути';

  @override
  String get failed_download => 'ошибка загрузки';

  @override
  String get failed_download_try_again =>
      'Ошибка загрузки файла. Попробуйте еще раз';

  @override
  String get error => 'Ошибка';

  @override
  String get save_files => 'Сохранение файлов';

  @override
  String get view_files => 'Просмотр файлов';

  @override
  String get add_photo => 'Добавить фото';

  @override
  String get upload_photo => 'Загрузите фотографию';

  @override
  String get add_photos => 'Добавление фотографий';

  @override
  String get save_photos => 'Сохранение фотографий';

  @override
  String get delete_photos => 'Удаление фотографии';

  @override
  String get delete_photo_warning =>
      'После удаления, фотографию нельзя будет восстановить. Удалить?';

  @override
  String get not_an_image_file => 'Этот файл не является изображением';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String photos_added(Object c) {
    return 'вы добавили $c фото';
  }

  @override
  String get select_date => 'Выберите дату';

  @override
  String get select_period => 'Выберите период';

  @override
  String get year => 'Год';

  @override
  String get quarter => 'Квартал';

  @override
  String get month => 'Месяц';

  @override
  String get week => 'Неделя';

  @override
  String get day => 'День';

  @override
  String get today => 'Сегодня';

  @override
  String get period => 'Период';

  @override
  String get tima => 'Время';

  @override
  String get text_filter => 'Фильтр по тексту';

  @override
  String get text_filter_unchanged => 'Фильтр по тексту не изменился';

  @override
  String get enter_time => 'Введите время';

  @override
  String get error_file_download => 'Ошибка скачивания файла';

  @override
  String get time => 'Время';

  @override
  String get saveChangesPrompt => 'Вы внесли изменения. Сохранить?';

  @override
  String get saveChangesOption => 'Вы можете сохранить изменения';

  @override
  String get continue_editing => 'продолжить редактирование';

  @override
  String get discardAndExit => 'или выйти назад без сохранения';

  @override
  String get exitWithoutSaving => 'Выйти без сохранения';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get are_you_sure => 'Вы уверены?';

  @override
  String get need_confirmation => 'Нужно подтверждение';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'Ок';

  @override
  String get empty_list => 'Пустой список';

  @override
  String there_are_count_elements_more_use_search(Object count) {
    return 'Есть еще $count элементов. Воспользуйтесь поиском.';
  }

  @override
  String get no_options_available => 'Нет доступных опций';

  @override
  String get date_filter => 'Фильтр по датам';

  @override
  String get all => 'Все';

  @override
  String get recent => 'Последние';

  @override
  String get favorites => 'Избранные';

  @override
  String get columns_not_set => 'Колонки (columns) не заданы для таблицы';

  @override
  String get unknown_display_type =>
      'Несуществующий тип отображения NsgListPage';

  @override
  String error_colon(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get period_filter => 'Фильтр по периоду';

  @override
  String get total => 'Итого';

  @override
  String get cell_data => 'Данные ячейки';

  @override
  String get copy_to_clipboard => 'Скопировать в буфер';

  @override
  String get cell_data_copied => 'Данные ячейки скопированы в буфер';

  @override
  String get add_row => 'Добавить строку';

  @override
  String get edit_row => 'Редактировать строку';

  @override
  String get copy_row => 'Копировать строку';

  @override
  String get delete_row => 'Удалить строку';

  @override
  String get refresh_table => 'Обновить таблицу';

  @override
  String get column_display => 'Отображение колонок';

  @override
  String get column_order_and_disable => 'Порядок и отключение колонок';

  @override
  String get drag_columns_to_reorder =>
      'Перетягивайте колонки, зажимая левую кнопку мыши, чтобы поменять последовательность колонок';

  @override
  String get user_settings_not_set => 'Не заданы настройки пользователя';

  @override
  String get column_width => 'Ширина колонок';

  @override
  String get apply => 'Применить';

  @override
  String delete_rows(Object count) {
    return 'Удаление строк ($count)';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get copy_row_dialog => 'Скопировать строку';

  @override
  String get edit_rows => 'Редактирование строк';

  @override
  String get confirm_delete_rows =>
      'Подтвердите, что хотите удалить следующие строки:';
}
