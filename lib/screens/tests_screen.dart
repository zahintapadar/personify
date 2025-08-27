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
                  _buildColorfulTestCard(
                    context: context,
                    title: 'MBTI Personality Test',
                    description: 'Discover your Myers-Briggs personality type through comprehensive questions.',
                    icon: Icons.psychology,
                    gradient: [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
                    onTap: () => context.push('/mbti-test'),
                  ),
                  const SizedBox(height: 16),
                  _buildColorfulTestCard(
                    context: context,
                    title: 'Big Five Personality Test',
                    description: 'Explore the five major personality dimensions that define you.',
                    icon: Icons.star,
                    gradient: [const Color(0xFFEF4444), const Color(0xFFF97316)],
                    onTap: () => context.push('/personality-test'),
                  ),
                  const SizedBox(height: 16),
                  _buildColorfulTestCard(
                    context: context,
                    title: 'View Test History',
                    description: 'Review your past test results and track your personality insights.',
                    icon: Icons.history,
                    gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
                    onTap: () => context.push('/test-history'),
                  ),
                  const SizedBox(height: 16),
                  _buildColorfulTestCard(
                    context: context,
                    title: 'Personality Insights',
                    description: 'Get detailed analysis and recommendations based on your results.',
                    icon: Icons.insights,
                    gradient: [const Color(0xFFF59E0B), const Color(0xFFEAB308)],
                    onTap: () {
                      // Coming soon functionality
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorfulTestCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
