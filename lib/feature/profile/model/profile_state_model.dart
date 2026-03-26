class ProfileStateModel {
  final String? name;
  final String? position;
  final String? profileImage;

  ProfileStateModel({
    this.name,
    this.position,
    this.profileImage,
  });

  ProfileStateModel copyWith({
    String? name,
    String? position,
    String? profileImage,
  }) {
    return ProfileStateModel(
      name: name ?? this.name,
      position: position ?? this.position,
      profileImage: profileImage ?? this.profileImage
    );
  }
}