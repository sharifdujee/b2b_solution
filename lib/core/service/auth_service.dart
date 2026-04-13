import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userRoleKey = "userRole";
  static const String _isSetUp = "isSetUp";
  static const String _userId = "userId";

  // Singleton instance for SharedPreferences
  static late SharedPreferences _preferences;

  // Private variables to hold token and userId
  static String? _token;
  static String? _userRole;
  static bool? _userSetUp;
  static String? _id;

  // Initialize SharedPreferences (call this during app startup)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    // Load token and userId from SharedPreferences into private variables
    _token = _preferences.getString(_tokenKey);
    _userRole = _preferences.getString(_userRoleKey);
    _userSetUp = _preferences.getBool(_isSetUp);
    _id = _preferences.getString(_userId);
  }

  // Check if a token exists in local storage
  static bool hasToken() {
    return _preferences.containsKey(_tokenKey);
  }

  // Save the token and user ID to local storage
  static Future<void> saveToken(String token) async {
    try {
      await _preferences.setString(_tokenKey, token);
      // Update private variables
      _token = token;
    } catch (e) {
      log('Error saving token: $e');
    }
  }

  /// save id
  static Future<void> saveId(String id) async {
    try {
      await _preferences.setString(_userId, id);
      // Update private variables
      _id = id;
    } catch (e) {
      log('Error saving id: $e');
    }
  }

  //Save user role
  static Future<void> saveRole(String role) async {
    try {
      await _preferences.setString(_userRoleKey, role);
      // Update private variables
      _userRole = role;
    } catch (e) {
      log('Error saving role: $e');
    }
  }

  static Future<void> saveStatus(bool setUp) async {
    try {
      await _preferences.setBool(_isSetUp, setUp);
      // Update private variables
      _userSetUp = setUp;
    } catch (e) {
      log('Error saving status: $e');
    }
  }

  // Clear authentication data (for logout or clearing auth data)
  // Note: Now requires BuildContext to be passed in
  static Future<void> logoutUser(BuildContext context) async {
    try {
      // Clear all data from SharedPreferences
      await deleteTokenRole();
      /// await GoogleSignInService().signOutFromGoogle();
      // Reset private variables
      _token = null;
      _userRole = null;
      _userSetUp = null;
      _id = null;
      // Redirect to the login screen
      if (context.mounted) {
        context.go("/login"); // Use .go() instead of .push() for login
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
      _token = null;
      _userRole = null;
      _userSetUp = null;
      _id = null;
    } catch (e) {
      log('Error deleting token and role: $e');
    }
  }

  // Getter for token
  static String? get token => _token;
  static String? get userRole => _userRole;
  static bool? get userSetUp => _userSetUp;
  static String? get id => _id; // Fixed: was a field, now a getter
}