import 'package:weather_forecast/main.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('WeatherForecastScreen', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    testWidgets('fetch weather forecast successfully',
        (WidgetTester tester) async {
      final mockResponse = '''
        {
          "coord": {
            "lon": 76.9667,
            "lat": 11
          },
          "weather": [
            {
              "id": 701,
              "main": "Mist",
              "description": "mist",
              "icon": "50n"
            },
            {
              "id": 500,
              "main": "Rain",
              "description": "light rain",
              "icon": "10n"
            }
          ],
          "base": "stations",
          "main": {
            "temp": 73.18,
            "feels_like": 74.1,
            "temp_min": 69.51,
            "temp_max": 73.18,
            "pressure": 1010,
            "humidity": 83
          },
          "visibility": 5000,
          "wind": {
            "speed": 17.27,
            "deg": 230
          },
          "rain": {
            "1h": 0.49
          },
          "clouds": {
            "all": 75
          },
          "dt": 1688405424,
          "sys": {
            "type": 1,
            "id": 9206,
            "country": "IN",
            "sunrise": 1688344408,
            "sunset": 1688390322
          },
          "timezone": 19800,
          "id": 1273865,
          "name": "Coimbatore",
          "cod": 200
        }
      ''';

      final endpoint = 'https://open-weather13.p.rapidapi.com/city/coimbatore';
      final headers = {
        'X-RapidAPI-Key': '468ffbed63mshb5b1a633855769dp12c7b8jsn36e097cebd6f',
        'X-RapidAPI-Host': 'open-weather13.p.rapidapi.com',
      };

      when(mockHttpClient.get(Uri.parse(endpoint), headers: headers))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      await tester.pumpWidget(WeatherForecastApp());

      final cityTextField = find.byType(TextField);
      final getForecastButton = find.byType(ElevatedButton);

      expect(cityTextField, findsOneWidget);
      expect(getForecastButton, findsOneWidget);

      await tester.enterText(cityTextField, 'Coimbatore');
      await tester.tap(getForecastButton);
      await tester.pumpAndSettle();

      expect(find.text('City: Coimbatore'), findsOneWidget);
      expect(find.text('Temperature: 73.2°C'), findsOneWidget);
      expect(find.text('Humidity: 83%'), findsOneWidget);
      expect(find.text('Conditions: mist'), findsOneWidget);
    });
  });
}
