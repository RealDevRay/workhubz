import 'dart:convert';
import 'package:dio/dio.dart';

class GroqResult {
  final Map<String, dynamic>? data;
  final String? error;
  GroqResult({this.data, this.error});
}

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  final String _apiKey;
  final Dio _dio;

  GroqService()
    : _apiKey = const String.fromEnvironment('GROQ_API_KEY'),
      _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  Future<GroqResult> parseSearchQuery(String query) async {
    if (_apiKey.isEmpty) {
      return GroqResult(data: _localFallback(query));
    }

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'User-Agent': 'WorkHubz/1.0',
          },
        ),
        data: {
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You extract workspace search filters from user queries for Nairobi. '
                  'Valid neighborhoods: kilimani, westlands, cbd, ngongRoad, karen, lavington, '
                  'ridgeways, muthaiga, hurlingham, upperHill, kitengela, mlolongo, thikaRoad. '
                  'Valid amenities: wifi, parking, quiet, power_backup. '
                  'Return ONLY valid JSON with optional fields: neighborhood (string), '
                  'maxPrice (number in KES), amenities (array of strings). No markdown.',
            },
            {'role': 'user', 'content': query},
          ],
          'temperature': 0,
        },
      );

      if (response.statusCode != 200) {
        return GroqResult(data: _localFallback(query));
      }

      final body = response.data as Map<String, dynamic>;
      final content = body['choices'][0]['message']['content'] as String;

      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        return GroqResult(data: _localFallback(query));
      }

      final jsonStr = content.substring(jsonStart, jsonEnd + 1);
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GroqResult(data: parsed);
    } on DioException catch (e) {
      final body = e.response?.data;
      final code = body is Map ? body['error_code'] ?? '' : '';
      return GroqResult(
        data: _localFallback(query),
        error: 'Groq $code (${e.response?.statusCode})',
      );
    } catch (e) {
      return GroqResult(data: _localFallback(query));
    }
  }

  Map<String, dynamic> _localFallback(String query) {
    final lower = query.toLowerCase();
    final neighborhoods = [
      'kilimani',
      'westlands',
      'cbd',
      'ngongRoad',
      'karen',
      'lavington',
      'ridgeways',
      'muthaiga',
      'hurlingham',
      'upperHill',
      'kitengela',
      'mlolongo',
      'thikaRoad',
    ];
    final a = {
      'wifi': false,
      'parking': false,
      'quiet': false,
      'power_backup': false,
    };

    String? foundN;
    for (final n in neighborhoods) {
      final display = n.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => ' ${m.group(0)!.toLowerCase()}',
      );
      if (lower.contains(n) || lower.contains(display.trim())) {
        foundN = n;
        break;
      }
    }

    double? maxP;
    for (final m in RegExp(r'(\d{3,})').allMatches(lower)) {
      final num = int.tryParse(m.group(1) ?? '');
      if (num != null && num > 0 && num < 100000) {
        maxP = num.toDouble();
        break;
      }
    }

    if (lower.contains('wifi')) a['wifi'] = true;
    if (lower.contains('parking')) a['parking'] = true;
    if (lower.contains('quiet') || lower.contains('silent')) a['quiet'] = true;
    if (lower.contains('power') || lower.contains('backup')) {
      a['power_backup'] = true;
    }

    return {
      'neighborhood': foundN,
      'maxPrice': maxP,
      'amenities': a.entries.where((e) => e.value).map((e) => e.key).toList(),
    };
  }
}
