import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/data/local/settings_db.dart';
import 'home_screen.dart';
import '../../controller/transaction_controller.dart';

class OnboardingScreen extends StatefulWidget {
  final TransactionController controller;
  const OnboardingScreen({super.key, required this.controller});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  final List<_OnboardPageData> _pages = [
    _OnboardPageData(
      icon: Icons.auto_graph,
      title: 'Minimal Tracker',
      body:
          'Track transactions with minimal friction. Clean UI, clear insights.',
    ),
    _OnboardPageData(
      icon: Icons.show_chart,
      title: 'Clean Analytics',
      body:
          'Weekly rhythms, spending trends and simple charts to keep you aware.',
    ),
    _OnboardPageData(
      icon: Icons.shield,
      title: 'Quiet Intelligence',
      body: 'AI-driven insights focused only on what matters to your finances.',
    ),
    _OnboardPageData(
      icon: Icons.rocket_launch,
      title: 'Get Started',
      body: 'Ready to take control? Secure, private and ultra-lightweight.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl.addListener(() {
      final p = (_pageCtrl.page ?? 0).round();
      if (p != _page) setState(() => _page = p);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    await SettingsDB.set<bool>('app.onboardingComplete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(controller: widget.controller),
      ),
    );
  }

  void _skip() => _completeOnboarding();

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final contentW = isWide ? 600.0 : double.infinity;

            return Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      // Top bar with Skip
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _skip,
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: contentW,
                            child: PageView.builder(
                              controller: _pageCtrl,
                              itemCount: _pages.length,
                              itemBuilder: (context, i) {
                                final p = _pages[i];
                                return Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        p.icon,
                                        size: isWide ? 120 : 96,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        p.title,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      GlassCard(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.lg,
                                        ),
                                        child: Text(
                                          p.body,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Indicator + buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.lg,
                        ),
                        child: SizedBox(
                          width: contentW,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Page indicator
                              Row(
                                children: List.generate(_pages.length, (i) {
                                  final active = i == _page;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(right: 8),
                                    width: active ? 22 : 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.primary
                                          : AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  );
                                }),
                              ),

                              // Next / Get Started
                              ElevatedButton(
                                onPressed: _next,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _page == _pages.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final IconData icon;
  final String title;
  final String body;

  _OnboardPageData({
    required this.icon,
    required this.title,
    required this.body,
  });
}
