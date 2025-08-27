import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mbti_personality_provider.dart';
import '../widgets/simple_button.dart';

class MBTITestScreen extends StatefulWidget {
  const MBTITestScreen({super.key});

  @override
  State<MBTITestScreen> createState() => _MBTITestScreenState();
}

class _MBTITestScreenState extends State<MBTITestScreen> {
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() async {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    provider.resetTest();
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
      }
    } catch (e) {
      debugPrint('Error initializing current answer: $e');
    }
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
    
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    provider.answerQuestion(provider.currentQuestion.id, index);
  }

  void _nextQuestion() async {
    if (_selectedOptionIndex == null) return;
    
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    
    try {
      if (provider.hasNextQuestion) {
        provider.nextQuestion();
        // Clear selection for new question instead of initializing with previous answer
        setState(() {
          _selectedOptionIndex = null;
        });
      } else {
        await provider.completeTest();
        if (mounted) {
          context.push('/mbti-results');
        }
      }
    } catch (e) {
      debugPrint('Error in next question: $e');
    }
  }

  void _previousQuestion() {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    if (provider.hasPreviousQuestion) {
      provider.previousQuestion();
      // For previous questions, we can show the existing answer since user might want to review/change it
      _initializeCurrentAnswer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MBTI Test',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<MBTIPersonalityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || provider.questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Initializing MBTI Assessment...',
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
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Question
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentQuestion.options?.length ?? 0,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedOptionIndex == index;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _selectOption(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? const Color(0xFF8B5CF6).withOpacity(0.2)
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected 
                                              ? const Color(0xFF8B5CF6)
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected 
                                                  ? const Color(0xFF8B5CF6)
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isSelected 
                                                    ? const Color(0xFF8B5CF6)
                                                    : Colors.grey[600]!,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check,
                                                    color: colorScheme.onPrimary,
                                                    size: 16,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              currentQuestion.options?[index] ?? '',
                                              style: GoogleFonts.roboto(
                                                fontSize: 16,
                                                color: colorScheme.onSurface,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                      if (provider.hasPreviousQuestion) ...[
                        Expanded(
                          child: SimpleButton(
                            text: 'Previous',
                            onPressed: _previousQuestion,
                            isOutlined: true,
                            icon: Icons.arrow_back,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: SimpleButton(
                          text: isLastQuestion ? 'Complete' : 'Next',
                          onPressed: canProceed ? _nextQuestion : () {},
                          backgroundColor: canProceed 
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey[700],
                          icon: isLastQuestion ? Icons.check : Icons.arrow_forward,
                          isLoading: provider.isLoading,
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
}
