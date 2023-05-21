import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:nsg_data/nsg_data.dart';

abstract class NsgView<T extends NsgDataController> extends StatelessWidget with GetItMixin {
  NsgView({super.key});

  final String? tag = null;

  T get controller => get<T>();

  @override
  Widget build(BuildContext context);
}
