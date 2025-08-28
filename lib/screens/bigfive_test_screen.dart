import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bigfive_personality_provider.dart';
import '../widgets/simple_button.dart';

class BigFiveTestScreen extends StatefulWidget {
  const BigFiveTestScreen({super.key});

  @override
  State<BigFiveTestScreen> createState() => _BigFiveTestScreenState();
}

class _BigFiveTestScreenState extends State<BigFiveTestScreen> {
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() async {
    final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
    provider.resetTest();
    if (!provider.isLoading) {
      await provider.initializeML();
    }
    _initializeCurrentAnswer();
  }

  void _initializeCurrentAnswer() {
    try {
      final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
      final currentQuestion = provider.currentQuestion;
      final existingAnswer = provider.answers[currentQuestion.id];
      
      if (existingAnswer != null && mounted) {
        setState(() {
          _selectedOptionIndex = existingAnswer;
        });
      }
    } catch (e) {
      debugPrint('Error initializing current answer: $e');
    }
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
    
    final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
    provider.answerCurrentQuestion(index);
  }

  void _nextQuestion() {
    final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
    
    if (provider.hasNextQuestion) {
      provider.nextQuestion();
      _updateSelectedOption();
    } else {
      _completeTest();
    }
  }

  void _previousQuestion() {
    final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
    
    if (provider.hasPreviousQuestion) {
      provider.previousQuestion();
      _updateSelectedOption();
    }
  }

  void _updateSelectedOption() {
    final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
    final currentQuestion = provider.currentQuestion;
    final existingAnswer = provider.answers[currentQuestion.id];
    
    setState(() {
      _selectedOptionIndex = existingAnswer;
    });
  }

  void _completeTest() async {
    final provider = Provider.of<BigFivePersonalityProvider>(context, listen: false);
    
    try {
      await provider.completeTest();
      if (mounted) {
        context.push('/bigfive-result');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Big Five Test',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<BigFivePersonalityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || provider.questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Initializing Big Five Assessment...',
                      style: GoogleFonts.roboto(
                        color: colorScheme.onSurface,
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
            final canProceed = _selectedOptionIndex != null;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${provider.currentQuestionIndex + 1} of ${provider.questions.length}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Question content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trait indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getTraitColor(currentQuestion.trait).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getTraitColor(currentQuestion.trait),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getTraitName(currentQuestion.trait),
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getTraitColor(currentQuestion.trait),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Question title
                        Text(
                          currentQuestion.title,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Question text
                        Text(
                          currentQuestion.question,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentQuestion.options.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedOptionIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _selectOption(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? colorScheme.primary.withOpacity(0.1)
                                          : colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected 
                                            ? colorScheme.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected 
                                                ? colorScheme.primary
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected 
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Icon(
                                                  Icons.check,
                                                  color: colorScheme.onPrimary,
                                                  size: 12,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            currentQuestion.options[index],
                                            style: GoogleFonts.roboto(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      if (provider.hasPreviousQuestion)
                        Expanded(
                          child: SimpleButton(
                            text: 'Previous',
                            onPressed: _previousQuestion,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            textColor: colorScheme.onSurface,
                          ),
                        ),
                      
                      if (provider.hasPreviousQuestion) const SizedBox(width: 16),
                      
                      Expanded(
                        flex: provider.hasPreviousQuestion ? 1 : 2,
                        child: SimpleButton(
                          text: isLastQuestion ? 'Complete Test' : 'Next',
                          onPressed: canProceed ? _nextQuestion : () {},
                          backgroundColor: canProceed 
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          textColor: canProceed 
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getTraitColor(String trait) {
    switch (trait) {
      case 'O': return Colors.purple;
      case 'C': return Colors.blue;
      case 'E': return Colors.orange;
      case 'A': return Colors.green;
      case 'N': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getTraitName(String trait) {
    switch (trait) {
      case 'O': return 'Openness';
      case 'C': return 'Conscientiousness';
      case 'E': return 'Extraversion';
      case 'A': return 'Agreeableness';
      case 'N': return 'Neuroticism';
      default: return 'Unknown';
    }
  }
}
