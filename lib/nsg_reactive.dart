import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/dialog/nsg_future_progress_exception.dart';
import 'package:nsg_data/nsg_data.dart';

mixin NsgPartiallyUpdatable<T extends NsgDataItem> on NsgDataController<T> {
  void setStatusAndNotify(GetStatus<NsgBaseControllerData> status) {
    currentStatus = status;
    sendNotify();
  }

  Future<void> handleAndUpdate<R extends dynamic>(Future<R> Function() func) async {
    setStatusAndNotify(GetStatus.loading());
    var res = await func();
    if (res is GetStatus<NsgBaseControllerData>) {
      setStatusAndNotify(res);
    } else {
      setStatusAndNotify(GetStatus.success(NsgBaseController.emptyData));
    }
  }

  Future<void> handleAndUpdateSync<R extends dynamic>(R Function() func) async {
    setStatusAndNotify(GetStatus.loading());
    var res = func();
    if (res is GetStatus<NsgBaseControllerData>) {
      setStatusAndNotify(res);
    } else {
      setStatusAndNotify(GetStatus.success(NsgBaseController.emptyData));
    }
  }

  Future<void> progressAndUpdate<R extends dynamic>(Future<R> Function() func) async {
    await handleAndUpdate(
      () async => await nsgFutureProgressAndException(
        func: () async {
          await func();
        },
      ),
    );
  }
}

mixin NsgResettable<T> on NsgDataController {
  refreshAndUpdate(T item);
}

mixin class StatusController {
  final TrackedNotifier<bool> _status = TrackedNotifier(true);
  bool get isReady => _status.value;
  set isReady(bool newValue) => _status.value = newValue;

  final Map<String, ControllableNotifier> _listeners = {};

  void dispose() {
    for (ControllableNotifier listener in _listeners.values) {
      listener.dispose();
    }
  }

  /// default - все slb или кастомные namespace
  void notify({List<String>? namespace}) {
    namespace ??= ['default'];
    for (String field in namespace) {
      if (_listeners.containsKey(field)) _listeners[field]!.notify();
    }
  }

  /// Sync Listener Builder. Все slb слушают listener default namespace + те, которые вы укажите в агрументе
  Widget slb(Widget Function(BuildContext context) func, {List<String>? namespace}) {
    if (namespace == null) {
      namespace = ['default'];
    } else {
      namespace = [...namespace, 'default'];
    }
    List<Listenable> listeners = [];
    for (String field in namespace) {
      if (!_listeners.containsKey(field)) {
        _listeners[field] = ControllableNotifier();
      }
      listeners.add(_listeners[field]!);
    }

    return TrackedBuilder(
      builder: (context) {
        if (isReady) {
          return ListenableBuilder(listenable: Listenable.merge(listeners), builder: (context, child) => func(context));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Async Listener Builder
  // Widget alb(Future<Widget> Function(BuildContext context) func, {bool processOnBuild = false}) {
  //   if (processOnBuild) {
  //     return slb((context) {
  //       var res = func(context);
  //       return FutureBuilder(
  //         future: res,
  //         builder: (c, s) {
  //           if (s.hasData) {
  //             return s.data!;
  //           } else if (s.hasError) {
  //             return Text('loading');
  //           } else {
  //             return Text('loading');
  //           }
  //         },
  //       );
  //     });
  //   } else {
  //     var res = func();
  //     return FutureBuilder(
  //       future: res,
  //       builder: (c, s) {
  //         if (s.hasData) {
  //           return slb(() => s.data!);
  //         } else if (s.hasError) {
  //           return Text('loading');
  //         } else {
  //           return Text('loading');
  //         }
  //       },
  //     );
  //   }
  // }
}

class ControllableNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class TrackedBuilder extends DataListener {
  final Widget Function(BuildContext context) builder;
  const TrackedBuilder({super.key, required this.builder});

  @override
  State<StatefulWidget> createState() => _TrackedBuilderState();
}

class _TrackedBuilderState extends DataListenerState<TrackedBuilder> {
  @override
  Widget buildReactive(BuildContext context) {
    return widget.builder(context);
  }
}

/// Reactive notifier
class TrackedNotifier<T> extends ValueNotifier<T> {
  TrackedNotifier(super.value);

  static final List<Set<TrackedNotifier<dynamic>>> _trackedNotifierStack = [];

  static void startTracking() {
    _trackedNotifierStack.add(<TrackedNotifier<dynamic>>{});
  }

  static Set<TrackedNotifier<dynamic>> stopTracking() {
    if (_trackedNotifierStack.isEmpty) return {};
    return _trackedNotifierStack.removeLast();
  }

  @override
  T get value {
    if (_trackedNotifierStack.isNotEmpty) {
      _trackedNotifierStack.last.add(this);
    }
    return super.value;
  }
}

/// Reactive widget
abstract class DataListener extends StatefulWidget {
  const DataListener({super.key});
}

abstract class DataListenerState<T extends DataListener> extends State<T> {
  final Set<TrackedNotifier<dynamic>> _subscriptions = {};
  Widget? currentWidget;

  void _onChange() {
    if (!mounted) return;
    setState(() => currentWidget = null);
  }

  @override
  void dispose() {
    for (var notifier in _subscriptions) {
      notifier.removeListener(_onChange);
    }
    super.dispose();
  }

  Widget buildReactive(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return currentWidget ?? _buildAndListen(context);
  }

  Widget _buildAndListen(BuildContext context) {
    for (var notifier in _subscriptions) {
      notifier.removeListener(_onChange);
    }

    TrackedNotifier.startTracking();
    final result = buildReactive(context);
    final tracked = TrackedNotifier.stopTracking();

    _subscriptions.clear();
    _subscriptions.addAll(tracked);
    for (var notifier in _subscriptions) {
      notifier.addListener(_onChange);
    }

    currentWidget = result;
    return result;
  }
}
