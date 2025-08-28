import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bigfive_personality_provider.dart';
import '../widgets/material_background.dart';
import '../widgets/simple_button.dart';

class BigFiveHistoryScreen extends StatelessWidget {
  const BigFiveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: MaterialBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Big Five Test History',
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
              ),
              
              // Content
              Expanded(
                child: Consumer<BigFivePersonalityProvider>(
                  builder: (context, provider, child) {
                    if (provider.testHistory.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    
                    return Column(
                      children: [
                        // Stats summary
                        _buildStatsCard(context, provider),
                        
                        const SizedBox(height: 16),
                        
                        // History list
                        Expanded(
                          child: _buildHistoryList(context, provider),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: colorScheme.onSurface.withOpacity(0.3),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'No Test History Yet',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Take your first Big Five personality test to see your results here.',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SimpleButton(
              text: 'Take Big Five Test',
              onPressed: () => context.push('/bigfive-test'),
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, BigFivePersonalityProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final testCount = provider.testHistory.length;
    final mostRecentResult = provider.testHistory.first;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Personality Type',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mostRecentResult.personalityType,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${mostRecentResult.confidence.toStringAsFixed(1)}%',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Tests Taken',
                  testCount.toString(),
                  Icons.quiz,
                ),
                _buildStatItem(
                  context,
                  'Cluster',
                  mostRecentResult.dominantCluster.split(' ').first,
                  Icons.category,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context, BigFivePersonalityProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Test History',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => _showClearHistoryDialog(context, provider),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: provider.testHistory.length,
              itemBuilder: (context, index) {
                final result = provider.testHistory[index];
                final isLatest = index == 0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLatest 
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: isLatest 
                          ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                result.personalityType,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isLatest 
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isLatest)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Latest',
                                  style: GoogleFonts.roboto(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: colorScheme.onSurface.withOpacity(0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(result.timestamp),
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.assessment,
                              color: colorScheme.onSurface.withOpacity(0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${result.confidence.toStringAsFixed(1)}% confidence',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cluster: ${result.dominantCluster}',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Trait scores mini bars
                        Row(
                          children: ['O', 'C', 'E', 'A', 'N'].map((trait) {
                            final percentile = result.getTraitPercentile(trait);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: Column(
                                  children: [
                                    Text(
                                      trait,
                                      style: GoogleFonts.roboto(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getTraitColor(trait),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        widthFactor: percentile / 100,
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getTraitColor(trait),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
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

  void _showClearHistoryDialog(BuildContext context, BigFivePersonalityProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear Test History',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all your Big Five test history? This action cannot be undone.',
            style: GoogleFonts.roboto(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await provider.clearTestHistory();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Test history cleared successfully',
                        style: GoogleFonts.roboto(),
                      ),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.roboto(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
