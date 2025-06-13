import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _backgroundAnimationKey = 'background_animation_enabled';
  static const String _simpleAnimationKey = 'simple_animation_mode';
  
  // Background animation preferences
  static Future<bool> getBackgroundAnimationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_backgroundAnimationKey) ?? true; // Default: enabled
  }
  
  static Future<void> setBackgroundAnimationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backgroundAnimationKey, enabled);
  }
  
  // Simple animation mode (for performance)
  static Future<bool> getSimpleAnimationMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_simpleAnimationKey) ?? false; // Default: full animation
  }
  
  static Future<void> setSimpleAnimationMode(bool simple) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_simpleAnimationKey, simple);
  }
}
