import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/grocery_item.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(GroceryItemAdapter());
  }

  // Close boxes if they're already open
  if (Hive.isBoxOpen('groceries')) {
    await Hive.box('groceries').close();
  }
  if (Hive.isBoxOpen('grocery_items')) {
    await Hive.box('grocery_items').close();
  }

  // Open boxes with proper types
  await Hive.openBox('groceries');
  await Hive.openBox<GroceryItem>('grocery_items');
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Eat Me First',
          debugShowCheckedModeBanner: false,
          theme: themeService.isDark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDark
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
