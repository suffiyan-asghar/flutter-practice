import 'package:flutter/foundation.dart';

class HistoryEntry {
  final String expression;
  final String result;
  final DateTime time;

  HistoryEntry(this.expression, this.result) : time = DateTime.now();
}

/// Stores, exposes and clears the calculation history.
class HistoryProvider extends ChangeNotifier {
  final List<HistoryEntry> _entries = [];

  /// Newest first.
  List<HistoryEntry> get entries => List.unmodifiable(_entries);
  bool get isEmpty => _entries.isEmpty;

  void add(String expression, String result) {
    _entries.insert(0, HistoryEntry(expression, result));
    notifyListeners();
  }

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }
}