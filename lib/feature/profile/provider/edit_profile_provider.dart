
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/feature/profile/provider/profile_provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/service/app_url.dart';
import '../model/profile_edit_state_model.dart';
import '../model/profile_state_model.dart';


class EditProfileNotifier extends StateNotifier<ProfileEditStateModel> {

  EditProfileNotifier() : super(ProfileEditStateModel());

  TextEditingController fullNameController = TextEditingController();
  TextEditingController legalNameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessCategoryController = TextEditingController();
  TextEditingController operationYearsController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController businessLatitude = TextEditingController();
  TextEditingController businessLongitude = TextEditingController();

  TextEditingController businessAddressController = TextEditingController();

  UserModel? userModel;







  @override
  void dispose() {
    super.dispose();
  }



  void updateVerificationCode(String code) {
    state = state.copyWith(verificationCode: code, clearError: true);
  }


  void updateLocation({required double lat, required double lng, String? address}) {
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      businessAddress: address,
    );

    businessLatitude.text = lat.toString();
    businessLongitude.text = lng.toString();
    if (address != null) {
      businessAddressController.text = address;
    }
  }




  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        if (type == 'business') {
          state = state.copyWith(businessImage: pickedFile.path, clearError: true);
        } else if (type == 'profile') {
          state = state.copyWith(profileImage: pickedFile.path, clearError: true);
        } else if (type == 'license') {
          state = state.copyWith(businessLicenseImage: pickedFile.path, clearError: true);
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to pick image");
    }
  }

  // Public methods that now accept the Source
  Future<void> pickBusinessImage(ImageSource source) => _pickImage(source, 'business');
  Future<void> pickProfileImage(ImageSource source) => _pickImage(source, 'profile');

  void updatePassword(String password) {
    state = state.copyWith(password: password, clearError: true);
  }


  void toggleVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  void toggleIsLoading() {
    state = state.copyWith(isLoading: !state.isLoading);
  }

  bool validateForm() {

    if (state.password.length < 6) {
      state = state.copyWith(errorMessage: "Password must be at least 6 characters");
      return false;
    }

    if (state.password != state.confirmPassword) {
      state = state.copyWith(errorMessage: "Passwords do not match");
      return false;
    }

    state = state.copyWith(clearError: true);
    return true;
  }

  Future<bool> saveChanges() async {
    state = state.copyWith(isLoading: true, clearError: true);
    log("User Model : $userModel");
    if(legalNameController.text.isEmpty && userModel?.legalName != null){
      legalNameController.text = userModel!.legalName;
    }
    // if(businessNameController.text.isEmpty && userModel?.businessName != null){
    //   businessNameController.text = userModel!.businessName;
    // }
    if(fullNameController.text.isEmpty && userModel?.fullName != null){
      fullNameController.text = userModel!.fullName;
    }
    if(positionController.text.isEmpty && userModel?.position != null){
      positionController.text = userModel!.position;
    }

    List<String> finalCategories = [];

    if (businessCategoryController.text.trim().isNotEmpty) {
      finalCategories = [businessCategoryController.text.trim()];
    } else if (userModel?.businessCategory != null) {
      finalCategories = userModel!.businessCategory!;
    }
    int opYears = int.tryParse(operationYearsController.text) ?? userModel?.operationYears ?? 0;

    double lat = double.tryParse(state.latitude.toString()) ?? userModel?.businessLatitude ?? 0.0;

    double lng = double.tryParse(state.longitude.toString()) ?? userModel?.businessLongitude ?? 0.0;





    try {
      Map<String, dynamic> bodyData = {
        'legalName': legalNameController.text ,
        'businessName': businessNameController.text,
        'fullName': fullNameController.text,
        'position': positionController.text,
        'businessCategory': finalCategories,
        'operationYears': opYears,
        'businessLatitude': lat,
        'businessLongitude': lng,
      };
      log("Body Data: $bodyData");

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse(AppUrl.updateProfile),
      );

      request.headers.addAll({
        'Authorization': '${AuthService.token}',
        'Accept': 'application/json',
      });

      bodyData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      if (businessCategoryController.text.isNotEmpty) {
        request.fields['businessCategory'] = businessCategoryController.text;
      }

      http.MediaType _getMediaType(String path) {
        final extension = path.split('.').last.toLowerCase();
        return extension == 'png'
            ? http.MediaType('image', 'png')
            : http.MediaType('image', 'jpeg');
      }

      if (state.profileImage != null && File(state.profileImage!).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          state.profileImage!,
          contentType: _getMediaType(state.profileImage!),
        ));
      } else if (userModel?.profileImage != null) {
        request.fields['profileImage'] = userModel!.profileImage!;
      }


      if (state.businessImage != null && File(state.businessImage!).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'businessImage',
          state.businessImage!,
          contentType: _getMediaType(state.businessImage!),
        ));
      } else if (userModel?.businessImage != null) {
        request.fields['businessImage'] = userModel!.businessImage!;
      }



      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Status: ${response.statusCode}");
      log("Response: ${response.body}");

      final decodedData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ProfileProvider profileProvider = ProfileProvider();
        await profileProvider.getMyProfile();
        return true;
      } else {
        state = state.copyWith(
            isLoading: false,
            errorMessage: decodedData['message'] ?? "Save changes failed"
        );
        return false;
      }
    } catch (e) {
      log("Catch Error: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred",
      );
      return false;
    }
  }

}


final editProfileProvider = StateNotifierProvider.autoDispose<EditProfileNotifier, ProfileEditStateModel>((ref) {
  return EditProfileNotifier();
});
