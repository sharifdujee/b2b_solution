import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart'; // Import this
import '../model/profile_state_model.dart';

class ProfileProvider extends StateNotifier<ProfileStateModel> {
  ProfileProvider(): super(ProfileStateModel());

  final ImagePicker _picker = ImagePicker();

  void updateName(String name) => state = state.copyWith(name: name);
  void updatePosition(String position) => state = state.copyWith(position: position);

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        state = state.copyWith(profileImage: pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
}

final profileProvider = StateNotifierProvider.autoDispose<ProfileProvider, ProfileStateModel>((ref) {
  return ProfileProvider();
});