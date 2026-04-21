import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http_parser/http_parser.dart'; // Added for MediaType

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../models/signup_state_model.dart';

class SignupNotifier extends StateNotifier<SignupStateModel> {
  final Ref ref;
  SignupNotifier({required this.ref}) : super(SignupStateModel());

  // Text Controllers
  final TextEditingController roleController = TextEditingController();
  final TextEditingController legalNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController foodCategoryController = TextEditingController();
  final TextEditingController yearsOfOperationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController businessAddressController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  Timer? _timer;


  void resetErrorMessage() {
    state = state.copyWith(errorMessage: null);
  }

  void changeRole(Role role) {
    state = state.copyWith(selectRole: role, errorMessage: null);
    roleController.text = role.name;
  }

  // --- Timer Logic ---
  void startTimer() {
    state = state.copyWith(timer: 60, canResend: false, errorMessage: null);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timer > 0) {
        state = state.copyWith(timer: state.timer - 1);
      } else {
        state = state.copyWith(canResend: true);
        _timer?.cancel();
      }
    });
  }

  // --- OTP Verification ---
  Future<bool> verify(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final NetworkCaller networkCaller = NetworkCaller();

    try {
      final response = await networkCaller.postRequest(
        AppUrl.userVerifyOtp,
        body: {
          'email': emailController.text.trim(),
          'otp': code,
        },
      );

      if (!mounted) return false;
      state = state.copyWith(isLoading: false);

      if (response.isSuccess && response.responseData != null) {
        final result = response.responseData['result'];
        await AuthService.saveProfileSetup(result['isProfileComplete'] ?? false);
        await AuthService.saveId(result['userId'] ?? '');
        await AuthService.saveToken(result['accessToken'] ?? '');
        await AuthService.saveRole(result['role'] ?? '');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  // --- Location ---
  void updateLocation({required double lat, required double lng, String? address}) {
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      businessAddress: address,
      errorMessage: null,
    );
    latitudeController.text = lat.toString();
    longitudeController.text = lng.toString();
    if (address != null) businessAddressController.text = address;
  }

  // --- Image Picking ---
  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        state = state.copyWith(errorMessage: null);
        if (type == 'business') {
          state = state.copyWith(businessImage: pickedFile.path);
        } else if (type == 'profile') {
          state = state.copyWith(profileImage: pickedFile.path);
        } else if (type == 'license') {
          state = state.copyWith(businessLicenseImage: pickedFile.path);
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to pick image");
    }
  }

  Future<void> pickBusinessImage(ImageSource source) => _pickImage(source, 'business');
  Future<void> pickProfileImage(ImageSource source) => _pickImage(source, 'profile');
  Future<void> pickLicenseImage(ImageSource source) => _pickImage(source, 'license');

  void toggleVisibility() => state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleConfirmPasswordVisibility() => state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);


  void updateFoodCategories(List<String> categories) {
    state = state.copyWith(foodCategory: categories);

    foodCategoryController.text = categories.join(", ");
  }

  // --- Signup Logic ---
  Future<bool> signup() async {
    log("Sign up pressed");
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      Map<String, dynamic> bodyData = {
        'role': state.selectRole?.name.toUpperCase() ?? '',
        'legalName': legalNameController.text.trim(),
        'businessName': businessNameController.text.trim(),
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'position': positionController.text.trim(),
        'businessCategory': [foodCategoryController.text.trim()],
        'operationYears': int.tryParse(yearsOfOperationController.text.trim()) ?? 0,
        'businessLatitude': double.tryParse(latitudeController.text.trim()) ?? 0.0,
        'businessLongitude': double.tryParse(longitudeController.text.trim()) ?? 0.0,
        'fcmToken': '',
      };

      final request = http.MultipartRequest('POST', Uri.parse(AppUrl.createUser));
      request.fields['bodyData'] = jsonEncode(bodyData);

      MediaType _getMediaType(String path) {
        final extension = path.split('.').last.toLowerCase();
        return extension == 'png' ? MediaType('image', 'png') : MediaType('image', 'jpeg');
      }

      if (state.profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage', state.profileImage!,
          contentType: _getMediaType(state.profileImage!),
        ));
      }
      if (state.businessImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'businessImage', state.businessImage!,
          contentType: _getMediaType(state.businessImage!),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return false;
      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        final result = decodedData['result'];
        if (result != null && result['id'] != null) {
          await AuthService.saveToken(result['id']);
        }
        await AuthService.saveProfileSetup(true);
        return true;
      } else {
        final decodedData = jsonDecode(response.body);
        log("decodedData : $decodedData");
        return false;
      }
    } catch (e) {
      log("Signup Error: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    roleController.dispose();
    legalNameController.dispose();
    businessNameController.dispose();
    nameController.dispose();
    emailController.dispose();
    positionController.dispose();
    foodCategoryController.dispose();
    yearsOfOperationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    businessAddressController.dispose();
    pinController.dispose();
    super.dispose();
  }
}

final signupProvider = StateNotifierProvider.autoDispose<SignupNotifier, SignupStateModel>((ref) {
  return SignupNotifier(ref: ref);
});