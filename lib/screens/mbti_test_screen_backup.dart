import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mbti_personality_provider.dart';
import '../widgets/simple_button.dart';
import '../widgets/simple_gradient_background.dart';

class MBTITestScreen extends StatefulWidget {
  const MBTITestScreen({super.key});

  @override
  State<MBTITestScreen> createState() => _MBTITestScreenState();
}

class _MBTITestScreenState extends State<MBTITestScreen>
    with TickerProviderStateMixin {
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() async {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    
    // Always reset test when entering test screen to ensure fresh start
    provider.resetTest();
    
    // Initialize ML service if not already initialized
    if (!provider.isLoading) {
      await provider.initializeML();
    }
    
    _initializeCurrentAnswer();
  }

  void _initializeCurrentAnswer() {
    try {
      final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
      final currentQuestion = provider.currentQuestion;
      final existingAnswer = provider.answers[currentQuestion.id] as int?;
      
      if (existingAnswer != null && mounted) {
        setState(() {
          _selectedOptionIndex = existingAnswer;
        });
      } else {
        setState(() {
          _selectedOptionIndex = null;
        });
      }
    } catch (e) {
      debugPrint('Error initializing current answer: $e');
    }
  }

  void _nextQuestion() {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    final currentQuestion = provider.currentQuestion;
    
    // Save current answer - MCQ uses index of selected option
    if (_selectedOptionIndex != null) {
      provider.answerQuestion(currentQuestion.id, _selectedOptionIndex!);
    }
    
    if (provider.hasNextQuestion) {
      provider.nextQuestion();
      _initializeCurrentAnswer();
    } else {
      _completeTest();
    }
  }

  void _previousQuestion() {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    
    if (provider.hasPreviousQuestion) {
      provider.previousQuestion();
      _initializeCurrentAnswer();
    }
  }

  void _completeTest() async {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    
    try {
      debugPrint('Starting MBTI test completion...');
      await provider.completeTest();
      debugPrint('MBTI test completion successful!');
      
      if (mounted) {
        debugPrint('Navigating to MBTI results...');
        context.go('/mbti-results');
      }
    } catch (e) {
      debugPrint('Error completing MBTI test: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing test: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MBTI Test',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<MBTIPersonalityProvider>(
          builder: (context, provider, child) {
            // Safety check - show loading if provider is loading or not properly initialized
            if (provider.isLoading || provider.questions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Initializing MBTI Assessment...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final currentQuestion = provider.currentQuestion;
            final progress = provider.progress;
            final isLastQuestion = !provider.hasNextQuestion;
                    final canProceed = _selectedOptionIndex != null; // Can proceed if an option is selected

                    return Column(
                      children: [
                        // Header with progress
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Back button and progress
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => context.go('/'),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Question ${provider.currentQuestionIndex + 1} of ${provider.questions.length}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 48), // Balance the back button
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Question content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: AnimatedQuestionCard(
                                questionTitle: currentQuestion.title,
                                questionText: currentQuestion.question,
                                options: currentQuestion.options ?? [],
                                selectedOptionIndex: _selectedOptionIndex,
                                onOptionSelected: (index) {
                                  setState(() {
                                    _selectedOptionIndex = index;
                                  });
                                },
                                questionIndex: provider.currentQuestionIndex,
                              ),
                            ),
                          ),
                        ),

                        // Navigation buttons
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              // Previous button
                              if (provider.hasPreviousQuestion)
                                Expanded(
                                  child: AnimatedButton(
                                    onPressed: _previousQuestion,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Previous',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              if (provider.hasPreviousQuestion) const SizedBox(width: 16),

                              // Next/Complete button
                              Expanded(
                                flex: provider.hasPreviousQuestion ? 1 : 2,
                                child: AnimatedButton(
                                  onPressed: canProceed ? _nextQuestion : null,
                                  backgroundColor: canProceed 
                                      ? null 
                                      : Colors.white.withOpacity(0.1),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                isLastQuestion ? 'Complete' : 'Next',
                                                style: TextStyle(
                                                  color: canProceed ? Colors.white : Colors.white.withOpacity(0.5),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              isLastQuestion ? Icons.check : Icons.arrow_forward,
                                              color: canProceed ? Colors.white : Colors.white.withOpacity(0.5),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }
}
