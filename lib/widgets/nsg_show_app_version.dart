import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../nsg_control_options.dart';

class NsgShowAppVersion extends StatefulWidget {
  final Color? color;
  const NsgShowAppVersion({super.key, this.color});

  @override
  State<NsgShowAppVersion> createState() => _NsgShowAppVersionState();
}

class _NsgShowAppVersionState extends State<NsgShowAppVersion> {
  PackageInfo _packageInfo = PackageInfo(appName: 'Unknown', packageName: 'Unknown', version: 'Unknown', buildNumber: 'Unknown', buildSignature: 'Unknown');

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(seconds: 1),
      child: Text('Версия: ${_packageInfo.version}', style: TextStyle(color: widget.color ?? ControlOptions.instance.colorMain)),
    );
  }
}
