class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const naverMapClientId = String.fromEnvironment(
    'NAVER_MAP_CLIENT_ID',
    defaultValue: '',
  );

  static const naverMapClientSecret = String.fromEnvironment(
    'NAVER_MAP_CLIENT_SECRET',
    defaultValue: '',
  );
}
