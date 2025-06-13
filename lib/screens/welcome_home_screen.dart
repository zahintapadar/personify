import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/plasma_renderer.dart';
import '../widgets/animated_button.dart';

class WelcomeHomeScreen extends StatefulWidget {
  const WelcomeHomeScreen({super.key});

  @override
  State<WelcomeHomeScreen> createState() => _WelcomeHomeScreenState();
}

class _WelcomeHomeScreenState extends State<WelcomeHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            tileMode: TileMode.mirror,
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [
              Color(0xfff44336),
              Color(0xff2196f3),
            ],
            stops: [0, 1],
          ),
        ),
        child: Stack(
          children: [
            // Plasma Background
            const PlasmaRenderer(
              type: PlasmaType.infinity,
              particles: 10,
              color: Color(0x442eaeaa),
              blur: 0.31,
              size: 1,
              speed: 1.86,
              offset: 0,
              blendMode: BlendMode.plus,
              particleType: ParticleType.atlas,
              variation1: 0,
              variation2: 0,
              variation3: 0,
              rotation: 0,
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: AnimationLimiter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 40),
                          _buildHeader(),
                          const SizedBox(height: 50),
                          _buildTestOptions(context),
                          const SizedBox(height: 40),
                          _buildHistorySection(context),
                          const SizedBox(height: 40),
                          _buildFeaturesSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo with floating animation
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            final value = _floatingController.value * 2 * math.pi;
            return Transform.translate(
              offset: Offset(0, 8 * math.sin(value)),
              child: Transform.scale(
                scale: 1.0 + 0.1 * math.cos(value * 1.5),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Animated Welcome Title with fixed height
        SizedBox(
          height: 80, // Fixed height to prevent layout shifts
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Welcome to Personify',
                textStyle: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 80),
              ),
              TypewriterAnimatedText(
                'Discover Your True Self',
                textStyle: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 80),
              ),
              TypewriterAnimatedText(
                'Unlock Your Potential',
                textStyle: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 80),
              ),
            ],
            isRepeatingAnimation: true,
            pause: const Duration(milliseconds: 2000),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
        ),
        const SizedBox(height: 16),
        
        // Animated Subtitle with fixed height
        SizedBox(
          height: 60, // Fixed height for subtitle
          child: AnimatedTextKit(
            animatedTexts: [
              FadeAnimatedText(
                'AI-powered personality assessments that reveal your unique traits',
                textStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
                duration: const Duration(milliseconds: 1500),
              ),
            ],
            isRepeatingAnimation: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTestOptions(BuildContext context) {
    return Column(
      children: [
        // MBTI Test Card
        _buildTestCard(
          context,
          title: 'MBTI Personality Test',
          subtitle: 'Comprehensive 16-type assessment',
          description: 'Discover your Myers-Briggs personality type through our advanced AI-powered assessment. Get detailed insights into your cognitive functions and personality traits.',
          icon: Icons.psychology_outlined,
          features: ['16 Personality Types', 'Cognitive Functions', 'Detailed Reports', 'AI-Powered'],
          onTap: () => context.go('/mbti-test'),
          gradient: [
            Colors.purple.shade400,
            Colors.deepPurple.shade600,
          ],
        ),
        const SizedBox(height: 20),
        
        // Quick Test Card
        _buildTestCard(
          context,
          title: 'Quick Personality Test',
          subtitle: 'Fast 5-minute assessment',
          description: 'Get quick insights into your personality traits with our streamlined assessment. Perfect for a fast overview of your characteristics.',
          icon: Icons.speed,
          features: ['5 Minutes', 'Quick Results', 'Basic Traits', 'Easy to Use'],
          onTap: () => context.go('/test'),
          gradient: [
            Colors.teal.shade400,
            Colors.cyan.shade600,
          ],
        ),
      ],
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<String> features,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Features
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((feature) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your Testing History',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'View your previous personality test results and track your journey of self-discovery.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  onPressed: () => context.go('/mbti-history'),
                  backgroundColor: Colors.purple.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology_outlined, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'MBTI',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: AnimatedButton(
                  onPressed: () => context.go('/history'),
                  backgroundColor: Colors.teal.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.speed, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Quick',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.psychology_outlined,
        'title': 'AI-Powered Analysis',
        'description': 'Advanced machine learning algorithms analyze your responses for accurate results.',
      },
      {
        'icon': Icons.insights,
        'title': 'Detailed Insights',
        'description': 'Get comprehensive reports with cognitive functions and personality breakdowns.',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Track Progress',
        'description': 'Monitor your personality development over time with detailed history.',
      },
      {
        'icon': Icons.share,
        'title': 'Share Results',
        'description': 'Share your personality insights with friends and family easily.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose Personify?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        ...features.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> feature = entry.value;
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feature['description'] as String,
                              style: GoogleFonts.poppins(
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
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}