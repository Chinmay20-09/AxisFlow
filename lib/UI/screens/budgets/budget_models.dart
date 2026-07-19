import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';

// ── Budget status ─────────────────────────────────────────────────────────────
enum BudgetStatus { caution, onTrack, critical, pending }

// ── Data model ────────────────────────────────────────────────────────────────
class BudgetItem {
  final IconData icon;
  final String title;
  final String spent;
  final String total;
  final String remaining;
  final double progress;
  final BudgetStatus status;
  final Color iconBg;
  final Color iconColor;
  final double allocationPercent;

  const BudgetItem({
    required this.icon,
    required this.title,
    required this.spent,
    required this.total,
    required this.remaining,
    required this.progress,
    required this.status,
    required this.iconBg,
    required this.iconColor,
    this.allocationPercent = 0,
  });
}

// ── Category Budget model for the planner ──────────────────────────────────────
class CategoryBudget {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  double percent;

  CategoryBudget({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.percent = 0,
  });
}

// ── Shared icon/color mapping for categories ───────────────────────────────────
class CategoryVisual {
  final IconData icon;
  final Color bg;
  final Color fg;

  const CategoryVisual(this.icon, this.bg, this.fg);
}

class IconAndColor {
  final IconData icon;
  final Color bgColor;
  final Color fgColor;

  const IconAndColor({
    required this.icon,
    required this.bgColor,
    required this.fgColor,
  });
}

const _categoryVisuals = <String, CategoryVisual>{
  'Food': CategoryVisual(Icons.restaurant, Color(0x3322C55E), Color(0xFF22C55E)),
  'Transport': CategoryVisual(Icons.directions_car, Color(0x333B82F6), Color(0xFF3B82F6)),
  'Bills': CategoryVisual(Icons.receipt_long, Color(0x33A855F7), Color(0xFFA855F7)),
  'Shopping': CategoryVisual(Icons.shopping_bag, Color(0x33F59E0B), Color(0xFFF59E0B)),
  'Health': CategoryVisual(Icons.medical_services, Color(0x33EF4444), Color(0xFFEF4444)),
  'Education': CategoryVisual(Icons.school, Color(0x336366F1), Color(0xFF6366F1)),
  'Entertainment': CategoryVisual(Icons.movie, Color(0x33EC4899), Color(0xFFEC4899)),
  'Travel': CategoryVisual(Icons.flight, Color(0x3314B8A6), Color(0xFF14B8A6)),
  'Subscription': CategoryVisual(Icons.subscriptions, Color(0x33F97316), Color(0xFFF97316)),
  'Rent': CategoryVisual(Icons.home, Color(0x338B5CF6), Color(0xFF8B5CF6)),
  'EMI': CategoryVisual(Icons.credit_card, Color(0x33E11D48), Color(0xFFE11D48)),
  'Family': CategoryVisual(Icons.family_restroom, Color(0x33D946BA), Color(0xFFD946BA)),
  'Personal': CategoryVisual(Icons.person, Color(0x330EA5E9), Color(0xFF0EA5E9)),
};

IconAndColor categoryIconInfo(String name) {
  final visual = _categoryVisuals[name];
  if (visual != null) {
    return IconAndColor(icon: visual.icon, bgColor: visual.bg, fgColor: visual.fg);
  }

  return IconAndColor(
    icon: Icons.category,
    bgColor: const Color(0x33FFFFFF),
    fgColor: AppColors.onSurface,
  );
}
