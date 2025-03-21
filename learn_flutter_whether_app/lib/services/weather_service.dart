import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'api_constants.dart';

class WeatherService {
  // Get current weather for a location
  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(ApiConstants.currentWeather(lat, lon)),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Weather(
        temperature: data['main']['temp'].toDouble(),
        description: data['weather'][0]['description'],
        icon: data['weather'][0]['icon'],
        humidity: data['main']['humidity'],
        windSpeed: data['wind']['speed'].toDouble(),
        date: DateTime.now(),
      );
    } else {
      throw Exception('Failed to get current weather: ${response.body}');
    }
  }

  // Get 5-day forecast for a location
  Future<List<Weather>> getForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(ApiConstants.forecastWeather(lat, lon)),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List forecastList = data['list'];

      List<Weather> weatherList = [];

      for (var item in forecastList) {
        weatherList.add(Weather(
          temperature: item['main']['temp'].toDouble(),
          description: item['weather'][0]['description'],
          icon: item['weather'][0]['icon'],
          humidity: item['main']['humidity'],
          windSpeed: item['wind']['speed'].toDouble(),
          date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
        ));
      }

      return weatherList;
    } else {
      throw Exception('Failed to get forecast: ${response.body}');
    }
  }
}
