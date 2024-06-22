import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/search_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "secure/.env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // "docho, galo, geni"
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: const Color(0xFF2A29CC),
    ),
    debugShowCheckedModeBanner: false,
    home: const MapScreen(),
  ));
}
