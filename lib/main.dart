import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_themes.dart';
import 'providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
      home: const SplashScreen(),
    );
  }




}











