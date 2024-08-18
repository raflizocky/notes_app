import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notes_app/services/supabase_service.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:notes_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "./dotenv");
  await SupabaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
