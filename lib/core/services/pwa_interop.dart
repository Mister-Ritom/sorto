// lib/core/services/pwa_interop.dart
export 'pwa_interop_stub.dart'
    if (dart.library.js_util) 'pwa_interop_web.dart';
