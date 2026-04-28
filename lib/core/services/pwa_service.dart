import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorto/core/services/pwa_constants.dart';
import 'package:sorto/shared/widgets/pwa_install_banner.dart';
import 'pwa_interop.dart';

export 'pwa_constants.dart';

final pwaServiceProvider = Provider((ref) => PWAService());

class PWAService {
  PWAService() {
    if (kIsWeb) {
      _init();
    }
  }

  final _installableController = StreamController<bool>.broadcast();
  Stream<bool> get installableStream => _installableController.stream;

  bool _isInstallable = false;
  bool get isInstallable => _isInstallable;

  void _init() {
    // Notify when prompt is ready
    initPwaInterop(() {
      _isInstallable = true;
      _installableController.add(true);
    });

    // Check initial state
    if (isPwaInstallableApp()) {
      _isInstallable = true;
      _installableController.add(true);
    }
  }

  Future<bool> install() async {
    if (!kIsWeb) return false;
    final success = await installPwaApp();
    if (success) {
      _isInstallable = false;
      _installableController.add(false);
    }
    return success;
  }

  void showInstallBanner(BuildContext context, {PwaBannerContext bannerContext = PwaBannerContext.generic, bool force = false}) async {
    if (!kIsWeb) return;
    if (!_isInstallable && !force) return;

    if (!force) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pwa_banner_seen_${bannerContext.name}';
      if (prefs.getBool(key) == true) return;
      await prefs.setBool(key, true);
    }

    if (context.mounted) {
      PwaInstallBanner.show(context, bannerContext: bannerContext);
    }
  }
}
