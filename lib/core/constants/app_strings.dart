class AppStrings {
  static const appTitle = 'AxisFlow';

  static const goodMorning = 'Good Morning';

  static const trackMessage = 'Everything is on track';

  static const todayFlowLabel = 'TODAY FLOW';
  static const alertsScreenTitle = 'Alerts';

  static const prioritySectionLabel = 'Priority';

  static const historySectionLabel = 'History';

  static const todayFlowAmount = '\$42.50';

  static const aiInsightBadge = 'AI INSIGHT';

  static const aiInsightMessage =
      "You're spending 10% less than usual this Tuesday.";

  static const weeklyRhythmTitle = 'Weekly Rhythm';

  static const weeklyAverage = 'Avg: \$58/day';

  static const recentActivityTitle = 'Recent Activity';

  static const viewAll = 'View All';

  static const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const chartHeights = [40.0, 60.0, 85.0, 50.0, 70.0, 95.0, 30.0];

  // Category lists moved to lib/core/constants/categories.dart as CategoryItem
  // Use getCategoryDisplay(name) and getCategoryIcon(name) for UI display.

  static const appActivityTitle = 'AxisFlow | Activity';
  static const appBarBrand = 'AxisFlow';
  static const searchHint = 'Search transactions.';
  static const aiInsightLabel = 'AI GENERATED INSIGHTS';
  static const aiInsightBody =
      'Your spending on coffee is down 12% this week. That\'s \$18 saved for your "New Tech" goal.';
  static const aiInsightCta = 'See detailed analysis';

  static const navWealth = 'Wealth';
  static const navFlow = 'Flow';
  static const navInsights = 'Insights';
  static const navProfile = 'Profile';

  static const chips = [
    'All',
    'Income',
    'Expenses',
    'Today',
    'Yesterday',
    'This Week',
  ];

  static const groupToday = 'Today';
  static const groupYesterday = 'Yesterday';
}

class CategoryHelper {
  static String cleanCategory(String category) {
    return category.split(' ').first;
  }
}

String formatDate(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

String formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
