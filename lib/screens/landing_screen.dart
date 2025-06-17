import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nimbus/screens/home_screen.dart';
import 'package:nimbus/theme/app_colors.dart'; // Import your centralized colors

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.mainGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/weather_icon.png',
                      height: 428,
                      width: 428,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      "NIMBUS",
                      style: GoogleFonts.poppins(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Get Started button centered
            Positioned(
              top: 800, // adjust as needed
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 304,
                  height: 72,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF281C42),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
