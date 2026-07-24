import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_dims.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/ui/models/transaction_saved_data.dart';
import 'package:axisflow/ui/models/transaction_result.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/ui/widgets/cards/category_selector.dart';

/// A polished bottom-sheet-style popup for confirming an auto-imported
/// transaction from SMS.
///
/// Uses the shared [CategorySelector] widget so the category experience
/// is identical to [AddTransactionSheet].
class PopupAddTransaction extends StatefulWidget {
  final double amount;
  final String merchant;
  final String account;
  final String suggestedCategory;
  final String transactionId;
  final String bank;
  final DateTime date;
  final bool needsAttention;
  final TransactionType transactionType;

  /// Called with the result when the user presses Done.
  /// If null, the popup just closes.
  final ValueChanged<TransactionResultData>? onDone;
  final VoidCallback? onLater;
  final VoidCallback? onDismissed;

  const PopupAddTransaction({
    super.key,
    this.amount = 1250.00,
    this.merchant = 'Starbucks Coffee',
    this.account = 'HDFC Bank • 4291',
    this.suggestedCategory = 'Food',
    this.transactionId = '',
    this.bank = '',
    required this.date,
    this.needsAttention = false,
    this.transactionType = TransactionType.expense,
    this.onDone,
    this.onLater,
    this.onDismissed,
  });

  /// Construct from a raw [Transaction] (e.g. from the Alerts screen).
  ///
  /// Parses merchant, bank, and sender from the structured note field.
  factory PopupAddTransaction.fromTransaction(
    Transaction tx, {
    VoidCallback? onDismissed,
    ValueChanged<TransactionResultData>? onDone,
  }) {
    String extractField(String prefix) {
      for (final line in tx.note.split('\n')) {
        if (line.startsWith('$prefix: ')) {
          return line.substring('$prefix: '.length).trim();
        }
      }
      return '';
    }
    final merchant = extractField('Merchant');
    final bank = extractField('Bank');

    return PopupAddTransaction(
      transactionId: tx.id,
      amount: tx.amount,
      merchant: merchant.isNotEmpty ? merchant : 'Unknown',
      account: bank.isNotEmpty ? bank : 'Manual Entry',
      bank: bank,
      date: tx.createdAt,
      suggestedCategory: tx.category,
      needsAttention: tx.state == TransactionState.pending,
      transactionType: tx.type,
      onDone: onDone,
      onDismissed: onDismissed,
    );
  }

  /// Construct from [TransactionSavedData].
  factory PopupAddTransaction.fromSavedData(
    TransactionSavedData data, {
    VoidCallback? onDismissed,
    ValueChanged<TransactionResultData>? onDone,
  }) {
    return PopupAddTransaction(
      transactionId: data.transactionId,
      amount: data.amount,
      merchant: data.merchant,
      account: data.account,
      bank: data.bank,
      date: data.date,
      suggestedCategory: data.suggestedCategory,
      needsAttention: data.needsAttention,
      transactionType: data.transactionType,
      onDone: onDone,
      onDismissed: onDismissed,
    );
  }

  /// Convenience method to show this sheet as a modal bottom sheet.
  ///
  /// Returns the [TransactionResultData] when Done is pressed,
  /// or null if the sheet is dismissed without confirming.
  static Future<TransactionResultData?> show(
    BuildContext context, {
    PopupAddTransaction? sheet,
  }) {
    return showModalBottomSheet<TransactionResultData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      elevation: 0,
      builder: (_) =>
          sheet ?? PopupAddTransaction(date: DateTime.now()),
    ).then((result) {
      sheet?.onDismissed?.call();
      return result;
    });
  }

  @override
  State<PopupAddTransaction> createState() => _PopupAddTransactionState();
}

class _PopupAddTransactionState extends State<PopupAddTransaction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  final _noteController = TextEditingController();

  /// The currently selected category (defaults to suggested).
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.suggestedCategory;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Cubic(0.16, 1, 0.3, 1),
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ─── helpers ─────────────────────────────────────────────────────────

  Color get _typeColor => widget.transactionType == TransactionType.income
      ? AppColors.tertiary
      : AppColors.accentRed;

  IconData get _typeIcon => widget.transactionType == TransactionType.income
      ? Icons.arrow_downward
      : Icons.arrow_outward;

  String get _typeLabel => widget.transactionType == TransactionType.income
      ? 'Income'
      : 'Expense';

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(dt.year, dt.month, dt.day);

    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (dateDay == today) return 'Today, $timeStr';
    final yesterday = today.subtract(const Duration(days: 1));
    if (dateDay == yesterday) return 'Yesterday, $timeStr';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, $timeStr';
  }

  void _onDonePressed() {
    final result = TransactionResultData(
      transactionId: widget.transactionId,
      selectedCategory: _selectedCategory,
      note: _noteController.text.trim(),
    );
    widget.onDone?.call(result);
    Navigator.of(context).pop(result);
  }

  // ─── build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGrabHandle(),
              Flexible(child: _buildContent(bottomInset)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double bottomInset) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppDims.md, 4, AppDims.md, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppDims.md),
          _buildSummaryHero(),
          SizedBox(height: AppDims.md),
          _buildFieldsSection(),
          SizedBox(height: AppDims.sm),
          _buildActions(),
          SizedBox(height: 16 + bottomInset),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Transaction', style: AppTextStyles.headlineLg),
        const SizedBox(height: 4),
        Text(
          "We've already imported this transaction. Just confirm a few details.",
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHero() {
    return GlassCard(
      padding: EdgeInsets.all(AppDims.md),
      backgroundColor: AppColors.surfaceContainerLow,
      showBorder: true,
      activeBorderColor: AppColors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(AppDims.radiusXl),
      child: Column(
        children: [
          // Top row: type badge + amount + status chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge (Income / Expense)
                    Row(
                      children: [
                        Icon(_typeIcon, size: 18, color: _typeColor),
                        SizedBox(width: 4),
                        Text(
                          _typeLabel,
                          style: AppTextStyles.labelSm.copyWith(
                            color: _typeColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDims.base),
                    // Amount — use type-appropriate color
                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: AppDims.base),
                    // Merchant
                    Text(
                      widget.merchant,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Imported status chip
              _StatusChip(label: 'Imported from SMS', icon: Icons.check_circle),
            ],
          ),
          SizedBox(height: AppDims.md),
          _buildCustomDivider(),
          SizedBox(height: AppDims.md),
          // Date & Account row
          Row(
            children: [
              Expanded(
                child: _buildInfoBlock(
                    'Date & Time', _formatDate(widget.date)),
              ),
              SizedBox(width: AppDims.sm),
              Expanded(
                child: _buildInfoBlock('Account', widget.account),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.white.withValues(alpha: 0.05),
            AppColors.white.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: [0, 0.15, 0.85, 1],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
        ),
      ],
    );
  }

  // ─── Fields section ──────────────────────────────────────────────────

  Widget _buildFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shared category selector with favorites, icons, and picker
        CategorySelector(
          transactionType: widget.transactionType,
          selectedCategory: _selectedCategory,
          suggestedCategory: widget.suggestedCategory,
          onChanged: (name) {
            setState(() => _selectedCategory = name);
          },
        ),
        SizedBox(height: AppDims.sm),
        // Note field
        Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'NOTE (OPTIONAL)',
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildNoteField(),
      ],
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDims.radiusXl),
      ),
      child: TextField(
        controller: _noteController,
        style: const TextStyle(color: AppColors.onSurface, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'e.g. Morning latte at MG Road',
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.fromLTRB(AppDims.md, AppDims.lg, AppDims.md, AppDims.md),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: TextButton(
              onPressed: widget.onLater ?? () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDims.radiusXl),
                ),
              ),
              child: const Text('Later',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        SizedBox(width: AppDims.sm),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _onDonePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDims.radiusXl),
                ),
              ),
              child: const Text('Done',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small status chip with icon and label.
class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDims.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
