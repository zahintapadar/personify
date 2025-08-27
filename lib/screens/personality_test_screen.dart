import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/personality_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_button.dart';
import '../widgets/question_card.dart';
import '../widgets/progress_indicator_custom.dart';

class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _questionFadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _questionFadeAnimation;
  late Animation<Offset> _questionSlideAnimation;
  int? _selectedAnswer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCurrentAnswer();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _questionFadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _questionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionFadeController,
      curve: Curves.easeInOut,
    ));

    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _questionFadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _questionFadeController.forward();
  }

  void _initializeCurrentAnswer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PersonalityProvider>(context, listen: false);
      if (provider.questions.isNotEmpty && 
          provider.currentQuestionIndex < provider.questions.length) {
        final currentQuestionId = provider.currentQuestion.id;
        setState(() {
          _selectedAnswer = provider.answers[currentQuestionId];
        });
      }
    });
  }

  void _selectAnswer(int value) {
    setState(() {
      _selectedAnswer = value;
    });
    
    final provider = Provider.of<PersonalityProvider>(context, listen: false);
    provider.answerQuestion(provider.currentQuestion.id, value);
  }

  Future<void> _nextQuestion() async {
    if (_selectedAnswer == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<PersonalityProvider>(context, listen: false);
    
    try {
      if (provider.hasNextQuestion) {
        // Fade out current question
        await _questionFadeController.reverse();
        
        provider.nextQuestion();
        // Clear selection for new question instead of auto-selecting previous answer
        setState(() {
          _selectedAnswer = null;
        });
        
        // Small delay for smooth transition
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Fade in new question
        await _questionFadeController.forward();
      } else {
        await provider.completeTest();
        if (mounted) {
          context.go('/results');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _previousQuestion() async {
    if (_isLoading) return;

    final provider = Provider.of<PersonalityProvider>(context, listen: false);
    
    if (provider.hasPreviousQuestion) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Fade out current question
        await _questionFadeController.reverse();
        
        provider.previousQuestion();
        final prevQuestionId = provider.currentQuestion.id;
        setState(() {
          _selectedAnswer = provider.answers[prevQuestionId];
        });
        
        // Small delay for smooth transition
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Fade in previous question
        await _questionFadeController.forward();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _questionFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Consumer<PersonalityProvider>(
            builder: (context, provider, child) {
              if (provider.questions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading questions...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.currentQuestionIndex >= provider.questions.length) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Test completed!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: _isLoading ? null : (provider.hasPreviousQuestion
                                    ? _previousQuestion
                                    : () => context.go('/')),
                                icon: Icon(
                                  provider.hasPreviousQuestion 
                                      ? Icons.arrow_back_ios 
                                      : Icons.home,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: CustomProgressIndicator(
                                  progress: provider.progress,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  progressColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${provider.currentQuestionIndex + 1}/${provider.questions.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            provider.currentQuestion.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: FadeTransition(
                          opacity: _questionFadeAnimation,
                          child: SlideTransition(
                            position: _questionSlideAnimation,
                            child: QuestionCard(
                              question: provider.currentQuestion,
                              selectedAnswer: _selectedAnswer,
                              onAnswerSelected: _selectAnswer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          if (provider.hasPreviousQuestion) ...[
                            Expanded(
                              child: AnimatedButton(
                                onPressed: _isLoading ? null : _previousQuestion,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: const Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          Expanded(
                            flex: provider.hasPreviousQuestion ? 1 : 2,
                            child: AnimatedButton(
                              onPressed: (_selectedAnswer != null && !_isLoading)
                                  ? _nextQuestion
                                  : null,
                              backgroundColor: _selectedAnswer != null 
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                      ),
                                    )
                                  : Text(
                                      provider.hasNextQuestion ? 'Next' : 'Get Results',
                                      style: TextStyle(
                                        color: _selectedAnswer != null 
                                            ? const Color(0xFF6C63FF)
                                            : Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
