import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/bigfive_personality_provider.dart';
import '../widgets/simple_button.dart';
import '../widgets/material_background.dart';

class BigFiveResultScreen extends StatelessWidget {
  const BigFiveResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: MaterialBackground(
        child: SafeArea(
          child: Consumer<BigFivePersonalityProvider>(
            builder: (context, provider, child) {
              final result = provider.result;
              
              if (result == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results available',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please take the test first',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SimpleButton(
                        text: 'Take Test',
                        onPressed: () => context.push('/bigfive-test'),
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Your Big Five Results',
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Personality Type Card
                    _buildPersonalityTypeCard(context, result),
                    
                    const SizedBox(height: 24),
                    
                    // Trait Scores
                    _buildTraitScoresSection(context, result),
                    
                    const SizedBox(height: 24),
                    
                    // What This Means
                    _buildMeaningSection(context, result),
                    
                    const SizedBox(height: 24),
                    
                    // Strengths
                    _buildStrengthsSection(context, result),
                    
                    const SizedBox(height: 24),
                    
                    // Growth Areas
                    _buildGrowthAreasSection(context, result),
                    
                    const SizedBox(height: 24),
                    
                    // Career Suggestions
                    _buildCareerSuggestionsSection(context, result),
                    
                    const SizedBox(height: 24),
                    
                    // Learn More
                    _buildLearnMoreSection(context),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    _buildActionButtons(context),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalityTypeCard(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology,
            color: colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            result.personalityType,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${result.confidence.toStringAsFixed(1)}%',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cluster: ${result.dominantCluster}',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitScoresSection(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Trait Scores',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...['O', 'C', 'E', 'A', 'N'].map((trait) {
          return _buildTraitBar(context, trait, result);
        }),
      ],
    );
  }

  Widget _buildTraitBar(BuildContext context, String trait, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentile = result.getTraitPercentile(trait);
    final level = result.getTraitLevel(trait);
    final traitName = _getFullTraitName(trait);
    final traitColor = _getTraitColor(trait);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                traitName,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '$level (${percentile.round()}%)',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: traitColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: percentile / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: traitColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.getTraitDescription(trait),
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningSection(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'What This Means',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your personality profile shows how you typically think, feel, and behave across five major dimensions. This combination of traits creates your unique personality fingerprint.',
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsSection(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    final strengths = result.getStrengths();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Your Strengths',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...strengths.map((strength) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strength,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGrowthAreasSection(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    final growthAreas = result.getGrowthAreas();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Growth Opportunities',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...growthAreas.map((area) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    area,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCareerSuggestionsSection(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Get career suggestions from ML service
    final careers = [
      'Creative Director',
      'Research Scientist', 
      'Project Manager',
      'Counselor/Therapist',
      'Marketing Manager',
      'Data Analyst'
    ]; // Default careers - would be from ML service in production
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.work,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Career Matches',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: careers.map((career) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                career,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLearnMoreSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Learn More',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Want to dive deeper into personality psychology?',
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchURL('https://en.wikipedia.org/wiki/Big_Five_personality_traits'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.open_in_new,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Big Five Personality Traits - Wikipedia',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        SimpleButton(
          text: 'Take Test Again',
          onPressed: () => context.push('/bigfive-test'),
          backgroundColor: colorScheme.primary,
          textColor: colorScheme.onPrimary,
        ),
        const SizedBox(height: 12),
        SimpleButton(
          text: 'View Test History',
          onPressed: () => context.go('/test-history'),
          backgroundColor: colorScheme.surfaceContainerHighest,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 12),
        SimpleButton(
          text: 'Back to Home',
          onPressed: () => context.go('/'),
          backgroundColor: colorScheme.surfaceContainerHighest,
          textColor: colorScheme.onSurface,
        ),
      ],
    );
  }

  String _getFullTraitName(String trait) {
    switch (trait) {
      case 'O': return 'Openness to Experience';
      case 'C': return 'Conscientiousness';
      case 'E': return 'Extraversion';
      case 'A': return 'Agreeableness';
      case 'N': return 'Neuroticism';
      default: return 'Unknown';
    }
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
