import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nimbus/screens/forecast_screen.dart';
import 'package:nimbus/screens/landing_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
