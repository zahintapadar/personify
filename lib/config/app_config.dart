class AppConfig {
  // Environment variables or compile-time constants
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Validation methods
  static bool get isConfigValid {
    return geminiApiKey.isNotEmpty && 
           supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty;
  }

  static String get configError {
    final missing = <String>[];
    if (geminiApiKey.isEmpty) missing.add('GEMINI_API_KEY');
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    
    if (missing.isEmpty) return '';
    return 'Missing required configuration: ${missing.join(', ')}';
  }
}
