import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/db_service.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _registerUser(BuildContext context) async {
    final user = User(
      name: nameController.text,
      email: emailController.text,
      plateNumber: plateNumberController.text,
      carModel: carModelController.text,
      phoneNumber: int.parse(phoneNumberController.text),
      password: passwordController.text,
    );
    await DatabaseService.instance.createUser(user);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome to Realtime Accident Aid and Support System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Create an account to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                _buildTextField(nameController, "Car Owner"),
                SizedBox(height: 16),
                _buildTextField(emailController, "Email"),
                SizedBox(height: 16),
                _buildTextField(passwordController, "Password", isPassword: true),
                SizedBox(height: 16),
                _buildTextField(phoneNumberController, "Phone Number"),
                SizedBox(height: 16),
                _buildTextField(plateNumberController, "Plate Number"),
                SizedBox(height: 16),
                _buildTextField(carModelController, "Car Model"),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () => _registerUser(context),
                  child: Text("Sign Up", style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "Already have an account? Log In",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.blue[10],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      obscureText: isPassword,
    );
  }
}