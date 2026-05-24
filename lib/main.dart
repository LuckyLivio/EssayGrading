import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/storage_service.dart';
import '../../data/providers/app_providers.dart';
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '申论批改官',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
