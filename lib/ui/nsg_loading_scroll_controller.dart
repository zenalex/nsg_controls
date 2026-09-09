import 'package:flutter/material.dart';
import 'package:nsg_controls/ui/nsg_data_ui.dart';

class NsgLoadingScrollController<T> extends ScrollController {
  NsgLoadingScrollController({this.function, this.positionBeforeLoad = 200, this.attemptCount = 1}) : super(keepScrollOffset: true) {
    addListener(() async {
      try {
        // Нельзя вызывать [position] / [offset] при positions.length != 1 (переход между экранами).
        if (positions.length != 1) {
          return;
        }
        final p = positions.first;
        // Содержимое списка изменилось - значит предыдущая подгрузка что-то
        // принесла (или список перечитали целиком), и счётчик попыток пора
        // обнулить. Это единственный сброс, который работает на КОРОТКОМ списке:
        // ветка по позиции (ниже) требует уйти от низа дальше чем на
        // [positionBeforeLoad], а при maxScrollExtent < positionBeforeLoad правая
        // часть её условия отрицательна, тогда как pixels снизу ограничен
        // minScrollExtent, - недостижимо ни при какой прокрутке.
        //
        // Сравнивается ПРЕДЫДУЩИЙ замер, и годится изменение в любую сторону:
        // после refreshData запас прокрутки схлопывается обратно к первой
        // странице, и требовать здесь именно роста значило бы намертво запереть
        // счётчик, если новая выборка тоже короче порога.
        //
        // А вот привязывать сброс к самому факту завершения загрузки нельзя:
        // холостой вызов, который ничего не принёс, тоже завершается успехом, а
        // сеттер статуса зовёт notifyListeners, то есть этого же слушателя, -
        // вышла бы вечная карусель таймеров нулевой длины. Изменение запаса
        // прокрутки как раз и отличает сделанную работу от холостой.
        if (_lastMaxExtent != p.maxScrollExtent) {
          _attCount = 0;
          _errCount = 0;
          _lastMaxExtent = p.maxScrollExtent;
        }
        if (_attCount < attemptCount &&
            _stat != NsgLoadingScrollStatus.loading &&
            _stat != NsgLoadingScrollStatus.pause &&
            (p.pixels >= p.maxScrollExtent - positionBeforeLoad)) {
          _stat = NsgLoadingScrollStatus.loading;
          try {
            _attCount++;
            if (function != null) {
              Future(function!).then((T val) {
                _value = val;
                _stat = NsgLoadingScrollStatus.success;
              }, onError: _failAttempt);
            } else {
              _stat = NsgLoadingScrollStatus.empty;
            }
          } catch (er, st) {
            _failAttempt(er, st);
          }
        } else if (!(p.pixels >= p.maxScrollExtent - positionBeforeLoad)) {
          _attCount = 0;
          _errCount = 0;
        }

        lastOffset = p.pixels;
      } catch (e) {
        // Handle cases where ScrollController is not properly attached
        // or has multiple positions
      }
    });
  }

  final T Function()? function;
  final double positionBeforeLoad;
  final int attemptCount;

  double lastOffset = 0;

  //Map<int, double> heightMap = {};
  DataGroupList dataGroups = DataGroupList([]);

  int _errCount = 0;
  int _attCount = 0;

  /// Запас прокрутки на предыдущем срабатывании слушателя. По его ИЗМЕНЕНИЮ
  /// видно, что содержимое списка обновилось, и счётчик попыток можно обнулять.
  double _lastMaxExtent = 0;

  /// Схлопывает несколько scheduleRestoreScrollOffsetAfterRebuild подряд (per-frame obx).
  int _restoreScrollSeq = 0;

  T? _value;

  T? get value => _value;
  set value(T? val) {
    value = val;
    statusChange.notifyListeners();
    notifyListeners();
  }

  String? error;
  NsgLoadingScrollStatus _status = NsgLoadingScrollStatus.init;
  set _stat(NsgLoadingScrollStatus value) {
    _status = value;
    statusChange.notifyListeners();
    notifyListeners();
  }

  NsgLoadingScrollStatus get _stat => _status;

  NsgLoadingScrollStatus get status => _status;

  stopUpdate() {
    _status = NsgLoadingScrollStatus.pause;
  }

  startUpdate() {
    _errCount = 0;
    _attCount = 0;
    _lastMaxExtent = 0;
    _status = NsgLoadingScrollStatus.init;
  }

  /// Неудачная попытка подгрузки.
  ///
  /// Из [NsgLoadingScrollStatus.loading] надо выйти при ЛЮБОМ исходе: пока
  /// статус loading, условие запуска закрыто независимо от счётчика попыток -
  /// список молчит навсегда, а потребители, которые по этому статусу рисуют
  /// крутилку (nsg_data_controller_ui, таблицы), показывают её вечно.
  /// Раньше сюда попадали только при СИНХРОННОМ броске и только начиная с
  /// четвёртой ошибки: у [Future.then] не было onError, и асинхронная ошибка
  /// уходила в никуда вместе со статусом.
  void _failAttempt(Object error, StackTrace stackTrace) {
    _errCount++;
    // Порог в три ошибки - замысел исходного кода, он сохранён: рябь сети даёт
    // право на следующую попытку, устойчивый отказ переводит список в error.
    // Изменилось только то, что из loading выходят ОБЕ ветки, а не одна.
    _stat = _errCount > 3 ? NsgLoadingScrollStatus.error : NsgLoadingScrollStatus.success;
  }

  /// Восстановить [lastOffset] после пересборки списка. Без [position] при 0/2+ Scrollable; один jumpTo на серию rebuild.
  void scheduleRestoreScrollOffsetAfterRebuild() {
    final seq = ++_restoreScrollSeq;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (seq != _restoreScrollSeq) return;
        try {
          if (!hasClients || positions.length != 1) return;
          final target = lastOffset;
          if (target <= 0) return;
          final max = positions.first.maxScrollExtent;
          if (max <= 0) return;
          jumpTo(target.clamp(0.0, max));
        } catch (_) {}
      });
    });
  }

  // void scrollToIndex(int index) {
  //   double position = 0;
  //   for (int i = 0; i < index; i++) {
  //     position += heightMap[i] ?? 0;
  //   }
  //   animateTo(
  //     position,
  //     duration: const Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  Future<void> scrollToIndex(int targetIndex) async {
    if (targetIndex == -1) {
      return;
    }
    while (true) {
      final key = dataGroups.itemsKeys[targetIndex];
      if (key == null) {
        await Future.delayed(const Duration(milliseconds: 50));
        continue;
      }

      final context = key.currentContext;
      if (context != null && context.mounted) {
        await Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
        break;
      } else {
        if (positions.length == 1) {
          await animateTo(positions.first.pixels + 400, duration: const Duration(milliseconds: 1), curve: Curves.linear);
        }
      }
      if (positions.length == 1) {
        final p = positions.first;
        if (p.pixels >= p.maxScrollExtent) {
          break;
        }
      }
    }
  }

  double middleHeight(List<double> list, double delta) {
    if (list.isEmpty) return 0;

    final Map<double, int> counts = {};

    for (var item in list) {
      bool found = false;

      for (var key in counts.keys) {
        if ((item - key).abs() <= delta) {
          counts[key] = counts[key]! + 1;
          found = true;
          break;
        }
      }

      if (!found) {
        counts[item] = 1;
      }
    }

    int maxCount = counts.values.reduce((a, b) => a > b ? a : b);

    List<double> freqList = counts.entries.where((entry) => entry.value == maxCount).map((entry) => entry.key).toList();

    if (freqList.isEmpty) return 0;
    final sum = freqList.reduce((a, b) => a + b);
    return sum / freqList.length;
  }

  ChangeNotifier statusChange = ChangeNotifier();
}

enum NsgLoadingScrollStatus { loading, success, empty, pause, error, init }
