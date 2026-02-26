import 'package:badminton_app/app/router.dart';
import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/config/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  if (!kIsWeb) {
    await Firebase.initializeApp();
    await NaverMapSdk.instance.initialize(
      clientId: Env.naverMapClientId,
    );
  }

  runApp(
    const ProviderScope(
      child: GutAlimApp(),
    ),
  );
}

class GutAlimApp extends ConsumerWidget {
  const GutAlimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '거트알림',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
