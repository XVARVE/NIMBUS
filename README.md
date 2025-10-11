# 🌤️ Nimbus — Flutter Weather App




## 📱 Overview

Nimbus is a beautifully designed Flutter-based weather application that delivers real-time weather forecasts, UV index, air quality, and sunrise/sunset insights with smooth gradients, dynamic data, and animated visuals.
Built using the OpenWeatherMap API, it’s crafted for performance, responsiveness, and design consistency across all devices.

## ✨ Features

✅ Live Weather Data — Get real-time temperature, humidity, and weather conditions.
🌦️ 7-Day Forecast — Horizontal scroll view showing weekly predictions.
☀️ UV Index & Sunrise/Sunset — Fetched dynamically from OpenWeatherMap One Call API.
💨 Air Quality Index (AQI) — Integrated from OpenWeatherMap Air Pollution API.
📍 Automatic Location Detection — Detects your current city using Geolocator.
🎨 Consistent Gradient Theme — Custom color palette from /theme/app_colors.dart.
⚡ Offline Caching — Stores recent weather data using SharedPreferences.
🔥 Smooth UI Transitions — Designed with Google Fonts & Material 3 styling.

| Feature               | API Endpoint              | Description                          |
| --------------------- | ------------------------- | ------------------------------------ |
| Current Weather       | `/data/2.5/weather`       | Fetches live temperature & condition |
| 5-Day/3-Hour Forecast | `/data/2.5/forecast`      | Provides extended forecasts          |
| One Call              | `/data/2.5/onecall`       | Fetches UV, sunrise/sunset, etc.     |
| Air Quality           | `/data/2.5/air_pollution` | Retrieves AQI data                   |

## 🧠 Tech Stack

Framework: Flutter

Language: Dart

API Integration: OpenWeatherMap REST API

State Management: SetState (Simple Architecture)

Storage: SharedPreferences

Location: Geolocator & Geocoding

## 🚀 Future Enhancements

🌙 Dark/Light Mode Toggle

🗺️ Multiple City Management

📊 Detailed Hourly Graphs

🎯 Notifications for UV & AQI Alerts

🧭 Widget Support for Android/iOS
