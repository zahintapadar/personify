import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/material_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'About Personify',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo/Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.8),
                        Colors.blue.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Main heading
              Center(
                child: Text(
                  'About Personify',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // What is Personify section
              _buildSection(
                title: 'What is Personify?',
                content: 'Personify is an innovative personality recognition and mental wellness companion app that combines cutting-edge AI technology with evidence-based psychology. Our app provides comprehensive personality assessments, including MBTI and Big Five personality tests, alongside Sage - your personal AI wellness companion for 24/7 mental health support.',
              ),
              
              const SizedBox(height: 24),
              
              // Who is it for section
              _buildSection(
                title: 'Who is it for?',
                content: 'Personify is designed for students, working professionals, and individuals from all walks of life, with a special focus on serving rural and remote communities that may not have easy access to licensed psychologists or mental health professionals. Whether you\'re exploring your personality, seeking self-awareness, or need accessible mental wellness support, Personify is here for you.',
              ),
              
              const SizedBox(height: 24),
              
              // Goal section
              _buildSection(
                title: 'Our Goal',
                content: 'Our mission is to democratize mental health awareness and make accessible psychology tools available to everyone, regardless of their location or circumstances. We believe that understanding your personality and having access to mental wellness resources should not be a privilege, but a fundamental right. Through Personify, we aim to bridge the gap between professional psychological services and those who need them most.',
              ),
              
              const SizedBox(height: 32),
              
              // Features section
              _buildFeaturesSection(),
              
              const SizedBox(height: 32),
              
              // Contact section
              _buildContactSection(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.psychology,
            title: 'AI-Powered Personality Tests',
            description: 'Advanced MBTI and Big Five personality assessments with machine learning insights.',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.chat_bubble_outline,
            title: 'Sage AI Companion',
            description: '24/7 AI wellness companion for personalized mental health support and guidance.',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.insights,
            title: 'Detailed Analytics',
            description: 'Comprehensive personality insights with strengths, growth areas, and career suggestions.',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.history,
            title: 'Test History',
            description: 'Track your personality journey with detailed historical results and progress.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.3),
                Colors.blue.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.red.withOpacity(0.8),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Made with ❤️ for Mental Wellness',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Version 2.1.0',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'For support and feedback:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'zahintapadar@gmail.com',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
