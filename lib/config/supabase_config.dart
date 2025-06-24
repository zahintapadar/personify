import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://xerwnudnirafvoikwoyd.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlcndudWRuaXJhZnZvaWt3b3lkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwMzY2MDIsImV4cCI6MjA2MTYxMjYwMn0.U6OyuPf-nYxtb9DpPjjjAl2Zx5xxssJbvn7mvCGgfBE';

  // Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
