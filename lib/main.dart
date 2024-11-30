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
  Hive.registerAdapter(GroceryItemAdapter());
  await Hive.openBox<GroceryItem>('groceries');
  
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
    return MaterialApp(
      title: 'Eat Me First',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeService>().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
