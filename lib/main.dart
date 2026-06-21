import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_themes.dart';
import 'providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'providers/finance_provider.dart';
import 'data/local/hive_helper.dart';
import 'presentation/screens/main_navigation_holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.initHive();

  runApp(
    // MultiProvider lagaya taqe aik se zyada providers register ho sakein
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()..loadTransactions()),
        // Yeh double dot (..) operator app khulte hi automatic database load kar deta hai
      ],
      child: const FinTrackApp(),
    ),
  );
}

class FinTrackApp extends StatelessWidget{
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context){
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainNavigationHolder(),
    );
  }
}











