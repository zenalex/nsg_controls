# NSG Controls

[![pub package](https://img.shields.io/pub/v/nsg_controls.svg)](https://pub.dev/packages/nsg_controls)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Набор UI компонентов для быстрого создания приложений на основе пакета [nsg_data](https://pub.dev/packages/nsg_data). Пакет предоставляет готовые виджеты для работы с данными, формами, таблицами и другими элементами интерфейса.

## 🚀 Возможности

- **Формы и поля ввода**: Готовые компоненты для создания форм с валидацией
- **Таблицы**: Продвинутые таблицы с сортировкой, фильтрацией и редактированием
- **Диалоги**: Модальные окна, прогресс-диалоги и всплывающие меню
- **Навигация**: Табы, списки страниц и навигационные элементы
- **Файловый пикер**: Загрузка и обработка файлов с предварительным просмотром
- **Локализация**: Поддержка русского и английского языков
- **Адаптивность**: Responsive дизайн для различных размеров экранов

## 📦 Установка

Добавьте зависимость в ваш `pubspec.yaml`:

```yaml
dependencies:
  nsg_controls: ^1.0.0-beta.1
  nsg_data: ^1.0.0
```

Затем выполните:

```bash
flutter pub get
```

## 🎯 Основные компоненты

### Формы и поля ввода

```dart
import 'package:nsg_controls/nsg_controls.dart';

// Текстовое поле
NsgInput(
  label: 'Имя',
  controller: nameController,
  validator: (value) => value?.isEmpty == true ? 'Обязательное поле' : null,
)

// Выбор даты
NsgDatePicker(
  label: 'Дата рождения',
  controller: dateController,
)

// Выбор времени
NsgTimePicker(
  label: 'Время',
  controller: timeController,
)

// Выпадающий список
NsgDropdownMenu(
  label: 'Город',
  items: cities,
  onChanged: (value) => print('Выбран: $value'),
)
```

### Таблицы

```dart
// Простая таблица
NsgSimpleTable(
  columns: [
    NsgTableColumn(title: 'Имя', field: 'name'),
    NsgTableColumn(title: 'Возраст', field: 'age'),
    NsgTableColumn(title: 'Город', field: 'city'),
  ],
  data: users,
  onRowTap: (user) => print('Выбран: ${user.name}'),
)

// Таблица с редактированием
NsgTable(
  columns: columns,
  data: data,
  editMode: true,
  onSave: (item) => saveUser(item),
)
```

### Диалоги

```dart
// Простой диалог
showNsgDialog(
  context: context,
  title: 'Подтверждение',
  content: 'Вы уверены?',
  actions: [
    NsgButton(
      text: 'Отмена',
      onPressed: () => Navigator.pop(context),
    ),
    NsgButton(
      text: 'ОК',
      onPressed: () => confirmAction(),
    ),
  ],
)

// Прогресс диалог
showNsgProgressDialog(
  context: context,
  message: 'Загрузка данных...',
)
```

### Списки и навигация

```dart
// Список страниц
NsgListPage(
  title: 'Пользователи',
  dataController: usersController,
  itemBuilder: (context, user) => UserCard(user: user),
)

// Табы
NsgSimpleTabs(
  tabs: [
    NsgSimpleTabsTab(title: 'Информация', child: InfoWidget()),
    NsgSimpleTabsTab(title: 'Настройки', child: SettingsWidget()),
  ],
)
```

### Файловый пикер

```dart
NsgFilePicker(
  onFileSelected: (file) {
    print('Выбран файл: ${file.name}');
  },
  allowedExtensions: ['jpg', 'png', 'pdf'],
  maxFileSize: 10 * 1024 * 1024, // 10MB
)
```

## 🎨 Кастомизация

### Темы и стили

```dart
// Настройка цветов
NsgControlOptions(
  primaryColor: Colors.blue,
  secondaryColor: Colors.grey,
  errorColor: Colors.red,
)

// Кастомные стили для кнопок
NsgButton(
  text: 'Кастомная кнопка',
  style: NsgButtonStyle(
    backgroundColor: Colors.green,
    textColor: Colors.white,
    borderRadius: 8,
  ),
)
```

### Локализация

```dart
// Поддержка русского и английского языков
MaterialApp(
  localizationsDelegates: [
    NsgControlsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    const Locale('ru', 'RU'),
    const Locale('en', 'US'),
  ],
)
```

## 📱 Примеры

Полные примеры использования доступны в папке [example/controls_examples](example/controls_examples/).

## 🔧 Требования

- Flutter: >=1.17.0
- Dart SDK: >=3.8.1
- nsg_data: ^1.0.0

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 🤝 Поддержка

Если у вас есть вопросы или предложения:

- Email: zenalex@nsgsoft.com
- Telegram: @zenalex
- GitHub Issues: [Создать issue](https://github.com/zenalex/nsg_controls/issues)

## 📈 Версии

См. [CHANGELOG.md](CHANGELOG.md) для истории изменений.

---

**Автор**: NSG (zenkov25@gmail.com)
