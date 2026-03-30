enum ConnectionFilterOption { Connected, Pending, Find }





class MyConnectionStateModel {
  final String name;
  final String address;
  final String note;
  final String icon;
  final int membershipYear;
  final String phoneNumber;
  final String email;
  final ConnectionFilterOption status;
  final bool? sendRequestStatus;



  MyConnectionStateModel({
    required this.name,
    required this.address,
    required this.note,
    required this.icon,
    required this.membershipYear,
    required this.phoneNumber,
    required this.email,
    required this.status,
    this.sendRequestStatus = false
  });

  MyConnectionStateModel copyWith({
    String? name,
    String? address,
    String? note,
    String? icon,
    int? membershipYear,
    String? phoneNumber,
    String? email,
    ConnectionFilterOption? status,
    bool? sendRequestStatus,
  }) {
    return MyConnectionStateModel(
      name: name ?? this.name,
      address: address ?? this.address,
      note: note ?? this.note,
      icon: icon ?? this.icon,
      membershipYear: membershipYear ?? this.membershipYear,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      status: status ?? this.status,
      sendRequestStatus: sendRequestStatus ?? this.sendRequestStatus,
    );
  }
}
