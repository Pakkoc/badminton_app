import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/config/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: GutAlimApp(),
    ),
  );
}

class GutAlimApp extends StatelessWidget {
  const GutAlimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '거트알림',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('거트알림'),
        ),
      ),
    );
  }
}
