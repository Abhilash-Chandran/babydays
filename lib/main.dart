import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'models/activity.dart';
import 'providers/activity_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/app_shell.dart';
import 'services/auth_service.dart';
import 'services/firestore_storage_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (always available as fallback).
  final localStorage = StorageService();
  await localStorage.init();
  final prefs = await SharedPreferences.getInstance();

  // Try to initialize Firebase — if it fails, fall back to local-only mode.
  AuthService? authService;
  FirestoreStorageService? firestoreStorage;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authService = AuthService();
    await authService.signInAnonymously();
    if (authService.userId != null) {
      final candidate = FirestoreStorageService(userId: authService.userId!);
      // Verify Firestore is reachable before committing to it.
      final available = await candidate.isAvailable();
      if (available) {
        firestoreStorage = candidate;
        // One-time migration: push local data to Firestore if we haven't yet.
        final migrated = prefs.getBool('firestore_migrated') ?? false;
        if (!migrated) {
          final dates = await localStorage.getTrackedDates();
          final allActivities = <Activity>[];
          for (final date in dates) {
            allActivities.addAll(
              await localStorage.getActivitiesForDate(date),
            );
          }
          if (allActivities.isNotEmpty) {
            try {
              await firestoreStorage.importActivities(allActivities);
              await prefs.setBool('firestore_migrated', true);
            } catch (_) {
              // Migration failed — keep local data, try again next launch.
              firestoreStorage = null;
            }
          } else {
            await prefs.setBool('firestore_migrated', true);
          }
        }
      }
    }
  } catch (_) {
    // Firebase not configured yet — continue with local storage.
  }

  runApp(
    BabyDaysApp(
      localStorage: localStorage,
      firestoreStorage: firestoreStorage,
      authService: authService,
      prefs: prefs,
    ),
  );
}

class BabyDaysApp extends StatelessWidget {
  final StorageService localStorage;
  final FirestoreStorageService? firestoreStorage;
  final AuthService? authService;
  final SharedPreferences prefs;

  const BabyDaysApp({
    super.key,
    required this.localStorage,
    this.firestoreStorage,
    this.authService,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(firestoreStorage ?? localStorage),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        if (authService != null)
          ChangeNotifierProvider.value(value: authService!),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          AppTheme.activePalette = themeProvider.palette;
          return MaterialApp(
            title: 'BabyDays',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.mode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
