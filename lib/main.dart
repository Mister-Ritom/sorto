// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorto/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait by default (can unlock on dare detail for landscape video)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080808),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  //if its dev env then use the local supabase url and anon key
  if (kDebugMode) {
    await Supabase.initialize(
      url: ApiConstants.supabaeDevUrl,
      anonKey: ApiConstants.supabaeDevAnonKey,
      debug: true,
    );
  } else {
    // Initialize Supabase
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
      debug: false,
    );
  }

  runApp(const ProviderScope(child: SortoApp()));
}
