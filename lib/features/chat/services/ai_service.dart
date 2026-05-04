import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _defaultModel = 'mistralai/Mistral-7B-Instruct-v0.2';

  Future<String> sendMessage(
    List<Map<String, String>> history,
    String message,
  ) async {
    final String apiKey = dotenv.env['HF_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Missing HF_API_KEY in .env');
    }

    final String model = (dotenv.env['HF_MODEL']?.trim().isNotEmpty ?? false)
        ? dotenv.env['HF_MODEL']!.trim()
        : _defaultModel;

    final Uri uri = Uri.parse('$_baseUrl/$model');

    final String prompt = _buildPrompt(history, message);

    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'inputs': prompt,
        'parameters': <String, dynamic>{
          'max_new_tokens': 220,
          'temperature': 0.7,
          'return_full_text': false,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'AI request failed (${response.statusCode}): ${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final String text = _extractText(decoded).trim();
    if (text.isEmpty) {
      throw Exception('AI response was empty.');
    }

    return text;
  }

  String _buildPrompt(List<Map<String, String>> history, String message) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('You are SmartWear AI. Be concise, practical, and safe.')
      ..writeln('Focus on fitness, diet, and wearable health insights.')
      ..writeln();

    for (final Map<String, String> item in history) {
      final String role = item['role'] ?? 'user';
      final String content = item['content'] ?? '';
      if (content.trim().isEmpty) {
        continue;
      }
      buffer.writeln('${role.toUpperCase()}: $content');
    }

    buffer
      ..writeln('USER: $message')
      ..writeln('ASSISTANT:');

    return buffer.toString();
  }

  String _extractText(dynamic decoded) {
    if (decoded is List && decoded.isNotEmpty) {
      final dynamic first = decoded.first;
      if (first is Map<String, dynamic>) {
        final dynamic generatedText = first['generated_text'];
        if (generatedText is String) {
          return generatedText;
        }
        final dynamic summaryText = first['summary_text'];
        if (summaryText is String) {
          return summaryText;
        }
      }
    }

    if (decoded is Map<String, dynamic>) {
      final dynamic generatedText = decoded['generated_text'];
      if (generatedText is String) {
        return generatedText;
      }
      final dynamic errorMessage = decoded['error'];
      if (errorMessage is String && errorMessage.trim().isNotEmpty) {
        throw Exception('AI provider error: $errorMessage');
      }
    }

    return '';
  }
}
