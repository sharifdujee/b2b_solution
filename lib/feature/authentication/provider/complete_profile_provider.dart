import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:b2b_solution/feature/authentication/provider/state/complete_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../profile/model/profile_state_model.dart';
import '../../profile/provider/profile_provider.dart';

class CompleteProfileNotifier extends StateNotifier<CompleteProfileState> {

  final UserModel? _currentUser;
  CompleteProfileNotifier(this._currentUser) : super(CompleteProfileState()) {
    _initializeFields();
  }
  // Controllers
  final TextEditingController legalNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController yearsOfOperationController = TextEditingController();
  final TextEditingController foodCategoryController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();




  void _initializeFields() {
    if (_currentUser != null) {
      nameController.text = _currentUser!.fullName ?? "";
      emailController.text = _currentUser!.email ?? "";

      legalNameController.text = _currentUser!.legalName ?? "";
      businessNameController.text = _currentUser!.businessName ?? "";
      positionController.text = _currentUser!.position ?? "";
      yearsOfOperationController.text = _currentUser!.operationYears?.toString() ?? "";

      state = state.copyWith(
        foodCategory: _currentUser!.businessCategory ?? [],
        latitude: _currentUser!.businessLatitude,
        longitude: _currentUser!.businessLongitude,
      );

      foodCategoryController.text = (state.foodCategory).join(", ");
    }
  }

  // --- Image Picking Methods ---

  Future<void> pickProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        state = state.copyWith(profileImage: image.path);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to pick profile image");
    }
  }

  Future<void> pickBusinessImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        state = state.copyWith(businessImage: image.path);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to pick business image");
    }
  }

  void updateAddress(String address) {
    state = state.copyWith(businessAddress: address);
  }

  void updateLocation({required double lat, required double lng, required String address}) {
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      businessAddress: address,
    );
  }

  void updateFoodCategories(List<String> categories) {
    state = state.copyWith(foodCategory: categories);
    foodCategoryController.text = categories.join(", ");
  }

  void resetErrorMessage() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  // --- API Submission ---

  Future<bool> completeProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = http.MultipartRequest('PATCH', Uri.parse(AppUrl.updateProfile));

      request.headers.addAll({
        'Authorization': ' ${AuthService.token}',
        'Accept': 'application/json',
      });

      Map<String, dynamic> data = {
        'legalName': legalNameController.text.trim(),
        'businessName': businessNameController.text.trim(),
        'role': 'USER',
        //'fullName': nameController.text.trim(),
        'position': positionController.text.trim(),
        'businessCategory': state.foodCategory,
        'operationYears': int.tryParse(yearsOfOperationController.text.trim()) ?? 0,
        'businessLatitude': state.latitude,
        'businessLongitude': state.longitude,
      };

      log("Onboarding Body: $data");

      request.fields['bodyData'] = jsonEncode(data);

      MediaType _getMediaType(String path) {
        final extension = path.split('.').last.toLowerCase();
        return extension == 'png' ? MediaType('image', 'png') : MediaType('image', 'jpeg');
      }

      if (state.profileImage != null && File(state.profileImage!).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          state.profileImage!,
          contentType: _getMediaType(state.profileImage!),
        ));
      }

      if (state.businessImage != null && File(state.businessImage!).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'businessImage',
          state.businessImage!,
          contentType: _getMediaType(state.businessImage!),
        ));
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Onboarding Status: ${response.statusCode}");
      log("Onboarding Response: ${response.body}");

      final decodedData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
            isLoading: false,
            errorMessage: decodedData['message'] ?? "Failed to complete profile"
        );
        return false;
      }
    } catch (e) {
      log("Onboarding Catch Error: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred",
      );
      return false;
    }
  }

  @override
  void dispose() {
    legalNameController.clear();
    businessNameController.clear();
    positionController.clear();
    yearsOfOperationController.clear();
    foodCategoryController.clear();
    nameController.clear();
    emailController.clear();
    super.dispose();
  }
}

final completeProfileProvider = StateNotifierProvider.autoDispose<CompleteProfileNotifier, CompleteProfileState>((ref) {
  final profileState = ref.watch(profileProvider);
  return CompleteProfileNotifier(profileState.userModel);
});