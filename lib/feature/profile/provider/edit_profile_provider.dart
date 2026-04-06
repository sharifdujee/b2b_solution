import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/feature/profile/provider/profile_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/service/app_url.dart';
import '../model/profile_edit_state_model.dart';
import '../model/profile_state_model.dart';

class EditProfileNotifier extends StateNotifier<ProfileEditStateModel> {
  final UserModel? _currentUser;
  final ProfileProvider _profileProvider;

  EditProfileNotifier(this._currentUser, this._profileProvider)
      : super(ProfileEditStateModel()) {
    _initializeFields();
  }

  TextEditingController fullNameController = TextEditingController();
  TextEditingController legalNameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessCategoryController = TextEditingController();
  TextEditingController operationYearsController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController businessLatitude = TextEditingController();
  TextEditingController businessLongitude = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();

  void _initializeFields() {
    if (_currentUser != null) {
      fullNameController.text = _currentUser!.fullName;
      legalNameController.text = _currentUser!.legalName;
      businessNameController.text = _currentUser!.businessName;
      positionController.text = _currentUser!.position;
      operationYearsController.text = _currentUser!.operationYears.toString();
      businessLatitude.text = _currentUser!.businessLatitude?.toString() ?? "";
      businessLongitude.text = _currentUser!.businessLongitude?.toString() ?? "";

      if (_currentUser!.businessCategory.isNotEmpty) {
        businessCategoryController.text = _currentUser!.businessCategory.first;
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    legalNameController.dispose();
    businessNameController.dispose();
    businessCategoryController.dispose();
    operationYearsController.dispose();
    positionController.dispose();
    businessLatitude.dispose();
    businessLongitude.dispose();
    businessAddressController.dispose();
    super.dispose();
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
      final XFile? pickedFile = await _picker.pickImage(source: source);
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

  Future<void> pickBusinessImage(ImageSource source) => _pickImage(source, 'business');
  Future<void> pickProfileImage(ImageSource source) => _pickImage(source, 'profile');

  bool validateForm() {
    return true;
  }

  Future<bool> saveChanges() async {
    state = state.copyWith(isLoading: true, clearError: true);

    List<String> finalCategories = [];
    if (businessCategoryController.text.trim().isNotEmpty) {
      finalCategories = [businessCategoryController.text.trim()];
    } else if (_currentUser?.businessCategory != null) {
      finalCategories = _currentUser!.businessCategory;
    }

    int opYears = int.tryParse(operationYearsController.text) ?? _currentUser?.operationYears ?? 0;

    double? lat = double.tryParse(businessLatitude.text) ?? state.latitude;
    if (lat == 0.0) lat = _currentUser?.businessLatitude;

    double? lng = double.tryParse(businessLongitude.text) ?? state.longitude;
    if (lng == 0.0) lng = _currentUser?.businessLongitude;

    try {
      final request = http.MultipartRequest('PATCH', Uri.parse(AppUrl.updateProfile));

      request.headers.addAll({
        'Authorization':' ${AuthService.token}',
        'Accept': 'application/json',
      });

      Map<String, dynamic> data = {
        'legalName': legalNameController.text,
        'businessName': businessNameController.text,
        'fullName': fullNameController.text,
        'position': positionController.text,
        'businessCategory': finalCategories,
        'operationYears': opYears,
        'businessLatitude': lat,
        'businessLongitude': lng,
      };
      log("Body: $data");


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

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log("Status: ${response.statusCode}");
      log("Response: ${response.body}");

      final decodedData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _profileProvider.getMyProfile();
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
  final profileState = ref.watch(profileProvider);
  final profileNotifier = ref.read(profileProvider.notifier);

  return EditProfileNotifier(profileState.userModel, profileNotifier);
});