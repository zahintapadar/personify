import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.04, 0.0), // 52% 50%
            radius: 1.0,
            colors: [
              Color(0xFF000000), // rgba(0, 0, 0, 1)
              Color(0xFF581DA9), // rgba(88, 29, 169, 1)
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Personality Tests',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildEnhancedTestCard(
                    context: context,
                    title: 'MBTI Personality Test',
                    subtitle: '16 Personality Types',
                    description: 'Discover your Myers-Briggs personality type through comprehensive questions.',
                    icon: Icons.psychology,
                    gradient: [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
                    duration: '10 minutes',
                    questions: '15 questions',
                    onTap: () => context.push('/mbti-test'),
                  ),
                  const SizedBox(height: 20),
                  _buildEnhancedTestCard(
                    context: context,
                    title: 'Big Five Personality Test',
                    subtitle: 'OCEAN Model',
                    description: 'Explore the five major personality dimensions that define you.',
                    icon: Icons.star,
                    gradient: [const Color(0xFFEF4444), const Color(0xFFF97316)],
                    duration: '5 minutes',
                    questions: '25 questions',
                    onTap: () => context.push('/bigfive-test'),
                  ),
                  const SizedBox(height: 20),
                  _buildEnhancedTestCard(
                    context: context,
                    title: 'View Test History',
                    subtitle: 'Your Journey',
                    description: 'Review your past test results and track your personality insights.',
                    icon: Icons.history,
                    gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
                    duration: 'Instant access',
                    questions: 'All results',
                    onTap: () => context.push('/test-history'),
                  ),
                  const SizedBox(height: 20),
                  _buildEnhancedTestCard(
                    context: context,
                    title: 'Personality Insights',
                    subtitle: 'Coming Soon',
                    description: 'Get detailed analysis and recommendations based on your results.',
                    icon: Icons.insights,
                    gradient: [const Color(0xFFF59E0B), const Color(0xFFEAB308)],
                    duration: 'Soon',
                    questions: 'Advanced AI',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Coming soon! Stay tuned for advanced personality insights.'),
                          backgroundColor: const Color(0xFFF59E0B),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTestCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required String duration,
    required String questions,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
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
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: duration,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.quiz,
                      label: questions,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
