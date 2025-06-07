import 'package:flutter/material.dart';
import '../models/personality_result.dart';

class ResultCard extends StatelessWidget {
  final PersonalityResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isExtrovert = result.personalityType == 'Extrovert';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExtrovert
              ? [
                  const Color(0xFFFF5934),
                  const Color(0xFFFF7044),
                ]
              : [
                  const Color(0xFF421DA9),
                  const Color(0xFF5B2BC4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isExtrovert ? const Color(0xFFFF5934) : const Color(0xFF421DA9))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Personality Type Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExtrovert ? Icons.groups : Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Result Text
          Text(
            'You are an',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Personality Type
          Text(
            result.personalityType.toUpperCase(),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 36,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Decorative divider
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
