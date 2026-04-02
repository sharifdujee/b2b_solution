import 'dart:developer';
import 'dart:io';

import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/service/auth_service.dart';
import '../model/profile_state_model.dart';

class ProfileProvider extends ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;

  ProfileStateModel? _profileStateModel;
  UserModel? userModel;

  final NetworkCaller networkCaller = NetworkCaller();
  final ImagePicker _picker = ImagePicker();

  // --- Getters ---
  String? get errorMessage => _errorMessage;
  bool get hasUser => userModel != null;
  bool get isLoading => _isLoading;
  ProfileStateModel? get profileStateModel => _profileStateModel;

  // --- Fetch Profile ---
  Future<void> getMyProfile() async {
    String? token = AuthService.token;

    if (token == null || token.isEmpty) {
      _errorMessage = "No Authentication Token Found";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      var response = await networkCaller.getRequest(
        AppUrl.getMe,
        token: token,
      );

      if (response.isSuccess) {
        final result = response.responseData['result'];

        if (result != null) {
          _profileStateModel =
              ProfileStateModel.fromJson(response.responseData);
          userModel = UserModel.fromJson(result);

          log("User Loaded: ${userModel?.fullName}");
        } else {
          _errorMessage = "No User Data Found";
        }
      } else {
        _errorMessage = response.errorMessage;
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      log("Profile Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Pick Image ---
  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        await uploadProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      _errorMessage = "Failed to pick image";
      notifyListeners();
    }
  }

  // --- Upload Image ---
  Future<void> uploadProfileImage(File imageFile) async {
    String? token = AuthService.token;
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {

      var response = await networkCaller.patchRequest(
        AppUrl.updateProfile,
        token: token,
        body: {
          'profileImage': imageFile.path,
        },
      );



      if(response.isSuccess){
        await getMyProfile();
      }else{
        _errorMessage = response.errorMessage;
      }
      
    } catch (e) {
      _errorMessage = "Upload failed $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

final profileProvider =
ChangeNotifierProvider<ProfileProvider>((ref) => ProfileProvider());