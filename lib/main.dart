import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/app.dart';
import 'package:trip_wise_nepal/core/services/hive/hive_service.dart';
import 'package:trip_wise_nepal/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive database
  print('[DEBUG] main.dart: Initializing HiveService');
  await HiveService.instance.init();
  print('[DEBUG] main.dart: HiveService initialized');

  // Initialize SharedPreferences
  // This is required because SharedPreferences is async,
  // but Riverpod providers are sync by default.
  // So we initialize it here and override the provider.
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}