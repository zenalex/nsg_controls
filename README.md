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
  nsg_controls:
    path: ../path/to/nsg_controls
  nsg_data:
    path: ../path/to/nsg_data
```

Затем выполните:

```bash
flutter pub get
```

## 🎯 Основные компоненты

Все элементы ввода `NsgInput` работают поверх `NsgDataItem` / `NsgDataController`, поэтому совместимы и с REST-провайдером NSG, и с новым `serverpod`-адаптером из `nsg_data`.

### Цвета NsgInput из темы приложения

`NsgInputTheme` в `ThemeData.extensions` позволяет приложению задать цвета
текста, верхней подписи, подсказки, обычной рамки, рамки фокуса и значка очистки. Цвета следует
подбирать под фактический фон поля; extension сам не меняет фон и не вычисляет
контраст. Без extension или при `null` в отдельном слоте сохраняются прежние
цвета `ControlOptions`.

```dart
ThemeData(
  extensions: const [
    NsgInputTheme(
      textColor: Colors.black,
      labelColor: Colors.black,
      hintColor: Colors.black54,
      borderColor: Colors.black54,
      focusedBorderColor: Colors.deepPurple,
      clearIconColor: Colors.black,
    ),
  ],
)
```

Явные `textStyle`, `labelTextStyle`, `labelColor`, `labelWidget` и `borderColor`
сохраняют прежний приоритет и семантику. В частности, `borderColor` задаёт обычную
рамку, а рамка фокуса остаётся отдельным слотом. Явный `hint` использует
`hintColor`; `labelTextStyle` применяется к подсказке из `label`, как и прежде.
clearIconColor задаёт один цвет clear X в обычном состоянии и при наведении.
При null сохраняются оба прежних ControlOptions цвета и их порядок. Обработчик
очистки, обновление поля и фокуса не меняются.
Размеры, шрифты, ошибки валидации, заливки, курсор, остальные значки и пункты
выпадающих списков этим extension не меняются.

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

`NsgPeriodWidget` получает текст периода из `NsgTypedPeriod.dateText` (`nsg_data`)
по локали своего `BuildContext`. Формат «День» уже включает день недели;
повторно дописывать его в UI не нужно. В узкой строке автоматический текст дня
уменьшается до доступного места без увеличения на широких экранах.
Другие периоды и явно переданный `timeText` сохраняют прежнее отображение.

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

### Встроенный ввод времени на web/desktop

`NsgTimePicker` на web и desktop редактирует время в самом поле. Текст и курсор
не переписываются на каждом изменении; значение принимается при завершении
ввода или потере фокуса. В 24-часовом режиме `0950` принимается как `09:50`.
Неполный ввод и `24:00`/`12:60` не вызывают callback: действует строгий разбор
`NsgUserDate`, включая период суток в 12-часовых локалях. С `validator`
сохраняется прежняя семантика: при успехе вызывается `onValidTime`, иначе
`onClose`. Мобильные Material/Cupertino-пути остаются прежними.
