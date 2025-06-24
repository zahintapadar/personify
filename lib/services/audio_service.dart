import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _musicEnabledKey = 'background_music_enabled';
  static const String _musicVolumeKey = 'background_music_volume';
  
  static bool _isInitialized = false;
  static bool _isMusicEnabled = true;
  static double _volume = 0.3; // Default volume (30%)
  
  /// Initialize the audio service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load preferences
      await _loadPreferences();
      
      // Set up audio player
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      
      // Start background music if enabled
      if (_isMusicEnabled) {
        await _startBackgroundMusic();
      }
      
      _isInitialized = true;
      debugPrint('AudioService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }
  
  /// Load audio preferences
  static Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool(_musicEnabledKey) ?? true;
      _volume = prefs.getDouble(_musicVolumeKey) ?? 0.3;
    } catch (e) {
      debugPrint('Error loading audio preferences: $e');
      _isMusicEnabled = true;
      _volume = 0.3;
    }
  }
  
  /// Start playing background music
  static Future<void> _startBackgroundMusic() async {
    try {
      await _audioPlayer.play(AssetSource('audio/backgroundmusic.mp3'));
      debugPrint('Background music started');
    } catch (e) {
      debugPrint('Error starting background music: $e');
    }
  }
  
  /// Stop background music
  static Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
      debugPrint('Background music stopped');
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }
  
  /// Pause background music
  static Future<void> pauseBackgroundMusic() async {
    try {
      await _audioPlayer.pause();
      debugPrint('Background music paused');
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }
  
  /// Resume background music
  static Future<void> resumeBackgroundMusic() async {
    try {
      if (_isMusicEnabled) {
        await _audioPlayer.resume();
        debugPrint('Background music resumed');
      }
    } catch (e) {
      debugPrint('Error resuming background music: $e');
    }
  }
  
  /// Enable/disable background music
  static Future<void> setMusicEnabled(bool enabled) async {
    try {
      _isMusicEnabled = enabled;
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_musicEnabledKey, enabled);
      
      if (enabled) {
        await _startBackgroundMusic();
      } else {
        await stopBackgroundMusic();
      }
      
      debugPrint('Background music ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting music enabled: $e');
    }
  }
  
  /// Set music volume (0.0 - 1.0)
  static Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_musicVolumeKey, _volume);
      
      // Update player volume
      await _audioPlayer.setVolume(_volume);
      
      debugPrint('Music volume set to: ${(_volume * 100).round()}%');
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }
  
  /// Get current music enabled state
  static bool get isMusicEnabled => _isMusicEnabled;
  
  /// Get current volume
  static double get volume => _volume;
  
  /// Check if audio service is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Dispose audio resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isInitialized = false;
      debugPrint('AudioService disposed');
    } catch (e) {
      debugPrint('Error disposing AudioService: $e');
    }
  }
}
