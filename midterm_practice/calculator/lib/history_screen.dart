import 'package:flutter/material.dart';
import 'package:midterm_practice/history_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final entries = history.entries;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear history",
            onPressed: history.isEmpty ? null : () => _confirmClear(context),
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text("No calculations yet",
                  style: TextStyle(color: Colors.white54, fontSize: 18)),
            )
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, i) {
                final e = entries[i];
                return ListTile(
                  title: Text(
                    "${e.expression} =",
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  subtitle: Text(
                    e.result,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear history?"),
        content: const Text("This will delete all saved calculations."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<HistoryProvider>().clear();
    }
  }
}