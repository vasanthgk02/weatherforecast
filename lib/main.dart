import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherForecastApp());
}

class WeatherForecastApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherForecastScreen(),
    );
  }
}

class WeatherForecastScreen extends StatefulWidget {
  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  TextEditingController _cityController = TextEditingController();
  String _cityName = '';
  WeatherForecast? _weatherForecast;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter city name',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchWeatherForecast,
              child: Text('Get Forecast'),
            ),
            SizedBox(height: 16.0),
            if (_isLoading)
              Center(
                  child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ))
            else if (_weatherForecast != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'City: ${_weatherForecast!.cityName}',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Temperature: ${_weatherForecast!.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Humidity: ${_weatherForecast!.humidity}%',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Conditions: ${_weatherForecast!.weatherConditions}',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchWeatherForecast() async {
    setState(() {
      _isLoading = true;
      _weatherForecast = null;
    });

    final cityName = _cityController.text;

    final url =
        Uri.parse('https://open-weather13.p.rapidapi.com/city/$cityName');
    final headers = {
      'X-RapidAPI-Key': '468ffbed63mshb5b1a633855769dp12c7b8jsn36e097cebd6f',
      'X-RapidAPI-Host': 'open-weather13.p.rapidapi.com',
    };

    try {
      final response = await http.get(url, headers: headers);
      final jsonData = jsonDecode(response.body);

      final cityName = jsonData['name'];
      final temperature = jsonData['main']['temp'].toDouble();
      final humidity = jsonData['main']['humidity'];
      final weatherConditions = jsonData['weather'][0]['description'];

      setState(() {
        _isLoading = false;
        _weatherForecast = WeatherForecast(
          cityName: cityName,
          temperature: temperature,
          humidity: humidity,
          weatherConditions: weatherConditions,
        );
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _weatherForecast = null;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch weather forecast. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class WeatherForecast {
  final String cityName;
  final double temperature;
  final int humidity;
  final String weatherConditions;

  WeatherForecast({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.weatherConditions,
  });
}
