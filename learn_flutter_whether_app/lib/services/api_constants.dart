class ApiConstants {
  static const String baseUrl =
      'http://192.168.0.100:5000'; // Change this to your backend URL

  static const String register = '/api/users';
  static const String login = '/api/users/login';

  static const String users = '/api/users';

  static const String favoriteDays = '/api/favoritedays';

  // Weather API
  static const String weatherApiKey =
      '0fbb0668e7973280caadf99300d4921a'; // Replace with your API key
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static String currentWeather(double lat, double lon) =>
      '$weatherBaseUrl/weather?lat=$lat&lon=$lon&appid=$weatherApiKey&units=metric';
  static String forecastWeather(double lat, double lon) =>
      '$weatherBaseUrl/forecast?lat=$lat&lon=$lon&appid=$weatherApiKey&units=metric';
}
