import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/google_sign_in_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool _isLoading = false;
  String _userName = 'User';
  String _userEmail = '';
  GoogleSignInAccount? _currentUser;

  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  GoogleSignInAccount? get currentUser => _currentUser;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user was previously signed in
      _isSignedIn = await GoogleSignInService.isSignedIn();
      
      if (_isSignedIn) {
        // Try to sign in silently
        final account = await GoogleSignInService.signInSilently();
        if (account != null) {
          _currentUser = account;
          _userName = account.displayName ?? 'User';
          _userEmail = account.email;
        } else {
          // Silent sign-in failed, user needs to sign in again
          _isSignedIn = false;
          await _loadStoredUserData();
        }
      }
    } catch (error) {
      print('Auth initialization error: $error');
      _isSignedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStoredUserData() async {
    _userName = await GoogleSignInService.getUserName() ?? 'User';
    _userEmail = await GoogleSignInService.getUserEmail() ?? '';
  }

  Future<bool> signIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      final account = await GoogleSignInService.signIn();
      if (account != null) {
        _isSignedIn = true;
        _currentUser = account;
        _userName = account.displayName ?? 'User';
        _userEmail = account.email;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (error) {
      print('Sign-in error: $error');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await GoogleSignInService.signOut();
      _isSignedIn = false;
      _currentUser = null;
      _userName = 'User';
      _userEmail = '';
    } catch (error) {
      print('Sign-out error: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  String getDisplayName() {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    return 'User';
  }
}
