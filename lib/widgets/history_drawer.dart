import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation_history.dart';
import '../theme/luxury_theme.dart';

class HistoryDrawer extends StatelessWidget {
  final List<HistoryItem> history;
  final void Function(String expr) onRecallExpression;
  final VoidCallback onClearHistory;

  const HistoryDrawer({
    super.key,
    required this.history,
    required this.onRecallExpression,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LuxuryTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: LuxuryTheme.emeraldPrimary, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: LuxuryTheme.borderMuted,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Icon(Icons.history, color: LuxuryTheme.emeraldPrimary, size: 24),
              const SizedBox(width: 10),
              Text(
                'Calculation Tape (${history.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LuxuryTheme.textBright,
                ),
              ),
              const Spacer(),
              if (history.isNotEmpty)
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, size: 16, color: LuxuryTheme.ochreWarm),
                  label: Text(
                    'Clear Tape',
                    style: TextStyle(color: LuxuryTheme.ochreWarm, fontSize: 13),
                  ),
                  onPressed: () {
                    onClearHistory();
                    Navigator.pop(context);
                  },
                ),
              IconButton(
                icon: Icon(Icons.close, color: LuxuryTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Body
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: LuxuryTheme.emeraldPrimary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No calculations recorded yet.',
                          style: TextStyle(
                            color: LuxuryTheme.textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => Divider(
                      color: LuxuryTheme.borderMuted,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = history[history.length - 1 - index];
                      return InkWell(
                        onTap: () {
                          onRecallExpression(item.expression);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: LuxuryTheme.goldWarm,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTime(item.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: LuxuryTheme.textSubtle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.expression,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: LuxuryTheme.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '= ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: LuxuryTheme.goldPrimary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.result,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: LuxuryTheme.emeraldBright,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 16, color: LuxuryTheme.textMuted),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: item.result));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Result copied to clipboard!'),
                                          duration: Duration(seconds: 1),
                                          backgroundColor: LuxuryTheme.surfaceCardElevated,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
