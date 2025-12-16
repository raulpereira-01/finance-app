// Elemento configurable que define qué widget del dashboard se muestra y en qué orden.
enum DashboardItemType { balance, expensesByCategory, incomeVsExpenses }

class DashboardItem {
  final String id;
  final DashboardItemType type;
  final bool enabled;
  final int order;

  DashboardItem({
    required this.id,
    required this.type,
    required this.enabled,
    required this.order,
  });

  DashboardItem copyWith({bool? enabled, int? order}) {
    return DashboardItem(
      id: id,
      type: type,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }
}
