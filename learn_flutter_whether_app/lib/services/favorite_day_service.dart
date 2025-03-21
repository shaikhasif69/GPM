import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_day_model.dart';
import '../models/weather_model.dart';
import 'api_constants.dart';

class FavoriteDayService {
  Future<FavoriteDay> addFavoriteDay(DateTime date, Weather weatherData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    
    if (userId == null || token == null) {
      throw Exception('User not logged in');
    }
    
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.favoriteDays),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'date': date.toIso8601String(),
        'weatherData': weatherData.toJson(),
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print("Response body: $responseData");  
      
      if (responseData is Map<String, dynamic>) {
        return FavoriteDay(
          id: responseData['_id'] ?? '',
          userId: userId,
          date: date,
          weatherData: weatherData,
        );
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to add favorite day: ${response.body}');
    }
  }

  // Get all favorite days for the current user
  Future<List<FavoriteDay>> getUserFavoriteDays() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    
    print("UserId: $userId, Token: ${token != null ? 'exists' : 'null'}");
    
    if (userId == null || token == null) {
      throw Exception('User not logged in');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.favoriteDays}/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        
        if (data.isEmpty) return [];
        
        return data.map((item) {
          try {
            return FavoriteDay.fromJson(item);
          } catch (e) {
            print("Error parsing favorite day: $e");
            return null;
          }
        }).whereType<FavoriteDay>().toList();
      } else {
        print("Failed to get favorite days: ${response.body}");
        return []; 
      }
    } catch (e) {
      print("Exception in getUserFavoriteDays: $e");
      return []; 
    }
  }

  // Remove a day from favorites
  Future<void> removeFavoriteDay(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('User not logged in');
    }
    
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.favoriteDays}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite day: ${response.body}');
    }
  }
}