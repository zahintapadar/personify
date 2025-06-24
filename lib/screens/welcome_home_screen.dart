import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/animated_button.dart';
import '../widgets/gradient_background.dart';
import '../services/app_preferences.dart';
import '../services/supabase_service.dart';

class WelcomeHomeScreen extends StatefulWidget {
  const WelcomeHomeScreen({super.key});

  @override
  State<WelcomeHomeScreen> createState() => _WelcomeHomeScreenState();
}

class _WelcomeHomeScreenState extends State<WelcomeHomeScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: AnimationLimiter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAnimationSettings(context),
        backgroundColor: Colors.white.withOpacity(0.9),
        child: const Icon(Icons.settings, color: Color(0xFF421DA9)),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
          description:
              'Discover your Myers-Briggs personality type through our advanced AI-powered assessment. Get detailed insights into your cognitive functions and personality traits.',
          icon: Icons.psychology_outlined,
          features: [
            '16 Personality Types',
            'Cognitive Functions',
            'Detailed Reports',
            'AI-Powered',
          ],
          onTap: () => context.go('/mbti-test'),
          gradient: [Colors.purple.shade400, Colors.deepPurple.shade600],
        ),
        const SizedBox(height: 20),

        // Quick Test Card
        _buildTestCard(
          context,
          title: 'Quick Personality Test',
          subtitle: 'Fast 5-minute assessment',
          description:
              'Get quick insights into your personality traits with our streamlined assessment. Perfect for a fast overview of your characteristics.',
          icon: Icons.speed,
          features: [
            '5 Minutes',
            'Quick Results',
            'Basic Traits',
            'Easy to Use',
          ],
          onTap: () => context.go('/test'),
          gradient: [Colors.teal.shade400, Colors.cyan.shade600],
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
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                      child: Icon(icon, color: Colors.white, size: 32),
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
                  children: features
                      .map(
                        (feature) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
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
                        ),
                      )
                      .toList(),
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
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
              const Icon(Icons.history, color: Colors.white, size: 28),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.psychology_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
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
        'description':
            'Advanced machine learning algorithms analyze your responses for accurate results.',
      },
      {
        'icon': Icons.insights,
        'title': 'Detailed Insights',
        'description':
            'Get comprehensive reports with cognitive functions and personality breakdowns.',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Track Progress',
        'description':
            'Monitor your personality development over time with detailed history.',
      },
      {
        'icon': Icons.share,
        'title': 'Share Results',
        'description':
            'Share your personality insights with friends and family easily.',
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
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
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

  void _showAnimationSettings(BuildContext context) {
    showDialog(context: context, builder: (context) => const _SettingsDialog());
  }
}

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  bool _animationEnabled = true;
  bool _simpleMode = false;
  bool _notificationsEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final animationEnabled =
          await AppPreferences.getBackgroundAnimationEnabled();
      final simpleMode = await AppPreferences.getSimpleAnimationMode();
      final notificationsEnabled =
          await AppPreferences.getNotificationsEnabled();
      final musicEnabled = await AppPreferences.getMusicEnabled();
      final musicVolume = await AppPreferences.getMusicVolume();

      if (mounted) {
        setState(() {
          _animationEnabled = animationEnabled;
          _simpleMode = simpleMode;
          _notificationsEnabled = notificationsEnabled;
          _musicEnabled = musicEnabled;
          _musicVolume = musicVolume;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _animationEnabled = true;
          _simpleMode = false;
          _notificationsEnabled = true;
          _musicEnabled = true;
          _musicVolume = 0.3;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: GestureDetector(
        onLongPress: () async {
          // Hidden debug feature - comprehensive Supabase testing
          debugPrint('Testing Supabase connection and table access...');

          // Find correct table name
          final correctTableName = await SupabaseService.findCorrectTableName();
          debugPrint('Found table: $correctTableName');

          // Test basic connection
          final connected = await SupabaseService.testConnection();
          debugPrint('Basic connection test: $connected');

          // Verify table structure
          final tableInfo = await SupabaseService.verifyTable();
          debugPrint('Table verification: $tableInfo');

          // List available tables
          await SupabaseService.listTables();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  correctTableName != null
                      ? '✅ Found table: $correctTableName. Check console for details.'
                      : '❌ No accessible table found. Check console for details.',
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: const Text(
          'App Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF421DA9),
          ),
        ),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Customize app settings for better experience',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('Background Animation'),
                      subtitle: const Text(
                        'Enable fluid background animations',
                      ),
                      value: _animationEnabled,
                      onChanged: (value) async {
                        await AppPreferences.setBackgroundAnimationEnabled(
                          value,
                        );
                        setState(() {
                          _animationEnabled = value;
                        });
                      },
                    ),
                    if (_animationEnabled)
                      SwitchListTile(
                        title: const Text('Performance Mode'),
                        subtitle: const Text(
                          'Use simplified animations for better performance',
                        ),
                        value: _simpleMode,
                        onChanged: (value) async {
                          await AppPreferences.setSimpleAnimationMode(value);
                          setState(() {
                            _simpleMode = value;
                          });
                        },
                      ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text(
                        'Get reminders to take personality tests',
                      ),
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        await AppPreferences.setNotificationsEnabled(value);
                        setState(() {
                          _notificationsEnabled = value;
                        });

                        // Show confirmation
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Notifications enabled! You\'ll get reminders to take tests.'
                                    : 'Notifications disabled.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Background Music'),
                      subtitle: const Text('Play ambient background music'),
                      value: _musicEnabled,
                      onChanged: (value) async {
                        await AppPreferences.setMusicEnabled(value);
                        setState(() {
                          _musicEnabled = value;
                        });

                        // Show confirmation
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Background music enabled'
                                    : 'Background music disabled',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    if (_musicEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_down),
                            Expanded(
                              child: Slider(
                                value: _musicVolume,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: '${(_musicVolume * 100).round()}%',
                                onChanged: (value) {
                                  setState(() {
                                    _musicVolume = value;
                                  });
                                },
                                onChangeEnd: (value) async {
                                  await AppPreferences.setMusicVolume(value);
                                },
                              ),
                            ),
                            const Icon(Icons.volume_up),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Done',
            style: TextStyle(
              color: Color(0xFF421DA9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
