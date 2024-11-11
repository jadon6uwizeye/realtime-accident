class User {
  final int? id;
  final String name;
  final String plateNumber;
  final String carModel;
  final int phoneNumber; 
  final String email;
  final String password;

  User(
      {this.id,
      required this.name,
      required this.plateNumber,
      required this.carModel,
      required this.phoneNumber,
      required this.email,
      required this.password});

  // Convert a User object to a map to store in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'plate_number': plateNumber,
      'car_model': carModel,
      'phone_number': phoneNumber,
      'email': email,
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
      phoneNumber: map['phone_number'],
      email: map['email'],
      password: map['password'],
    );
  }
}
