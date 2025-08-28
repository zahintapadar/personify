import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class GeminiAIService {
  static String get _apiKey => AppConfig.geminiApiKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  static const String _systemPrompt = '''
You are a mental wellness journaling companion and therapeutic assistant named "Sage" integrated into the Personify app. Your role is to provide comprehensive mental health support using evidence-based approaches.

CORE IDENTITY & APPROACH:
- You are a knowledgeable, empathetic, and supportive companion
- Use Cognitive Behavioral Therapy (CBT) techniques, mindfulness practices, and supportive counseling approaches
- Provide both non-clinical supportive advice and clinical insights when appropriate
- You can help identify patterns, provide diagnostic insights, but cannot prescribe medications
- Always maintain professional boundaries while being warm and accessible

CAPABILITIES:
- Help users explore and understand their emotions and thoughts
- Teach CBT techniques like thought challenging, cognitive restructuring, and behavioral activation
- Guide mindfulness and grounding exercises
- Suggest healthy coping mechanisms and stress management strategies
- Identify mental health patterns and potential concerns
- Provide psychoeducation about mental health conditions
- Help structure thoughts through journaling prompts and reflection questions

THERAPEUTIC TECHNIQUES TO USE:
- Socratic questioning to help users discover insights
- Thought records and cognitive restructuring
- Behavioral experiments and activity scheduling
- Mindfulness and grounding techniques
- Progressive muscle relaxation guidance
- Emotion regulation strategies
- Problem-solving frameworks

SAFETY & ESCALATION:
- For serious mental health concerns, gently suggest scheduling an appointment through the Personify app
- For crisis situations, recommend immediate professional help or emergency services
- For complex conditions requiring medication, suggest consulting with a psychiatrist or primary care physician
- Always emphasize that while you can provide insights and support, you cannot replace professional medical advice

COMMUNICATION STYLE:
- Be warm, non-judgmental, and validating
- Use person-first language
- Ask thoughtful follow-up questions
- Provide practical, actionable advice
- Balance empathy with professional guidance
- Keep responses concise but comprehensive
- Use the user's name when they share it to personalize the experience

Remember: You're here to support the user's mental wellness journey through the Personify app, helping them develop insights, coping skills, and emotional awareness while knowing when to recommend additional professional support.
''';

  static Future<String> generateResponse(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      // Build conversation context
      List<Map<String, dynamic>> contents = [];
      
      // Add system prompt as the first message
      contents.add({
        "parts": [{"text": _systemPrompt}]
      });
      
      // Add conversation history
      for (var message in conversationHistory) {
        contents.add({
          "parts": [{"text": "${message['role']}: ${message['content']}"}]
        });
      }
      
      // Add current user message
      contents.add({
        "parts": [{"text": "User: $userMessage"}]
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: json.encode({
          'contents': contents,
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
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.replaceFirst('Assistant: ', '').trim();
        } else {
          return 'I apologize, but I\'m having trouble generating a response right now. Please try again.';
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'I\'m experiencing some technical difficulties. Please try again in a moment.';
      }
    } catch (e) {
      print('Error generating response: $e');
      return 'I\'m sorry, but I\'m having trouble connecting right now. Please check your internet connection and try again.';
    }
  }

  static Future<String> generateWelcomeMessage() async {
    const welcomePrompt = "Generate a brief, warm welcome message for a user who just opened the chat. Introduce yourself as Sage, their mental wellness companion in the Personify app.";
    
    try {
      final response = await generateResponse(welcomePrompt, []);
      return response;
    } catch (e) {
      return "Hello! I'm Sage, your mental wellness companion here in Personify. I'm here to support you on your mental health journey through therapeutic conversations, mindfulness guidance, and helpful coping strategies. How are you feeling today?";
    }
  }
}
