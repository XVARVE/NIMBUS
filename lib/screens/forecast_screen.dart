import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nimbus/services/weather_service.dart';
import 'package:nimbus/theme/app_colors.dart';

class ForecastScreen extends StatefulWidget {
  final String city;
  const ForecastScreen({super.key, required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  List<Map<String, dynamic>> forecast = [];
  bool isLoading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      weatherData = await _weatherService.fetchWeather(widget.city);
      forecast = await _weatherService.fetchForecast(widget.city);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load forecast: $e')),
      );
    }
  }

  String getDayMinTemp() {
    if (forecast.isEmpty) return '--';
    int today = DateTime.now().day;
    final todayTemps = forecast
        .where((entry) => DateTime.parse(entry['dt_txt']).day == today)
        .map((entry) => entry['main']['temp_min'] ?? entry['main']['temp']);
    if (todayTemps.isEmpty) return '--';
    return todayTemps.reduce((a, b) => a < b ? a : b).round().toString();
  }

  String getDayMaxTemp() {
    if (forecast.isEmpty) return '--';
    int today = DateTime.now().day;
    final todayTemps = forecast
        .where((entry) => DateTime.parse(entry['dt_txt']).day == today)
        .map((entry) => entry['main']['temp_max'] ?? entry['main']['temp']);
    if (todayTemps.isEmpty) return '--';
    return todayTemps.reduce((a, b) => a > b ? a : b).round().toString();
  }

  void scrollToLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void scrollToRight() {
    _scrollController.animateTo(
      _scrollController.offset + 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxTemp = getDayMaxTemp();
    final minTemp = getDayMinTemp();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.mainGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.white))
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0), // No left padding
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Back arrow FLUSH left
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0), // Only right, so left is flush
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.arrow_back, color: AppColors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Center(
                              child: Text(
                                widget.city,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Max: $maxTemp   Min: $minTemp',
                        style: GoogleFonts.poppins(fontSize: 24, color: AppColors.white70, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(
                        '7-Days Forecasts',
                        style: GoogleFonts.openSans(
                          fontSize: 24,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      child: Row(
                        children: [
                          // Left arrow
                          GestureDetector(
                            onTap: scrollToLeft,
                            child: Container(
                              width: 28,
                              height: 80,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chevron_left,
                                size: 32,
                                color: AppColors.white70,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              children: _getDailyForecasts(7).asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final date = DateTime.parse(item['dt_txt']);
                                final day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
                                final temp = "${item['main']['temp'].round()}°C";
                                final icon = item['weather'][0]['icon'];
                                return _thinForecastTile(
                                  temp,
                                  'http://openweathermap.org/img/wn/$icon@2x.png',
                                  day,
                                  highlight: index == 2,
                                );
                              }).toList(),
                            ),
                          ),
                          // Right arrow
                          GestureDetector(
                            onTap: scrollToRight,
                            child: Container(
                              width: 28,
                              height: 80,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chevron_right,
                                size: 32,
                                color: AppColors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.mainGradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.air, color: AppColors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AIR QUALITY',
                                    style: GoogleFonts.openSans(fontSize: 16, color: AppColors.white70, fontWeight: FontWeight.w400)),
                                Text(
                                  "2 - Fair",
                                  style: GoogleFonts.openSans(
                                    fontSize: 28,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.white70),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            title: 'SUNRISE',
                            value: '5:32 AM',
                            subtitle: 'Sunset: 6:58 PM',
                            icon: Icons.wb_twighlight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: infoTile(
                            title: 'UV INDEX',
                            value: '4',
                            subtitle: 'Moderate',
                            icon: Icons.wb_sunny_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(Icons.menu_outlined, size: 50, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Thinner, pill-shaped tile with matching background gradient
  Widget _thinForecastTile(String temp, String iconUrl, String day, {bool highlight = false}) {
    return Container(
      width: 62,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: AppColors.mainGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: highlight
            ? [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))]
            : [],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(temp, style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Image.network(iconUrl, width: 30, height: 30),
          const SizedBox(height: 8),
          Text(day, style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDailyForecasts(int count) {
    final Map<String, Map<String, dynamic>> dailyMap = {};
    for (final entry in forecast) {
      final dt = DateTime.parse(entry['dt_txt']);
      final dateKey = "${dt.year}-${dt.month}-${dt.day}";
      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = entry;
      }
    }
    return dailyMap.values.take(count).toList();
  }

  Widget infoTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.mainGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white70, size: 24),
          const SizedBox(width: 8),
          // Title and value in a column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title next to the icon (already in a Row)
                Text(
                  title,
                  style: GoogleFonts.openSans(
                    color: AppColors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.openSans(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppColors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
