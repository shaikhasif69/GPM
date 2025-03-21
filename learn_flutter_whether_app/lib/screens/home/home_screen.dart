import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import '../../services/weather_service.dart';
import '../../services/favorite_day_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final FavoriteDayService _favoriteDayService = FavoriteDayService();
  bool _isTodayFavorited = false;
  Weather? _currentWeather;
  List<Weather> _forecast = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Example coordinates (Mumbai, India)
  final double _latitude = 19.0760;
  final double _longitude = 72.8777;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _checkIfTodayIsFavorited();
  }

  Future<void> _checkIfTodayIsFavorited() async {
    try {
      final favorites = await _favoriteDayService.getUserFavoriteDays();
      final today = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(today);

      setState(() {
        _isTodayFavorited = favorites.any(
            (day) => DateFormat('yyyy-MM-dd').format(day.date) == todayString);
      });

      print("Is today favorited? $_isTodayFavorited");
    } catch (e) {
      print("Error checking favorites: $e");
    }
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentWeather =
          await _weatherService.getCurrentWeather(_latitude, _longitude);
      final forecast = await _weatherService.getForecast(_latitude, _longitude);

      setState(() {
        _currentWeather = currentWeather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data. Please try again.';
        _isLoading = false;
      });
    }
  }

   Future<void> _addToFavorites() async {
    if (_currentWeather == null) return;
    
    // If today is already favorited, show a message
    if (_isTodayFavorited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Today is already in your favorites!')),
        );
      }
      return;
    }

    try {
      final favoriteDay = await _favoriteDayService.addFavoriteDay(
          DateTime.now(), _currentWeather!);
      
      print("Added to favorites: ${favoriteDay.id}");
      
      setState(() {
        _isTodayFavorited = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Today added to favorites!')),
        );
      }
    } catch (e) {
      print("Error adding to favorites: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add to favorites: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadWeatherData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCurrentWeather(),
            _buildForecast(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    if (_currentWeather == null) return const SizedBox.shrink();

    final weatherData = _currentWeather!;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[400]!,
            Colors.blue[800]!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mumbai, India', 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('EEEE, d MMMM').format(now),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
               IconButton(
                icon: Icon(
                  _isTodayFavorited ? Icons.favorite : Icons.favorite_border, 
                  color: Colors.white
                ),
                onPressed: _addToFavorites,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weatherData.temperature.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    weatherData.description.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Image.asset(
                'assets/images/weather/${weatherData.icon}.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.cloud,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                Icons.water_drop,
                'Humidity',
                '${weatherData.humidity}%',
              ),
              _buildWeatherDetail(
                Icons.air,
                'Wind',
                '${weatherData.windSpeed} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForecast() {
    if (_forecast.isEmpty) return const SizedBox.shrink();

    // Group forecast by day (to show daily forecast)
    final Map<String, Weather> dailyForecast = {};
    for (var weather in _forecast) {
      final day = DateFormat('yyyy-MM-dd').format(weather.date);
      if (!dailyForecast.containsKey(day)) {
        dailyForecast[day] = weather;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyForecast.length,
              itemBuilder: (context, index) {
                final day = dailyForecast.keys.elementAt(index);
                final weather = dailyForecast[day]!;
                return _buildDailyForecastItem(weather);
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.take(24).length,
              itemBuilder: (context, index) {
                final weather = _forecast[index];
                return _buildHourlyForecastItem(weather);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastItem(Weather weather) {
    return Card(
      margin: const EdgeInsets.only(right: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 5,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E, MMM d').format(weather.date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/weather/${weather.icon}.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.cloud,
                  size: 50,
                  color: Colors.grey[600],
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              weather.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecastItem(Weather weather) {
    return Card(
      margin: const EdgeInsets.only(right: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 3,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(weather.date),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(
              'assets/images/weather/${weather.icon}.png',
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.cloud,
                  size: 30,
                  color: Colors.grey[600],
                );
              },
            ),
            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
