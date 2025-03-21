import 'package:learn_flutter_whether_app/models/weather_model.dart';
 
class FavoriteDay {
  final String id;
  final String userId;
  final DateTime date;
  final Weather weatherData;

  FavoriteDay({
    required this.id,
    required this.userId,
    required this.date,
    required this.weatherData,
  });

  factory FavoriteDay.fromJson(Map<String, dynamic> json) {
    return FavoriteDay(
      id: json['_id']?.toString() ?? '',  
      userId: json['userId']?.toString() ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      weatherData: Weather.fromJson(json['weatherData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'weatherData': weatherData.toJson(),
    };
  }
}