class UserData {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String password;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}
