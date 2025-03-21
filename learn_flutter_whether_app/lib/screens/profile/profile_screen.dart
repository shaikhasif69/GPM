import 'package:flutter/material.dart';
import '../../models/favorite_day_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/favorite_day_service.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FavoriteDayService _favoriteDayService = FavoriteDayService();

  User? _user;
  List<FavoriteDay> _favoriteDays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUser();

      if (user != null) {
        final favoriteDays = await _favoriteDayService.getUserFavoriteDays();

        setState(() {
          _user = user;
          _favoriteDays = favoriteDays;
          _isLoading = false;
        });
      } else {
        _logout();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _removeFavoriteDay(String id) async {
    try {
      await _favoriteDayService.removeFavoriteDay(id);

      setState(() {
        _favoriteDays.removeWhere((day) => day.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorite day removed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to remove favorite day: ${e.toString()}')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildFavoriteDaysSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    if (_user == null) return const SizedBox.shrink();

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              const AssetImage('assets/images/default_profile.jpeg'),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(height: 15),
        Text(
          _user!.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _user!.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Joined: ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Weather Days',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _favoriteDays.isEmpty
            ? _buildEmptyFavoritesMessage()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _favoriteDays.length,
                itemBuilder: (context, index) {
                  return _buildFavoriteDayItem(_favoriteDays[index]);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyFavoritesMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 10),
          Text(
            'No favorite days yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Tap the heart icon on the weather screen to add today to your favorites.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteDayItem(FavoriteDay favoriteDay) {
    final weatherData = favoriteDay.weatherData;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(
              _getWeatherIcon(weatherData.icon),
              size: 50,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(favoriteDay.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${weatherData.temperature.round()}°C - ${weatherData.description}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Humidity: ${weatherData.humidity}% | Wind: ${weatherData.windSpeed} km/h',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(favoriteDay.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Favorite'),
          content: const Text(
              'Are you sure you want to remove this day from your favorites?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFavoriteDay(id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
  
IconData _getWeatherIcon(String iconCode) {
  if (iconCode.startsWith('01')) return Icons.wb_sunny;
  if (iconCode.startsWith('02')) return Icons.cloudy_snowing;
  if (iconCode.startsWith('03') || iconCode.startsWith('04')) return Icons.cloud;
  if (iconCode.startsWith('09')) return Icons.grain;
  if (iconCode.startsWith('10')) return Icons.beach_access;
  if (iconCode.startsWith('11')) return Icons.flash_on;
  if (iconCode.startsWith('13')) return Icons.ac_unit;
  if (iconCode.startsWith('50')) return Icons.blur_on;
  return Icons.cloud;  
}
}