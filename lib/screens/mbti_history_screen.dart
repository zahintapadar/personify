import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/mbti_personality_provider.dart';
import '../widgets/gradient_background.dart';
import '../models/mbti_personality_result.dart';

class MBTIHistoryScreen extends StatefulWidget {
  const MBTIHistoryScreen({super.key});

  @override
  State<MBTIHistoryScreen> createState() => _MBTIHistoryScreenState();
}

class _MBTIHistoryScreenState extends State<MBTIHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure provider is initialized when history screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
      if (!provider.isInitialized) {
        provider.initializeML();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'MBTI Test History',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Consumer<MBTIPersonalityProvider>(
                      builder: (context, provider, child) {
                        if (provider.testHistory.isEmpty) return const SizedBox.shrink();
                        
                        return IconButton(
                          onPressed: () => _showClearHistoryDialog(context, provider),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                          tooltip: 'Clear History',
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // History Content
              Expanded(
                child: Consumer<MBTIPersonalityProvider>(
                  builder: (context, provider, child) {
                    if (provider.testHistory.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    
                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: provider.testHistory.length,
                        itemBuilder: (context, index) {
                          final result = provider.testHistory[index];
                          
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildHistoryCard(context, result, index),
                              ),
                            ),
                          );
                        },
                      ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 50,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No MBTI Test History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Take your first MBTI personality test to see your results here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              child: const Text('Take MBTI Test Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, MBTIPersonalityResult result, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getTypeColor(result.mbtiType).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTypeColor(result.mbtiType).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  result.mbtiType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateFormat.format(result.timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Confidence Score
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence: ${result.confidencePercentage}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: result.confidence,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTypeColor(result.mbtiType).withOpacity(0.8),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          
          const SizedBox(height: 16),
          
          // Cognitive Stack
          Text(
            'Cognitive Functions: ${result.cognitiveStack}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _viewResultDetails(context, result),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String mbtiType) {
    // Color coding based on MBTI type
    switch (mbtiType[0]) {
      case 'E':
        return Colors.orange;
      case 'I':
      default:
        return Colors.blue;
    }
  }

  void _viewResultDetails(BuildContext context, MBTIPersonalityResult result) {
    // Set the result in the provider and navigate to results screen
    final provider = Provider.of<MBTIPersonalityProvider>(context, listen: false);
    provider.setHistoricalResult(result);
    context.go('/mbti-results');
  }

  void _showClearHistoryDialog(BuildContext context, MBTIPersonalityProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A1B3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Text(
            'Clear MBTI History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear all MBTI test history? This action cannot be undone.',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.clearTestHistory();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('MBTI test history cleared'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
