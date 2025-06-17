import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  final String apiKey = '255e164769371ab9ebd0528861340e5e';
  final String weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final url = '$weatherUrl?q=$city&appid=$apiKey&units=metric';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _cacheData("weather_$city", data);
        return data;
      } else {
        throw Exception('Failed to fetch weather');
      }
    } catch (_) {
      return await _getCachedData("weather_$city");
    }
  }

  Future<List<Map<String, dynamic>>> fetchForecast(String city) async {
    final url = '$forecastUrl?q=$city&appid=$apiKey&units=metric';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['list'];
        final List<Map<String, dynamic>> sliced =
        list.take(40).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        await _cacheData("forecast_$city", sliced);
        return sliced;
      } else {
        throw Exception('Failed to fetch forecast');
      }
    } catch (_) {
      final cached = await _getCachedData("forecast_$city");
      return cached != null ? List<Map<String, dynamic>>.from(cached) : [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchForecastByCoordinates(double lat, double lon) async {
    final url = '$forecastUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['list'];
        return list.take(40).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch forecast by coordinates');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchExtras(double lat, double lon) async {
    try {
      final oneCallUrl =
          'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&appid=$apiKey&units=metric';
      final airPollutionUrl =
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';

      final oneCallRes = await http.get(Uri.parse(oneCallUrl));
      final airRes = await http.get(Uri.parse(airPollutionUrl));

      if (oneCallRes.statusCode == 200 && airRes.statusCode == 200) {
        final oneCallData = jsonDecode(oneCallRes.body);
        final airData = jsonDecode(airRes.body);

        // Air Quality Index mapping (OpenWeatherMap: 1-5)
        int aqiValue = 0;
        if (airData['list'] != null && airData['list'].isNotEmpty) {
          aqiValue = airData['list'][0]['main']['aqi'] ?? 0;
        }

        return {
          'sunrise': oneCallData['current']['sunrise'],
          'sunset': oneCallData['current']['sunset'],
          'uvi': oneCallData['current']['uvi'],
          'aqi': aqiValue,
        };
      } else {
        throw Exception('Extras API error');
      }
    } catch (e) {
      throw Exception('Fetch extras error: $e');
    }
  }


  Future<String> getCurrentCity() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    final city = placemarks.first.locality;
    if (city == null || city.isEmpty) {
      throw Exception('Unable to determine city');
    }

    return city[0].toUpperCase() + city.substring(1);
  }

  Future<void> _cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, jsonEncode(data));
  }

  Future<dynamic> _getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    return raw != null ? jsonDecode(raw) : null;
  }
}
