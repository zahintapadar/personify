import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'audio_service.dart';

class AppPreferences {
  static const String _backgroundAnimationKey = 'background_animation_enabled';
  static const String _simpleAnimationKey = 'simple_animation_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _musicEnabledKey = 'background_music_enabled';
  static const String _musicVolumeKey = 'background_music_volume';
  
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
  
  // Notification preferences
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default: enabled
  }
  
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    await NotificationService.setNotificationsEnabled(enabled);
  }
  
  // Music preferences
  static Future<bool> getMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true; // Default: enabled
  }
  
  static Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, enabled);
    await AudioService.setMusicEnabled(enabled);
  }
  
  static Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_musicVolumeKey) ?? 0.3; // Default: 30%
  }
  
  static Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, volume);
    await AudioService.setVolume(volume);
  }
}
