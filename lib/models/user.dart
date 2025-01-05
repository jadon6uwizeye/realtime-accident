class User {
  final int? id;
  final String name;
  final String plateNumber;
  final String carModel;
  final int phoneNumber;
  final String email;
  final String password;
  final bool isAdmin;
  final String insurance;

  User(
      {this.id,
      required this.name,
      required this.plateNumber,
      required this.carModel,
      required this.insurance,
      required this.phoneNumber,
      required this.email,
      required this.password,
      this.isAdmin = false
      });

  // Convert a User object to a map to store in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'plate_number': plateNumber,
      'car_model': carModel,
      'insurance': insurance,
      'phone_number': phoneNumber,
      'email': email,
      'is_admin': isAdmin ? 1 : 0,
      'password': password,
    };
  }

  // Convert a map to a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      plateNumber: map['plate_number'],
      carModel: map['car_model'],
      insurance: map['insurance'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      isAdmin: map['is_admin'] == 1,
      password: map['password'],
    );
  }
}
