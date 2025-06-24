import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/personality_result.dart';
import '../models/mbti_personality_result.dart';

class SupabaseService {
  static String _tableName =
      'personify'; // Make this mutable so we can update it

  // Get the Supabase client
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Update the table name if a different one is found to work
  static void updateTableName(String tableName) {
    _tableName = tableName;
    debugPrint('Updated table name to: $_tableName');
  }

  /// Submit personality test results to Supabase
  static Future<bool> submitPersonalityTest({
    required PersonalityResult result,
    required Map<String, dynamic> answers,
  }) async {
    try {
      // Prepare the data for insertion
      final data = {
        'Q1': answers['time_alone']?.toString() ?? '',
        'Q2': answers['social_events']?.toString() ?? '',
        'Q3': answers['decision_making']?.toString() ?? '',
        'Q4': answers['work_environment']?.toString() ?? '',
        'Q5': answers['communication_style']?.toString() ?? '',
        'Q6': answers['problem_solving']?.toString() ?? '',
        'Q7': answers['energy_source']?.toString() ?? '',
        'Q8': answers['planning_style']?.toString() ?? '',
        'Q9': answers['stress_response']?.toString() ?? '',
        'Q10': answers['learning_style']?.toString() ?? '',
        'Q11': answers['conflict_resolution']?.toString() ?? '',
        'Q12': answers['motivation']?.toString() ?? '',
        'Q13': answers['change_adaptation']?.toString() ?? '',
        'Q14': answers['team_role']?.toString() ?? '',
        'Q15': answers['life_goals']?.toString() ?? '',
        'PersonalityType': result.personalityType,
        'TimeStamp': DateTime.now().toIso8601String(),
        'Traits': {
          'confidence': result.confidence,
          'description': result.description,
          'traits': result.traits,
          'strengths': result.strengths,
          'tips': result.tips,
        },
      };

      await _client.from(_tableName).insert(data);

      debugPrint('Successfully submitted personality test to Supabase');
      return true;
    } catch (error) {
      debugPrint('Error submitting personality test to Supabase: $error');
      return false;
    }
  }

  /// Submit MBTI test results to Supabase
  static Future<bool> submitMBTITest({
    required MBTIPersonalityResult result,
    required Map<String, dynamic> answers,
  }) async {
    try {
      // Map MBTI answers to Q1-Q15 format
      final answersList = answers.values.toList();
      final data = {
        'Q1': answersList.isNotEmpty ? answersList[0]?.toString() ?? '' : '',
        'Q2': answersList.length > 1 ? answersList[1]?.toString() ?? '' : '',
        'Q3': answersList.length > 2 ? answersList[2]?.toString() ?? '' : '',
        'Q4': answersList.length > 3 ? answersList[3]?.toString() ?? '' : '',
        'Q5': answersList.length > 4 ? answersList[4]?.toString() ?? '' : '',
        'Q6': answersList.length > 5 ? answersList[5]?.toString() ?? '' : '',
        'Q7': answersList.length > 6 ? answersList[6]?.toString() ?? '' : '',
        'Q8': answersList.length > 7 ? answersList[7]?.toString() ?? '' : '',
        'Q9': answersList.length > 8 ? answersList[8]?.toString() ?? '' : '',
        'Q10': answersList.length > 9 ? answersList[9]?.toString() ?? '' : '',
        'Q11': answersList.length > 10 ? answersList[10]?.toString() ?? '' : '',
        'Q12': answersList.length > 11 ? answersList[11]?.toString() ?? '' : '',
        'Q13': answersList.length > 12 ? answersList[12]?.toString() ?? '' : '',
        'Q14': answersList.length > 13 ? answersList[13]?.toString() ?? '' : '',
        'Q15': answersList.length > 14 ? answersList[14]?.toString() ?? '' : '',
        'PersonalityType': result.mbtiType,
        'TimeStamp': DateTime.now().toIso8601String(),
        'Traits': {
          'confidence': result.confidence,
          'description': result.description,
          'traits': result.traits,
          'strengths': result.strengths,
          'weaknesses': result.weaknesses,
          'tips': result.tips,
          'typeProbabilities': result.typeProbabilities,
          'cognitiveStack': result.cognitiveStack,
          'careerSuggestions': result.careerSuggestions,
        },
      };

      debugPrint('Attempting to insert MBTI data: $data');

      await _client.from(_tableName).insert(data);

      debugPrint('Successfully submitted MBTI test to Supabase');
      return true;
    } catch (error) {
      debugPrint('Error submitting MBTI test to Supabase: $error');
      debugPrint('Error type: ${error.runtimeType}');
      if (error is PostgrestException) {
        debugPrint('PostgrestException details:');
        debugPrint('  Message: ${error.message}');
        debugPrint('  Code: ${error.code}');
        debugPrint('  Details: ${error.details}');
        debugPrint('  Hint: ${error.hint}');
      }
      return false;
    }
  }

  /// Retrieve all personality test results from Supabase
  static Future<List<Map<String, dynamic>>> getAllResults() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('TimeStamp', ascending: false);

      debugPrint('Retrieved ${response.length} results from Supabase');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Error retrieving results from Supabase: $error');
      return [];
    }
  }

  /// Retrieve results by personality type
  static Future<List<Map<String, dynamic>>> getResultsByType(
    String personalityType,
  ) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('PersonalityType', personalityType)
          .order('TimeStamp', ascending: false);

      debugPrint(
        'Retrieved ${response.length} results for type $personalityType from Supabase',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Error retrieving results by type from Supabase: $error');
      return [];
    }
  }

  /// Get statistics about personality types
  static Future<Map<String, int>> getPersonalityTypeStats() async {
    try {
      final response = await _client.from(_tableName).select('PersonalityType');

      final stats = <String, int>{};
      for (final row in response) {
        final type = row['PersonalityType'] as String?;
        if (type != null && type.isNotEmpty) {
          stats[type] = (stats[type] ?? 0) + 1;
        }
      }

      debugPrint('Retrieved personality type statistics from Supabase: $stats');
      return stats;
    } catch (error) {
      debugPrint(
        'Error retrieving personality type statistics from Supabase: $error',
      );
      return {};
    }
  }

  /// Delete a specific result by ID
  static Future<bool> deleteResult(int id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);

      debugPrint('Successfully deleted result with ID $id from Supabase');
      return true;
    } catch (error) {
      debugPrint('Error deleting result from Supabase: $error');
      return false;
    }
  }

  /// Test the connection to Supabase
  static Future<bool> testConnection() async {
    try {
      await _client.from(_tableName).select('id').limit(1);

      debugPrint('Supabase connection test successful');
      return true;
    } catch (error) {
      debugPrint('Supabase connection test failed: $error');
      return false;
    }
  }

  /// Get recent test submissions (last 24 hours)
  static Future<List<Map<String, dynamic>>> getRecentSubmissions() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));

      final response = await _client
          .from(_tableName)
          .select()
          .gte('TimeStamp', yesterday.toIso8601String())
          .order('TimeStamp', ascending: false);

      debugPrint(
        'Retrieved ${response.length} recent submissions from Supabase',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Error retrieving recent submissions from Supabase: $error');
      return [];
    }
  }

  /// Verify table structure and accessibility
  static Future<Map<String, dynamic>> verifyTable() async {
    try {
      // Try to get table schema information
      final response = await _client.from(_tableName).select('*').limit(1);

      debugPrint('Table verification successful. Sample response: $response');
      return {
        'success': true,
        'message': 'Table exists and is accessible',
        'sampleData': response,
      };
    } catch (error) {
      debugPrint('Table verification failed: $error');
      return {
        'success': false,
        'message': 'Table verification failed: $error',
        'error': error.toString(),
      };
    }
  }

  /// List all available tables (for debugging)
  static Future<void> listTables() async {
    try {
      // This is a more general approach to test the connection
      // and see what tables are available
      final tables = ['Personify', 'personify', 'PERSONIFY', 'Personality'];

      for (final tableName in tables) {
        try {
          final response = await _client.from(tableName).select('*').limit(1);
          debugPrint(
            'Table "$tableName" exists and returned: ${response.length} rows',
          );
        } catch (e) {
          debugPrint('Table "$tableName" not accessible: $e');
        }
      }
    } catch (error) {
      debugPrint('Error listing tables: $error');
    }
  }

  /// Try different table name variations to find the correct one
  static Future<String?> findCorrectTableName() async {
    final possibleNames = [
      'Personify', // Original case
      'personify', // Lowercase
      'PERSONIFY', // Uppercase
      'Personality', // Alternative name
      'personality', // Alternative lowercase
      'personality_results', // Possible descriptive name
      'test_results', // Generic name
    ];

    for (final tableName in possibleNames) {
      try {
        debugPrint('Testing table name: $tableName');
        await _client.from(tableName).select('id').limit(1);

        debugPrint('✅ Found working table: $tableName');
        updateTableName(tableName); // Update the table name for future use
        return tableName;
      } catch (e) {
        debugPrint('❌ Table "$tableName" failed: $e');
      }
    }

    debugPrint('❌ No working table found');
    return null;
  }
}
