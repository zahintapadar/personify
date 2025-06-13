import 'package:flutter/material.dart';

class AnimatedQuestionCard extends StatefulWidget {
  final String questionTitle;
  final String questionText;
  final List<String> options;
  final int? selectedOptionIndex;
  final Function(int) onOptionSelected;
  final int questionIndex;

  const AnimatedQuestionCard({
    super.key,
    required this.questionTitle,
    required this.questionText,
    required this.options,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
    required this.questionIndex,
  });

  @override
  State<AnimatedQuestionCard> createState() => _AnimatedQuestionCardState();
}

class _AnimatedQuestionCardState extends State<AnimatedQuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Reduced from 600ms
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Reduced from 0.3
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimation() {
    // Start animation immediately without delay for faster loading
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionIndex != widget.questionIndex) {
      // Quick animation for question changes
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildQuestionCard(),
            const SizedBox(height: 24),
            ..._buildOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Text(
              'Question ${widget.questionIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question title
          Text(
            widget.questionTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Question text
          Text(
            widget.questionText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions() {
    return widget.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = widget.selectedOptionIndex == index;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)), // Much faster: reduced from 300 + (index * 100)
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - value)), // Reduced from 20
              child: Opacity(
                opacity: value,
                child: _buildOptionTile(index, option, isSelected),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildOptionTile(int index, String option, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Reduced from 300ms
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200), // Reduced from 300ms
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  width: 2.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Option text
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200), // Reduced from 300ms
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.4,
                ),
                child: Text(option),
              ),
            ),
            
            // Selected badge
            if (isSelected)
              AnimatedScale(
                duration: const Duration(milliseconds: 200), // Reduced from 300ms
                scale: isSelected ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  child: const Text(
                    'Selected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}