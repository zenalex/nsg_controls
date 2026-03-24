import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef NsgEventAction<S extends NsgState, R extends dynamic> = R Function(S event);
typedef NsgEventActionVoid<S extends NsgState> = NsgEventAction<S, void>;
typedef NsgEventBuilder<S extends NsgState> = Widget Function(BuildContext context, S event);

@immutable
abstract class NsgState {
  @mustBeOverridden
  NsgState copyWith();
}

@immutable
mixin NsgEventMixin<S extends NsgState> on NsgEvent<S> {
  S get state => stateN.value;

  set state(S newState) {
    stateN.value = newState;
  }

  S updateState(S newState) {
    state = newState;
    return state;
  }
}

class NsgEvent<S extends NsgState> {
  final ValueNotifier<S> stateN;
  NsgEvent({required S state}) : stateN = ValueNotifier(state);
}
