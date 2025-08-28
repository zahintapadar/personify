import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInService {
  static const String _isSignedInKey = 'is_signed_in';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSignedInKey) ?? false;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        await _saveUserData(account);
      }
      return account;
    } catch (error) {
      print('Silent sign-in failed: $error');
      return null;
    }
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        await _saveUserData(account);
      }
      return account;
    } catch (error) {
      print('Sign-in failed: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _clearUserData();
    } catch (error) {
      print('Sign-out failed: $error');
    }
  }

  static Future<void> _saveUserData(GoogleSignInAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSignedInKey, true);
    await prefs.setString(_userNameKey, account.displayName ?? 'User');
    await prefs.setString(_userEmailKey, account.email);
  }

  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSignedInKey, false);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  static String getDisplayName() {
    if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }
    return 'User';
  }
}
