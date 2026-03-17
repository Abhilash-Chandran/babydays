import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/activity_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/app_shell.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  final prefs = await SharedPreferences.getInstance();
  runApp(BabyDaysApp(storage: storage, prefs: prefs));
}

class BabyDaysApp extends StatelessWidget {
  final StorageService storage;
  final SharedPreferences prefs;

  const BabyDaysApp({super.key, required this.storage, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActivityProvider(storage)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
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
