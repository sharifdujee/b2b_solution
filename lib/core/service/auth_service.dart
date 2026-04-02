import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  // --- Constants for SharedPreferences Keys ---
  static const String _tokenKey = 'token';
  static const String _userRoleKey = "userRole";
  static const String _isSetUpKey = "isSetUp";
  static const String _userIdKey = "userId";
  static const String _isProfileSetupKey = "isProfileSetup";
  static const String _otpKey = "otp";
  static const String _resetMessageKey = "resetMessage";
  static const String _forgetTokenKey = "forgetToken";

  // --- Singleton instance ---
  static late SharedPreferences _preferences;

  // --- Private variables to hold values in memory ---
  static String? _token;
  static String? _userRole;
  static bool? _userSetUp;
  static String? _id;
  static bool? _isProfileSetup;
  static String? _otp;
  static String? _message;
  static String? _fToken;

  // Initialize SharedPreferences (call this in main.dart)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    // Load data from SharedPreferences into private variables using the KEYS
    _token = _preferences.getString(_tokenKey);
    _userRole = _preferences.getString(_userRoleKey);
    _userSetUp = _preferences.getBool(_isSetUpKey);
    _id = _preferences.getString(_userIdKey);
    _isProfileSetup = _preferences.getBool(_isProfileSetupKey);
    _otp = _preferences.getString(_otpKey);
    _message = _preferences.getString(_resetMessageKey);
    _fToken = _preferences.getString(_forgetTokenKey);
  }

  // --- Saver Methods ---

  static Future<void> saveForgetToken(String token) async {
    try {
      await _preferences.setString(_forgetTokenKey, token);
      _fToken = token;
      log("Forget token saved: $token");
    } catch (e) {
      log('Error saving forget token: $e');
    }
  }

  static Future<void> saveResetPasswordMessage(String message) async {
    try {
      await _preferences.setString(_resetMessageKey, message);
      _message = message;
    } catch (e) {
      log('Error saving reset message: $e');
    }
  }


  static Future<void> saveToken(String token) async {
    try {
      await _preferences.setString(_tokenKey, token);
      _token = token;
    } catch (e) {
      log('Error saving token: $e');
    }
  }

  static Future<void> saveId(String id) async {
    try {
      await _preferences.setString(_userIdKey, id);
      _id = id;
    } catch (e) {
      log('Error saving id: $e');
    }
  }

  static Future<void> saveRole(String role) async {
    try {
      await _preferences.setString(_userRoleKey, role);
      _userRole = role;
    } catch (e) {
      log('Error saving role: $e');
    }
  }

  static Future<void> saveStatus(bool setUp) async {
    try {
      await _preferences.setBool(_isSetUpKey, setUp);
      _userSetUp = setUp;
    } catch (e) {
      log('Error saving status: $e');
    }
  }

  static Future<void> saveProfileSetup(bool isSetup) async {
    try {
      await _preferences.setBool(_isProfileSetupKey, isSetup);
      _isProfileSetup = isSetup;
    } catch (e) {
      log('Error saving profile setup status: $e');
    }
  }

  // --- Auth Utilities ---

  static bool hasToken() {
    return _preferences.containsKey(_tokenKey);
  }

  static Future<void> logoutUser(BuildContext context) async {
    try {
      await deleteTokenRole();
      if (context.mounted) {
        context.go("/login");
      }
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  static Future<void> deleteTokenRole() async {
    try {
      // Clear specific keys
      final keysToRemove = [
        _tokenKey,
        _userRoleKey,
        _isSetUpKey,
        _userIdKey,
        _isProfileSetupKey,
        _otpKey,
        _forgetTokenKey,
        _resetMessageKey
      ];

      for (var key in keysToRemove) {
        await _preferences.remove(key);
      }

      // Reset in-memory variables
      _token = null;
      _userRole = null;
      _userSetUp = null;
      _id = null;
      _isProfileSetup = null;
      _otp = null;
      _fToken = null;
      _message = null;

      log("Auth data cleared successfully.");
    } catch (e) {
      log('Error deleting auth data: $e');
    }
  }

  // --- Getters ---
  static String? get token => _token;
  static String? get userRole => _userRole;
  static bool? get userSetUp => _userSetUp;
  static String? get id => _id;
  static bool? get isProfileSetup => _isProfileSetup;
  static String? get otp => _otp;
  static String? get forgetToken => _fToken;
  static String? get resetMessage => _message;
}