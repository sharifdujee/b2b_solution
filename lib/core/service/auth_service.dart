import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userRoleKey = "userRole";
  static const String _isSetUp = "isSetUp";
  static const String _userId = "userId";
  static const String _isProfileSetupKey = "isProfileSetup";
  static const String _otpKey = "otp"; // New OTP Key

  // Singleton instance for SharedPreferences
  static late SharedPreferences _preferences;

  // Private variables to hold values
  static String? _token;
  static String? _userRole;
  static bool? _userSetUp;
  static String? _id;
  static bool? _isProfileSetup;
  static String? _otp; // New Private Variable for OTP

  // Initialize SharedPreferences (call this during app startup)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    // Load data from SharedPreferences into private variables
    _token = _preferences.getString(_tokenKey);
    _userRole = _preferences.getString(_userRoleKey);
    _userSetUp = _preferences.getBool(_isSetUp);
    _id = _preferences.getString(_userId);
    _isProfileSetup = _preferences.getBool(_isProfileSetupKey);
    _otp = _preferences.getString(_otpKey); // Initialize OTP var
  }

  // Check if a token exists in local storage
  static bool hasToken() {
    return _preferences.containsKey(_tokenKey);
  }

  // Save the token to local storage
  static Future<void> saveToken(String token) async {
    try {
      await _preferences.setString(_tokenKey, token);
      _token = token;
    } catch (e) {
      log('Error saving token: $e');
    }
  }

  /// Save ID
  static Future<void> saveId(String id) async {
    try {
      await _preferences.setString(_userId, id);
      _id = id;
    } catch (e) {
      log('Error saving id: $e');
    }
  }

  // Save user role
  static Future<void> saveRole(String role) async {
    try {
      await _preferences.setString(_userRoleKey, role);
      _userRole = role;
    } catch (e) {
      log('Error saving role: $e');
    }
  }

  // Save setup status
  static Future<void> saveStatus(bool setUp) async {
    try {
      await _preferences.setBool(_isSetUp, setUp);
      _userSetUp = setUp;
    } catch (e) {
      log('Error saving status: $e');
    }
  }

  // Save Profile Setup Status
  static Future<void> saveProfileSetup(bool isSetup) async {
    try {
      await _preferences.setBool(_isProfileSetupKey, isSetup);
      _isProfileSetup = isSetup;
    } catch (e) {
      log('Error saving profile setup status: $e');
    }
  }

  // Save OTP (New Method)
  static Future<void> saveOtp(String otp) async {
    try {
      await _preferences.setString(_otpKey, otp);
      _otp = otp;
    } catch (e) {
      log('Error saving otp: $e');
    }
  }

  // Clear authentication data for logout
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
      await _preferences.remove(_tokenKey);
      await _preferences.remove(_userRoleKey);
      await _preferences.remove(_isSetUp);
      await _preferences.remove(_userId);
      await _preferences.remove(_isProfileSetupKey);
      await _preferences.remove(_otpKey); // Remove OTP key

      _token = null;
      _userRole = null;
      _userSetUp = null;
      _id = null;
      _isProfileSetup = null;
      _otp = null; // Reset OTP var
    } catch (e) {
      log('Error deleting token and role: $e');
    }
  }

  // Getters
  static String? get token => _token;
  static String? get userRole => _userRole;
  static bool? get userSetUp => _userSetUp;
  static String? get id => _id;
  static bool? get isProfileSetup => _isProfileSetup;
  static String? get otp => _otp; // New OTP Getter
}