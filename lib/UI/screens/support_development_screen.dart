import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_dims.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/core/theme/app_alpha.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/models/support_amount.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';

class SupportDevelopmentScreen extends StatefulWidget {
  const SupportDevelopmentScreen({super.key});

  @override
  State<SupportDevelopmentScreen> createState() =>
      _SupportDevelopmentScreenState();
}

class _SupportDevelopmentScreenState extends State<SupportDevelopmentScreen>
    with SingleTickerProviderStateMixin {
  String _selectedId = 'supporter'; // matches the HTML's pre-selected tier
  bool _transparencyOpen = false;
  late final AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _selectAmount(String id) {
    if (id == 'custom') {
      _showCustomAmountSheet();
      return;
    }
    setState(() => _selectedId = id);
  }

  Future<void> _showCustomAmountSheet() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDims.radiusCard),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppDims.md,
          right: AppDims.md,
          top: AppDims.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDims.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chooseAmountHeading,
                style: AppTextStyles.headlineLg),
            const SizedBox(height: AppDims.sm),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: AppTextStyles.headlineLg,
              decoration: InputDecoration(
                prefixText: currencySymbol,
                prefixStyle: AppTextStyles.headlineLg,
                hintText: '0',
                border: const UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDims.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _selectedId = 'custom');
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDims.radiusXl),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopBar(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppDims.sm),
          children: [
            const SizedBox(height: AppDims.sm),
            Text(
              supportIntro,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
            ),
            const SizedBox(height: AppDims.lg),
            _buildAppreciationCard(),
            const SizedBox(height: AppDims.lg),
            _buildWhySupportSection(),
            const SizedBox(height: AppDims.lg),
            _buildAmountSection(),
            const SizedBox(height: AppDims.sm),
            _buildSupportCta(),
            const SizedBox(height: AppDims.lg),
            _buildOtherWaysSection(context),
            const SizedBox(height: AppDims.lg),
            _buildTransparencyAccordion(),
            _buildFooterNote(),
            const SizedBox(height: AppDims.lg),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: AppAlpha.barBg),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        supportScreenTitle,
        style: AppTextStyles.headlineLgMobile,
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppDims.sm),
          child: const Icon(Icons.favorite_border,
              color: AppColors.onSurfaceVariant),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.white.withValues(alpha: AppAlpha.inputBorder),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildAppreciationCard() {
    return GlassCard(
      child: Column(
        children: [
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.2).animate(
              CurvedAnimation(
                  parent: _heartController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: AppAlpha.iconChipBg),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite,
                  color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: AppDims.sm),
          Text(supportThankYouTitle, style: AppTextStyles.headlineLg),
          const SizedBox(height: AppDims.xs),
          Text(
            supportThankYouBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildWhySupportSection() {
    final items = <_Reason>[
      _Reason(Icons.bolt, 'Faster Development',
          'Accelerate feature releases and roadmap completion.'),
      _Reason(Icons.verified_user, 'Better Reliability',
          'Enhanced server stability and proactive bug fixes.'),
      _Reason(Icons.psychology, 'Smarter AI',
          'Unlocking more advanced LLMs for better insights.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(whySupportHeading),
        const SizedBox(height: AppDims.sm),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDims.xs),
            child: GlassCard(
              padding: const EdgeInsets.all(AppDims.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: AppColors.primary),
                  const SizedBox(height: AppDims.xs),
                  Text(item.title,
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    item.description,
                    style: AppTextStyles.labelSm.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(chooseAmountHeading),
        const SizedBox(height: AppDims.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDims.sm,
          crossAxisSpacing: AppDims.sm,
          childAspectRatio: 1.5,
          children: [
            for (final option in SupportAmount.defaults)
              _AmountTile(
                option: option,
                selected: _selectedId == option.id,
                onTap: () => _selectAmount(option.id),
              ),
          ],
        ),
        const SizedBox(height: AppDims.sm),
        _CustomAmountTile(
          selected: _selectedId == 'custom',
          onTap: () => _selectAmount('custom'),
        ),
      ],
    );
  }

  Widget _buildSupportCta() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.payments),
        label: Text(
          supportCtaLabel,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor:
              AppColors.primary.withValues(alpha: AppAlpha.glowLight),
          padding: const EdgeInsets.symmetric(vertical: AppDims.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDims.radiusCard),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherWaysSection(BuildContext context) {
    final rows = <_OtherWay>[
      _OtherWay(Icons.star, 'Rate the App'),
      _OtherWay(Icons.bug_report, 'Report Bugs'),
      _OtherWay(Icons.lightbulb, 'Suggest Features'),
      _OtherWay(Icons.share, 'Share with Friends'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(otherWaysHeading),
        const SizedBox(height: AppDims.sm),
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: AppDims.xs),
            child: GlassCard(
              padding: const EdgeInsets.all(AppDims.md),
              onTap: () {},
              child: Row(
                children: [
                  Icon(row.icon, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: AppDims.sm),
                  Expanded(child: Text(row.label, style: AppTextStyles.bodyMd)),
                  const Icon(Icons.chevron_right,
                      color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransparencyAccordion() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _transparencyOpen = !_transparencyOpen),
            child: Padding(
              padding: const EdgeInsets.all(AppDims.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      transparencyQuestion,
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _transparencyOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.expand_more,
                        color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _transparencyOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDims.md, 0, AppDims.md, AppDims.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppColors.white
                        .withValues(alpha: AppAlpha.divider),
                    height: AppDims.md,
                  ),
                  Text(
                    transparencyIntro,
                    style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: AppDims.sm),
                  _breakdownRow('Server & Cloud Hosting', '40%'),
                  _breakdownRow('AI API & Model Training', '35%'),
                  _breakdownRow('Maintenance & Security', '25%'),
                  const SizedBox(height: AppDims.xs),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDims.radiusFull),
                    child: SizedBox(
                      height: 4,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 40,
                              child: Container(color: AppColors.primary)),
                          Expanded(
                              flex: 35,
                              child: Container(color: AppColors.secondary)),
                          Expanded(
                              flex: 25,
                              child:
                                  Container(color: AppColors.tertiary)),
                        ],
                      ),
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

  Widget _breakdownRow(String label, String pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDims.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
          Text(pct,
              style: AppTextStyles.labelSm
                  .copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDims.md),
      child: Center(
        child: Text(
          supportFooterNote,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSurfaceVariant
                .withValues(alpha: AppAlpha.dimmedText),
          ),
        ),
      ),
    );
  }
}

/// Helper data class for the "Why Support" section.
class _Reason {
  final IconData icon;
  final String title;
  final String description;
  const _Reason(this.icon, this.title, this.description);
}

/// Helper data class for the "Other Ways" section.
class _OtherWay {
  final IconData icon;
  final String label;
  const _OtherWay(this.icon, this.label);
}
class _SectionHeading extends StatelessWidget {
  final String label;
  const _SectionHeading(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.labelMd.copyWith(
        color: AppColors.primary,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  final SupportAmount option;
  final bool selected;
  final VoidCallback onTap;

  const _AmountTile(
      {required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderWidth: selected ? 2 : 1,
      activeBorderColor: selected ? AppColors.primary : null,
      backgroundColor: selected
          ? AppColors.primary.withValues(alpha: AppAlpha.selectedTintBg)
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(option.label,
              style: AppTextStyles.labelMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppDims.base),
          Text('$currencySymbol${option.amount}',
              style: AppTextStyles.headlineLg),
        ],
      ),
    );
  }
}

class _CustomAmountTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CustomAmountTile({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderWidth: selected ? 2 : 1,
      activeBorderColor: selected ? AppColors.primary : null,
      backgroundColor: selected
          ? AppColors.primary.withValues(alpha: AppAlpha.selectedTintBg)
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('CUSTOM AMOUNT',
              style: AppTextStyles.labelMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
           Icon(Icons.edit, color: AppColors.primary),
        ],
      ),
    );
  }
}
