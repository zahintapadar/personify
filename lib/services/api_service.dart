import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _apiKey = 'AIzaSyB4WazzCTpwn4OzMDgW6SndembmYOL-NPM';
  
  static String _buildSystemPrompt(String userName) {
    return '''
You are Sage, a mental wellness companion and therapeutic assistant integrated into the Personify app. Your role is to provide comprehensive mental health support using evidence-based approaches.

CORE IDENTITY & APPROACH:
- You are a knowledgeable, empathetic, and supportive companion
- Use Cognitive Behavioral Therapy (CBT) techniques, mindfulness practices, and supportive counseling approaches
- Provide both non-clinical supportive advice and clinical insights when appropriate
- You can help identify patterns, provide diagnostic insights, but cannot prescribe medications
- Always maintain professional boundaries while being warm and accessible

CRISIS DETECTION:
If a user expresses thoughts of self-harm, suicide, or immediate danger to themselves or others, you MUST respond with a JSON object containing {"crisis": true, "message": "I'm concerned about your safety. Please reach out to a crisis helpline immediately."} and nothing else.

Crisis indicators include but are not limited to:
- Suicidal ideation or planning
- Self-harm intentions
- Expressions of hopelessness with harmful intent
- Threats to harm others
- Severe mental health crisis requiring immediate intervention

CAPABILITIES:
- Help users explore and understand their emotions and thoughts
- Teach CBT techniques like thought challenging, cognitive restructuring, and behavioral activation
- Guide mindfulness and grounding exercises
- Suggest healthy coping mechanisms and stress management strategies
- Identify mental health patterns and potential concerns
- Provide psychoeducation about mental health conditions
- Help structure thoughts through journaling prompts and reflection questions

COMMUNICATION STYLE:
- Be warm, non-judgmental, and validating
- Use person-first language
- Ask thoughtful follow-up questions
- Provide practical, actionable advice
- Balance empathy with professional guidance
- Keep responses concise but comprehensive
- When addressing the user, call them "$userName" (their actual name from Google Sign-In)

Remember: You're here to support $userName's mental wellness journey through the Personify app, helping them develop insights, coping skills, and emotional awareness while prioritizing their safety above all else.
''';
  }

  /// Sends a message and returns a stream of text chunks for real-time display
  static Stream<String> sendMessageStream(String userId, String message, {String userName = 'User'}) async* {
    try {
      final response = await _makeRequest(userId, message, userName: userName);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check for crisis response
        if (_isCrisisResponse(data)) {
          yield json.encode({"crisis": true, "message": "I'm concerned about your safety. Please reach out to a crisis helpline immediately."});
          return;
        }
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          
          // Check if the response itself indicates a crisis
          if (_containsCrisisIndicators(text)) {
            yield json.encode({"crisis": true, "message": "I'm concerned about your safety. Please reach out to a crisis helpline immediately."});
            return;
          }
          
          // Simulate streaming by yielding chunks
          final words = text.split(' ');
          String currentChunk = '';
          
          for (int i = 0; i < words.length; i++) {
            currentChunk += '${words[i]} ';
            
            // Yield every 3-5 words to simulate streaming
            if (i % 4 == 0 && i > 0) {
              yield currentChunk.trim();
              currentChunk = '';
              
              // Add small delay to simulate real streaming
              await Future.delayed(const Duration(milliseconds: 50));
            }
          }
          
          // Yield remaining text
          if (currentChunk.isNotEmpty) {
            yield currentChunk.trim();
          }
        } else {
          throw ApiException('No response generated');
        }
      } else if (response.statusCode == 429) {
        throw QuotaExceededException('Monthly message limit exceeded');
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('Connection error');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      if (e is ApiException || e is QuotaExceededException || e is NetworkException) {
        rethrow;
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Sends a complete message and returns the full response
  static Future<Map<String, dynamic>> sendMessage(String userId, String message, {String userName = 'User'}) async {
    try {
      final response = await _makeRequest(userId, message, userName: userName);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check for crisis response
        if (_isCrisisResponse(data)) {
          return {"crisis": true, "message": "I'm concerned about your safety. Please reach out to a crisis helpline immediately."};
        }
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          
          // Check if the response itself indicates a crisis
          if (_containsCrisisIndicators(text)) {
            return {"crisis": true, "message": "I'm concerned about your safety. Please reach out to a crisis helpline immediately."};
          }
          
          return {"crisis": false, "message": text.trim()};
        } else {
          throw ApiException('No response generated');
        }
      } else if (response.statusCode == 429) {
        throw QuotaExceededException('Monthly message limit exceeded');
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('Connection error');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      if (e is ApiException || e is QuotaExceededException || e is NetworkException) {
        rethrow;
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  static Future<http.Response> _makeRequest(String userId, String message, {String userName = 'User'}) async {
    final uri = Uri.parse(_baseUrl);
    
    final systemPrompt = _buildSystemPrompt(userName);
    
    final body = {
      'contents': [
        {
          'parts': [
            {'text': '$systemPrompt\n\nUser: $message'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    };

    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey,
      },
      body: json.encode(body),
    ).timeout(const Duration(seconds: 30));
  }

  static bool _isCrisisResponse(Map<String, dynamic> data) {
    try {
      if (data['crisis'] == true) return true;
      
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      return _containsCrisisIndicators(text);
    } catch (e) {
      return false;
    }
  }

  static bool _containsCrisisIndicators(String text) {
    final crisisKeywords = [
      'suicide', 'kill myself', 'end my life', 'hurt myself', 
      'self harm', 'want to die', 'better off dead', 'no point living',
      'harm others', 'hurt someone', 'violence'
    ];
    
    final lowerText = text.toLowerCase();
    return crisisKeywords.any((keyword) => lowerText.contains(keyword));
  }
}

// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException(this.message);
  
  @override
  String toString() => message;
}
