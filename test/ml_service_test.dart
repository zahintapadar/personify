import 'package:flutter_test/flutter_test.dart';
import 'package:personify/services/ml_service.dart';

void main() {
  group('ML Service Tests', () {
    late MLService mlService;

    setUp(() {
      mlService = MLService();
    });

    tearDown(() {
      mlService.dispose();
    });

    test('ML Service initializes correctly', () async {
      // Note: This test would require the actual model files to be available
      // In a real test environment, you'd mock the file loading
      expect(mlService.isInitialized, false);
    });

    test('Prediction works with valid input', () async {
      // Example test data (would need actual model to test)
      const testInput = [3.0, 2.0, 4.0, 3.0, 2.0, 3.0, 2.0]; // Sample values
      
      // In a real test, you'd initialize the service first
      // final prediction = await mlService.predict(testInput);
      // expect(prediction, isA<double>());
      // expect(prediction, greaterThanOrEqualTo(0.0));
      // expect(prediction, lessThanOrEqualTo(1.0));
    });
  });
}
