class UserModel {
  final String uid;
  final String email; // Add this line
  final DateTime birthDate;
  final String gender;
  final String occupation;

  UserModel({
    required this.uid,
    required this.email, // Add this line
    required this.birthDate,
    required this.gender,
    required this.occupation,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email, // Add this line
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'occupation': occupation,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'], // Add this line
      birthDate: DateTime.parse(map['birthDate']),
      gender: map['gender'],
      occupation: map['occupation'],
    );
  }
}
