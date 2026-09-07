import 'package:flutter/material.dart';

/// Exposes reports header filter state to the list area below the shell.
class ReportsHeaderScope extends InheritedWidget {
  const ReportsHeaderScope({
    required this.selectedLeagueId,
    required this.selectedDate,
    required this.onClearLeagueSelection,
    required super.child,
    super.key,
  });

  final String? selectedLeagueId;
  final DateTime selectedDate;
  final VoidCallback onClearLeagueSelection;

  static ReportsHeaderScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ReportsHeaderScope>();
    assert(scope != null, 'ReportsHeaderScope not found in widget tree');
    return scope!;
  }

  void clearLeagueSelection() => onClearLeagueSelection();

  @override
  bool updateShouldNotify(ReportsHeaderScope oldWidget) =>
      selectedLeagueId != oldWidget.selectedLeagueId ||
      selectedDate != oldWidget.selectedDate;
}
