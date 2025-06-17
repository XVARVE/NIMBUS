import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nimbus/screens/forecast_screen.dart';
import 'package:nimbus/services/weather_service.dart';
import 'package:nimbus/theme/app_colors.dart'; // <-- import here

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController cityController = TextEditingController();
  final WeatherService weatherService = WeatherService();

  Map<String, dynamic>? weatherData;
  List<Map<String, dynamic>> forecastData = [];

  @override
  void initState() {
    super.initState();
    fetchLocationWeather();
  }

  Future<void> fetchWeather(String city) async {
    final data = await weatherService.fetchWeather(city);
    if (data != null) {
      setState(() => weatherData = data);
    }
  }

  Future<void> fetchForecast(String city) async {
    final data = await weatherService.fetchForecast(city);
    setState(() => forecastData = data);
  }

  String getDayMinTemp() {
    if (forecastData.isEmpty) return '--';
    int today = DateTime.now().day;
    final todayTemps = forecastData
        .where((entry) => DateTime.parse(entry['dt_txt']).day == today)
        .map((entry) => entry['main']['temp_min'] ?? entry['main']['temp']);
    if (todayTemps.isEmpty) return '--';
    return todayTemps.reduce((a, b) => a < b ? a : b).round().toString();
  }

  String getDayMaxTemp() {
    if (forecastData.isEmpty) return '--';
    int today = DateTime.now().day;
    final todayTemps = forecastData
        .where((entry) => DateTime.parse(entry['dt_txt']).day == today)
        .map((entry) => entry['main']['temp_max'] ?? entry['main']['temp']);
    if (todayTemps.isEmpty) return '--';
    return todayTemps.reduce((a, b) => a > b ? a : b).round().toString();
  }

  Future<void> fetchLocationWeather() async {
    try {
      final city = await weatherService.getCurrentCity();
      if (city.isNotEmpty) {
        cityController.text = city;
        await fetchWeather(city);
        await fetchForecast(city);
      } else {
        await _loadFallbackCity();
      }
    } catch (e) {
      await _loadFallbackCity();
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  Future<void> _loadFallbackCity() async {
    const fallbackCity = 'Lahore';
    cityController.text = fallbackCity;
    await fetchWeather(fallbackCity);
    await fetchForecast(fallbackCity);
  }

  @override
  Widget build(BuildContext context) {
    final temperature = weatherData?['main']['temp']?.round().toString() ?? '--';
    final condition = weatherData?['weather'][0]['main'] ?? '--';
    final minTemp = getDayMinTemp();
    final maxTemp = getDayMaxTemp();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.mainGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // House image behind forecast card
          Positioned(
            left: 0,
            right: 0,
            bottom: 160,
            child: Center(
              child: SizedBox(
                width: 336,
                height: 198,
                child: Image.asset(
                  'assets/images/house.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Main content above
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 220),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  TextField(
                    controller: cityController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter City',
                      hintStyle: const TextStyle(color: AppColors.white54),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: AppColors.white),
                        onPressed: () {
                          final city = cityController.text.trim();
                          if (city.isNotEmpty) {
                            fetchWeather(city);
                            fetchForecast(city);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/images/cloud_rain_icon.png', height: 244, width: 244),
                  Text(
                    '$temperature°',
                    style: GoogleFonts.poppins(
                      fontSize: 64,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    condition,
                    style: GoogleFonts.poppins(fontSize: 24, color: AppColors.white, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Max: $maxTemp°   Min: $minTemp°',
                    style: GoogleFonts.poppins(fontSize: 24, color: AppColors.white, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),

          // Forecast card floating
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,

            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForecastScreen(city: cityController.text),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.mainGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today", style: GoogleFonts.openSans(fontSize: 20, color: AppColors.white, fontWeight: FontWeight.w600)),
                          Text(
                            '${_monthName(DateTime.now().month)}, ${DateTime.now().day}',
                            style: GoogleFonts.openSans(fontSize: 20, color: AppColors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.white70),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: forecastData.map((entry) {
                              final temp = entry['main']['temp'].round().toString();
                              final time = DateTime.parse(entry['dt_txt']);
                              final hour = "${time.hour.toString().padLeft(2, '0')}:00";
                              final iconCode = entry['weather'][0]['icon'];
                              final iconUrl = 'http://openweathermap.org/img/wn/$iconCode@2x.png';

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$temp°C', style: GoogleFonts.poppins(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 5),
                                    Image.network(iconUrl, width: 30, height: 30),
                                    const SizedBox(height: 8),
                                    Text(hour, style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 20, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              );
                            }).toList(),
                          )

                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Bottom NavBar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(

              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.white),
                  Icon(Icons.add_circle_outline, color: AppColors.white),
                  Icon(Icons.menu, color: AppColors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}