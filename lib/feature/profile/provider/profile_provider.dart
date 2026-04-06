import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
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
          log("Profile Lat: ${userModel?.latitude}");
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

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        await uploadProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      log("Pick Image Error: $e");
      _errorMessage = "Failed to pick image";
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    String? token = AuthService.token;
    if (token == null) {
      _errorMessage = "Authentication required";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(AppUrl.updateProfile));

      request.headers.addAll({
        'Authorization': token,
        'Accept': 'application/json',
      });

      String extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
          contentType: http.MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Upload Status: ${response.statusCode}");
      log("Upload Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getMyProfile();
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _errorMessage = responseData['message'] ?? "Upload failed";
      }
    } catch (e) {
      log("Upload Error: $e");
      _errorMessage = "Upload failed: $e";
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

final profileProvider = ChangeNotifierProvider<ProfileProvider>((ref) {
  return ProfileProvider();
});