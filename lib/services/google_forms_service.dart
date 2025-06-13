import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/personality_result.dart';

class GoogleFormsService {
  // Google Form URL 
  static const String _formUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSf73OsrKTX_RLNVDsAUtbL_sRmYVi1PB0oobO-fqN4MVgwIew/formResponse';
  
  // Form field entry IDs mapping
  static const Map<String, String> _fieldIds = {
    'personality_type': 'entry.1929450622',    // User's personality type (e.g., "infp")
    'traits': 'entry.487427128',               // User's personality traits
    'date': 'entry.885776606',                 // Date of test completion
    'q1': 'entry.1749937389',                  // Question 1 answer
    'q2': 'entry.1333882665',                  // Question 2 answer
    'q3': 'entry.1771680536',                  // Question 3 answer
    'q4': 'entry.166609206',                   // Question 4 answer
    'q5': 'entry.941223928',                   // Question 5 answer
    'q6': 'entry.799674604',                   // Question 6 answer
    'q7': 'entry.275419266',                   // Question 7 answer
    'q8': 'entry.1321935650',                  // Question 8 answer
    'q9': 'entry.493403096',                   // Question 9 answer
    'q10': 'entry.187055647',                  // Question 10 answer
    'q11': 'entry.1614443067',                 // Question 11 answer
    'q12': 'entry.1482226697',                 // Question 12 answer
    'q13': 'entry.2121172533',                 // Question 13 answer
    'q14': 'entry.164370552',                  // Question 14 answer
    'q15': 'entry.784863944',                  // Question 15 answer
    'q16': 'entry.146257679',                  // Question 16 answer (if exists)
  };

  /// Submit personality test results to Google Forms
  static Future<bool> submitTestResults({
    required PersonalityResult result,
    required Map<String, dynamic> answers,
    required List<dynamic> questions,
    String? formUrl,
  }) async {
    try {
      final String targetUrl = formUrl ?? _formUrl;
      
      // Prepare form data
      final Map<String, String> formData = {
        _fieldIds['personality_type']!: result.personalityType.toLowerCase(),
        _fieldIds['traits']!: result.traits.join(', '),
        _fieldIds['date']!: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      // Add question answers with actual option text
      int questionIndex = 1;
      for (var question in questions) {
        final fieldKey = 'q$questionIndex';
        if (_fieldIds.containsKey(fieldKey) && answers.containsKey(question.id)) {
          final answerValue = answers[question.id];
          final optionText = _getOptionTextFromQuestion(question, answerValue);
          formData[_fieldIds[fieldKey]!] = optionText;
          print('Personality Q$questionIndex (${question.id}): $answerValue -> $optionText');
          questionIndex++;
        }
      }

      // Debug: Print all form data
      print('Submitting personality test to Google Forms:');
      formData.forEach((key, value) {
        print('  $key: $value');
      });

      // Make HTTP POST request to Google Forms
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      print('Google Forms response status: ${response.statusCode}');
      print('Google Forms response body: ${response.body}');

      // Google Forms typically returns 200 even for successful submissions
      return response.statusCode >= 200 && response.statusCode < 400;
      
    } catch (e) {
      print('Error submitting personality test to Google Forms: $e');
      return false;
    }
  }

  /// Submit MBTI test results to Google Forms
  static Future<bool> submitMBTIResults({
    required String mbtiType,
    required Map<String, dynamic> answers,
    required List<dynamic> questions,
    String? formUrl,
  }) async {
    try {
      final String targetUrl = formUrl ?? _formUrl;
      
      // Prepare form data
      final Map<String, String> formData = {
        _fieldIds['personality_type']!: mbtiType.toUpperCase(), // Use uppercase for MBTI
        _fieldIds['traits']!: 'MBTI Test',
        _fieldIds['date']!: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      // Add question answers for MBTI with actual option text
      int questionIndex = 1;
      for (var question in questions) {
        final fieldKey = 'q$questionIndex';
        if (_fieldIds.containsKey(fieldKey) && answers.containsKey(question.id)) {
          final answerValue = answers[question.id];
          final optionText = _getOptionTextFromQuestion(question, answerValue);
          formData[_fieldIds[fieldKey]!] = optionText;
          print('MBTI Q$questionIndex (${question.id}): $answerValue -> $optionText');
          questionIndex++;
        }
      }

      // Debug: Print all form data
      print('Submitting MBTI test to Google Forms:');
      formData.forEach((key, value) {
        print('  $key: $value');
      });

      // Make HTTP POST request to Google Forms
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      print('Google Forms response status: ${response.statusCode}');
      print('Google Forms response body: ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 400;
      
    } catch (e) {
      print('Error submitting MBTI results to Google Forms: $e');
      return false;
    }
  }

  /// Get the actual option text that user selected from question and answer value
  static String _getOptionTextFromQuestion(dynamic question, dynamic answerValue) {
    try {
      // Handle different question types
      if (question.options != null && question.values != null) {
        final values = question.values as List<dynamic>;
        final options = question.options as List<dynamic>;
        
        // Try to find the answer value in the values array
        final valueIndex = values.indexOf(answerValue);
        if (valueIndex >= 0 && valueIndex < options.length) {
          return options[valueIndex].toString();
        }
        
        // If not found by value, try by index (0-based indexing)
        if (answerValue is int && answerValue >= 0 && answerValue < options.length) {
          return options[answerValue].toString();
        }
      }
      
      // Final fallback
      return answerValue.toString();
      
    } catch (e) {
      print('Error getting option text: $e');
      return answerValue.toString();
    }
  }

  /// Test connection to Google Forms
  static Future<bool> testConnection({String? formUrl}) async {
    try {
      final String targetUrl = formUrl ?? _formUrl;
      
      // Try to make a simple GET request to check if the form is accessible
      final response = await http.get(Uri.parse(targetUrl));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      print('Error testing Google Forms connection: $e');
      return false;
    }
  }

  /// Update form URL if needed
  static String updateFormUrl(String newFormUrl) {
    // Validate the URL format
    if (newFormUrl.contains('docs.google.com/forms') && 
        newFormUrl.contains('/formResponse')) {
      return newFormUrl;
    } else if (newFormUrl.contains('docs.google.com/forms')) {
      // Convert view URL to submission URL
      return newFormUrl.replaceAll('/viewform', '/formResponse');
    }
    throw ArgumentError('Invalid Google Forms URL format');
  }
}
