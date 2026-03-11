import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class AIService {
  static Future<String?> askAI(String message) async {
    try {
      // 1. The API key goes right into the URL here
      final url =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${AppConstants.geminiApiKey}";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Summarize the following note into a concise, 1-sentence summary:\n\n$message"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 2. Google's JSON response structure is slightly different
        return data["candidates"][0]["content"]["parts"][0]["text"]
            .toString()
            .trim();
      } else {
        print("Gemini API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
  }
}
