import 'package:flutter/material.dart';
import 'package:nsg_controls/nsg_control_options.dart';

class NsgSimpleTabsTabIcon {
  NsgSimpleTabsTabIcon({required this.icon, this.onTap});
  final IconData icon;
  final void Function()? onTap;

  Widget get widget {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, color: nsgtheme.colorBase.c100, size: nsgtheme.sizeS),
      ),
    );
  }
}
