// lib/core/services/pwa_interop_web.dart
import 'dart:developer' as dev;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// Access the global 'window' or 'globalThis'
@JS('globalThis')
external JSObject get _globalThis;

void initPwaInterop(void Function() onInstallable) {
  // Set the property on the global object using js_interop_unsafe
  _globalThis.setProperty('onBeforeInstallPrompt'.toJS, onInstallable.toJS);
}

Future<bool> installPwaApp() async {
  try {
    // Call the global 'installPWA' function
    final JSPromise<JSBoolean>? promise = _globalThis.callMethod(
      'installPWA'.toJS,
    );
    if (promise == null) return false;

    final result = await promise.toDart;
    return result.toDart;
  } catch (e, st) {
    dev.log('Error during PWA installation', error: e, stackTrace: st, name: 'PwaInteropWeb');
    return false;
  }
}

bool isPwaInstallableApp() {
  try {
    // Call the global 'isPWAInstallable' function
    final JSBoolean? installable = _globalThis.callMethod(
      'isPWAInstallable'.toJS,
    );
    return installable?.toDart ?? false;
  } catch (e, st) {
    dev.log('Error checking PWA installability', error: e, stackTrace: st, name: 'PwaInteropWeb');
    return false;
  }
}
