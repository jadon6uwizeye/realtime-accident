import 'package:flutter/material.dart';
import 'screens/admin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Accident Location Tracker',
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        // Pass the User argument to HomeScreen
        '/home': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          print(user);
          print(user.isAdmin);
          print(user.id);
          if (user.isAdmin) {
            return const AdminDashboard();
          } else {
            return HomeScreen(user: user);
          }
        },
      },
    );
  }
}
