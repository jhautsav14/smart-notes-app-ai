import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class AIService {
  static Future<String?> askAI(String message) async {
    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer ${AppConstants.openRouterApiKey}",
          "Content-Type": "application/json",
          // OpenRouter recommends these headers for free models
          "HTTP-Referer": "https://github.com/your-repo",
          "X-Title": "Smart Notes App",
        },
        body: jsonEncode({
          "model": "meta-llama/llama-3-8b-instruct",
          "messages": [
            {
              "role": "user",
              "content":
                  "Summarize the following note into a concise, 1-sentence summary:\n\n$message"
            }
          ],
          "max_tokens": 200
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"].toString().trim();
      } else {
        print("AI Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
  }
}
