import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

class SupabaseConfig {
  static String get url => AppConfig.supabaseUrl;
  static String get anonKey => AppConfig.supabaseAnonKey;

  // Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    if (!AppConfig.isConfigValid) {
      throw Exception('Supabase configuration error: ${AppConfig.configError}');
    }
    
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
