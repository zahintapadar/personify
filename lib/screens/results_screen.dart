import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../providers/personality_provider.dart';
import '../providers/mbti_personality_provider.dart';
import '../models/personality_result.dart';
import '../models/mbti_personality_result.dart';
import '../widgets/gradient_background.dart';
import '../widgets/result_card.dart';
import '../widgets/trait_chip.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  void _retakeTest() {
    final provider = Provider.of<PersonalityProvider>(context, listen: false);
    provider.resetTest();
    context.go('/');
  }

  Widget _buildScreenshotContent(PersonalityResult result, {bool isMBTI = false, MBTIPersonalityResult? mbtiResult}) {
    return Container(
      width: 400, // Fixed width for consistent screenshots
      height: isMBTI ? 1400 : 700, // Increased height for MBTI content with all sections
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF421DA9),
            Color(0xFFFF5934),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header
            Text(
              'Your Results',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main Result Card - simplified for screenshot
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    result.personalityType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confidence: ${(result.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Your Personality',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.description.length > 150 
                        ? '${result.description.substring(0, 150)}...' 
                        : result.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Key Traits
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Traits',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (result.traits as List<dynamic>)
                        .take(6) // Limit traits for space
                        .map<Widget>((trait) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            trait.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
            
            // MBTI-specific content
            if (isMBTI && mbtiResult != null) ...[
              const SizedBox(height: 20),
              
              // Strengths & Growth Areas for MBTI
              Row(
                children: [
                  // Strengths
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.green.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Strengths',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...mbtiResult.strengths.take(3).map((strength) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 3,
                                  margin: const EdgeInsets.only(top: 6, right: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[200],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    strength,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Growth Areas
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: Colors.orange.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Growth Areas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...mbtiResult.weaknesses.take(3).map((weakness) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 3,
                                  margin: const EdgeInsets.only(top: 6, right: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[200],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    weakness,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Tips for Growth (MBTI only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.purple.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tips for Growth',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...mbtiResult.tips.take(3).map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.only(top: 6, right: 6),
                            decoration: BoxDecoration(
                              color: Colors.purple[200],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Career Suggestions (MBTI only)
              if (mbtiResult.careerSuggestions.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.blue.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Career Suggestions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: mbtiResult.careerSuggestions.take(4).map((career) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              career,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ),
                ),
            ],
            
            const Spacer(),
            
            // Footer
            Text(
              'Generated by Personify',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareResult() async {
    if (_isSharing) return;
    
    setState(() {
      _isSharing = true;
    });

    try {
      // Get the appropriate result from the correct provider based on route
      final provider = Provider.of<PersonalityProvider>(context, listen: false);
      final mbtiProvider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
      
      final result = provider.result;
      final mbtiResult = mbtiProvider.result;
      
      // Determine which test result to use based on current route
      final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation;
      final isMBTIRoute = currentRoute.contains('mbti-results');
      
      // Check which result to use based on route
      dynamic currentResult;
      if (isMBTIRoute && mbtiResult != null) {
        currentResult = _convertMBTIToPersonalityResult(mbtiResult);
      } else if (!isMBTIRoute && result != null) {
        currentResult = result;
      } else {
        return; // No appropriate result available
      }

      // Create a screenshot widget specifically for sharing
      final screenshotWidget = RepaintBoundary(
        child: _buildScreenshotContent(
          currentResult, 
          isMBTI: isMBTIRoute,
          mbtiResult: isMBTIRoute ? mbtiResult : null,
        ),
      );

      // Use a temporary screenshot controller for this specific widget
      final tempController = ScreenshotController();
      final image = await tempController.captureFromWidget(screenshotWidget);
      
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/personality_result.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath)], text: 'Check out my personality test result!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing result: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _saveScreenshot() async {
    if (_isSharing) return;
    
    setState(() {
      _isSharing = true;
    });

    try {
      // Get the appropriate result from the correct provider based on route
      final provider = Provider.of<PersonalityProvider>(context, listen: false);
      final mbtiProvider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
      
      final result = provider.result;
      final mbtiResult = mbtiProvider.result;
      
      // Determine which test result to use based on current route
      final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation;
      final isMBTIRoute = currentRoute.contains('mbti-results');
      
      // Check which result to use based on route
      dynamic currentResult;
      if (isMBTIRoute && mbtiResult != null) {
        currentResult = _convertMBTIToPersonalityResult(mbtiResult);
      } else if (!isMBTIRoute && result != null) {
        currentResult = result;
      } else {
        return; // No appropriate result available
      }

      // Create a screenshot widget specifically for saving
      final screenshotWidget = RepaintBoundary(
        child: _buildScreenshotContent(
          currentResult, 
          isMBTI: isMBTIRoute,
          mbtiResult: isMBTIRoute ? mbtiResult : null,
        ),
      );

      // Use a temporary screenshot controller for this specific widget
      final tempController = ScreenshotController();
      final image = await tempController.captureFromWidget(screenshotWidget);
      
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/personality_result_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screenshot saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving screenshot: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Helper method to convert MBTI result to regular PersonalityResult for ResultCard compatibility
  PersonalityResult _convertMBTIToPersonalityResult(MBTIPersonalityResult mbtiResult) {
    return PersonalityResult(
      personalityType: mbtiResult.mbtiType,
      confidence: mbtiResult.confidence,
      description: mbtiResult.description,
      traits: List<String>.from(mbtiResult.traits), // Ensure proper type conversion
      strengths: List<String>.from(mbtiResult.strengths),
      tips: List<String>.from(mbtiResult.tips),
      answers: mbtiResult.answers,
      timestamp: mbtiResult.timestamp,
    );
  }

  // Get cognitive stack for MBTI types
  // Build dimension breakdown widget
  Widget _buildDimensionBreakdown(String mbtiType) {
    final dimensions = [
      {
        'name': mbtiType[0] == 'E' ? 'Extraversion' : 'Introversion',
        'description': mbtiType[0] == 'E' ? 'Gains energy from external world' : 'Gains energy from inner world',
        'icon': mbtiType[0] == 'E' ? Icons.groups : Icons.person,
      },
      {
        'name': mbtiType[1] == 'S' ? 'Sensing' : 'Intuition',
        'description': mbtiType[1] == 'S' ? 'Focuses on concrete information' : 'Focuses on patterns and possibilities',
        'icon': mbtiType[1] == 'S' ? Icons.visibility : Icons.lightbulb,
      },
      {
        'name': mbtiType[2] == 'T' ? 'Thinking' : 'Feeling',
        'description': mbtiType[2] == 'T' ? 'Makes decisions with logic' : 'Makes decisions with values',
        'icon': mbtiType[2] == 'T' ? Icons.psychology : Icons.favorite,
      },
      {
        'name': mbtiType[3] == 'J' ? 'Judging' : 'Perceiving',
        'description': mbtiType[3] == 'J' ? 'Prefers structure and closure' : 'Prefers flexibility and openness',
        'icon': mbtiType[3] == 'J' ? Icons.schedule : Icons.explore,
      },
    ];

    return Column(
      children: dimensions.map((dimension) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                dimension['icon'] as IconData,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dimension['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dimension['description'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Consumer2<PersonalityProvider, MBTIPersonalityProvider>(
          builder: (context, provider, mbtiProvider, child) {
            final result = provider.result;
            final mbtiResult = mbtiProvider.result;
            
            // Determine which test result to show based on the current route
            final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation;
            final isMBTIRoute = currentRoute.contains('mbti-results');
            
            // Use the appropriate result based on the route
            final isMBTIResult = isMBTIRoute && mbtiResult != null;
            
            // Check if the appropriate provider has a result
            if ((isMBTIRoute && mbtiResult == null) || (!isMBTIRoute && result == null)) {
              return const SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Analyzing your personality...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This may take a moment',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use the result from the appropriate provider
            final displayResult = isMBTIResult 
                ? _convertMBTIToPersonalityResult(mbtiResult) 
                : result!;

            return Stack(
              children: [
                // Main scrollable content for display
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Header
                          Text(
                            'Your Results',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Results Content
                          Expanded(
                            child: AnimationLimiter(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: AnimationConfiguration.toStaggeredList(
                                    duration: const Duration(milliseconds: 600),
                                    childAnimationBuilder: (widget) => SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(child: widget),
                                    ),
                                    children: [
                                      // Main Result Card
                                      ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: ResultCard(result: displayResult),
                                      ),
                                      
                                      const SizedBox(height: 30),
                                      
                                      // Confidence Score
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.analytics,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Confidence Score',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: LinearProgressIndicator(
                                                    value: displayResult.confidence,
                                                    backgroundColor: Colors.white.withOpacity(0.2),
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Text(
                                                  '${(displayResult.confidence * 100).toInt()}%',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 30),
                                      
                                      // Description
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.description,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'About Your Personality',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              displayResult.description,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                color: Colors.white.withOpacity(0.9),
                                                height: 1.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 30),
                                      
                                      // MBTI-specific "What This Means" section
                                      if (isMBTIResult) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    color: Colors.blue.withOpacity(0.8),
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'What This Means',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: Colors.blue[100],
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                Provider.of<MBTIPersonalityProvider>(context, listen: false).getDetailedPersonalityExplanation(mbtiResult.mbtiType),
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.blue[50],
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                      
                                      // Traits
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.psychology,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Key Traits',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: displayResult.traits
                                                  .map((trait) => TraitChip(trait: trait))
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // MBTI-specific sections
                                      if (isMBTIResult) ...[
                                        const SizedBox(height: 30),
                                        
                                        // Enhanced Cognitive Functions Section
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.deepPurple.withOpacity(0.3),
                                                Colors.indigo.withOpacity(0.2),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.psychology,
                                                    color: Colors.white.withOpacity(0.9),
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'How Your Mind Works',
                                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              
                                              // Explanation text
                                              Text(
                                                'Your mind processes information through four cognitive functions in this specific order:',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white.withOpacity(0.9),
                                                  height: 1.5,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              
                                              // Cognitive Functions Stack
                                              _buildDetailedCognitiveFunctions(context, mbtiResult.mbtiType),
                                              
                                              const SizedBox(height: 20),
                                              
                                              // Learn more about cognitive functions
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.info_outline,
                                                          color: Colors.white.withOpacity(0.8),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Understanding Cognitive Functions',
                                                          style: TextStyle(
                                                            color: Colors.white.withOpacity(0.9),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'These functions work together like a mental toolkit, with your dominant function being the strongest and most developed, while your inferior function represents your greatest growth opportunity.',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.8),
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 30),
                                        
                                        // Type Dimensions Breakdown
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.tune,
                                                    color: Colors.white.withOpacity(0.8),
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Type Dimensions',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDimensionBreakdown(mbtiResult.mbtiType),
                                            ],
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 30),
                                        
                                        // Strengths & Growth Areas
                                        Row(
                                          children: [
                                            // Strengths
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.green.withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color: Colors.green.withOpacity(0.8),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Strengths',
                                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                            color: Colors.green[100],
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ...mbtiResult.strengths.take(4).map((strength) => Padding(
                                                      padding: const EdgeInsets.only(bottom: 6),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: 4,
                                                            height: 4,
                                                            margin: const EdgeInsets.only(top: 8, right: 8),
                                                            decoration: BoxDecoration(
                                                              color: Colors.green[200],
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              strength,
                                                              style: TextStyle(
                                                                color: Colors.green[100],
                                                                fontSize: 13,
                                                                height: 1.4,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(width: 16),
                                            
                                            // Growth Areas
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.orange.withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.trending_up_rounded,
                                                          color: Colors.orange.withOpacity(0.8),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Growth Areas',
                                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                            color: Colors.orange[100],
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ...mbtiResult.weaknesses.take(4).map((weakness) => Padding(
                                                      padding: const EdgeInsets.only(bottom: 6),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: 4,
                                                            height: 4,
                                                            margin: const EdgeInsets.only(top: 8, right: 8),
                                                            decoration: BoxDecoration(
                                                              color: Colors.orange[200],
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              weakness,
                                                              style: TextStyle(
                                                                color: Colors.orange[100],
                                                                fontSize: 13,
                                                                height: 1.4,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 30),
                                        
                                        // Career Suggestions
                                        if (mbtiResult.careerSuggestions.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.work_rounded,
                                                      color: Colors.white.withOpacity(0.8),
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Career Suggestions',
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Wrap(
                                                  spacing: 10,
                                                  runSpacing: 10,
                                                  children: mbtiResult.careerSuggestions.map((career) => 
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(
                                                          color: Colors.white.withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        career,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        
                                        const SizedBox(height: 30),
                                        
                                        // Tips for Growth
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.purple.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.trending_up,
                                                    color: Colors.purple.withOpacity(0.8),
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Tips for Growth',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: Colors.purple[100],
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              ...mbtiResult.tips.take(5).map((tip) => Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      margin: const EdgeInsets.only(top: 8, right: 12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.purple[200],
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        tip,
                                                        style: TextStyle(
                                                          color: Colors.purple[50],
                                                          fontSize: 14,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ],
                                      
                                      // External Links and Famous Examples Section (MBTI only)
                                      const SizedBox(height: 30),
                                      if (isMBTIResult) _buildExternalLinksSection(context, mbtiResult.mbtiType),
                                      
                                      const SizedBox(height: 80), // Extra space for floating buttons
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Floating Action Buttons positioned outside screenshot
                
                // Top Left - Retake Test Button
                Positioned(
                  top: 60,
                  left: 20,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _retakeTest,
                        borderRadius: BorderRadius.circular(28),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Top Right - Save Button
                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSharing ? null : _saveScreenshot,
                        borderRadius: BorderRadius.circular(28),
                        child: const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom Left - Home Button
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(28),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom Right - Share Button
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSharing ? null : _shareResult,
                        borderRadius: BorderRadius.circular(28),
                        child: _isSharing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.share_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build detailed cognitive functions widget
  Widget _buildDetailedCognitiveFunctions(BuildContext context, String mbtiType) {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    final functionDetails = provider.getCognitiveFunctionDetails(mbtiType);
    
    final functionTitles = ['Dominant', 'Auxiliary', 'Tertiary', 'Inferior'];
    final functionKeys = ['dominant', 'auxiliary', 'tertiary', 'inferior'];
    final functionColors = [
      Colors.green.withOpacity(0.8),
      Colors.blue.withOpacity(0.8), 
      Colors.orange.withOpacity(0.8),
      Colors.red.withOpacity(0.8),
    ];
    final functionIcons = [
      Icons.star,
      Icons.support,
      Icons.trending_up,
      Icons.warning_amber_rounded,
    ];

    return Column(
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: index < 3 ? 16 : 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: functionColors[index].withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: functionColors[index].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  functionIcons[index],
                  color: functionColors[index],
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${functionTitles[index]} Function',
                      style: TextStyle(
                        color: functionColors[index],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      functionDetails[functionKeys[index]] ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Build external links section
  Widget _buildExternalLinksSection(BuildContext context, String mbtiType) {
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    final famousExamples = provider.getFamousExamples(mbtiType);
    final personalityUrl = provider.getPersonalityTypeUrl(mbtiType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withOpacity(0.3),
            Colors.cyan.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Famous $mbtiType Personalities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Famous examples
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: famousExamples.map((person) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  person,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Learn more button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openExternalLink(personalityUrl),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: Text(
                'Learn More About $mbtiType',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Additional resources
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Resources',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildResourceLink('16Personalities.com', 'https://www.16personalities.com'),
                _buildResourceLink('Cognitive Functions Guide', 'https://www.personalityjunkie.com/functions-ni-ne-si-se/'),
                _buildResourceLink('MBTI Foundation', 'https://www.themyersbriggs.com/'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build resource link widget
  Widget _buildResourceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _openExternalLink(url),
        child: Row(
          children: [
            Icon(
              Icons.link,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open external link
  void _openExternalLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Try alternative launch mode if first fails
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          // If all fails, show a simple feedback instead of dialog
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open link: $url'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Show error feedback instead of dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $url'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

}
