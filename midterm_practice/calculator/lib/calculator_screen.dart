import 'package:flutter/material.dart';
import 'package:midterm_practice/button_values.dart';
import 'package:midterm_practice/calculator_provider.dart';
import 'package:midterm_practice/history_screen.dart';
import 'package:provider/provider.dart';

const Color _orange = Color(0xFFFF9F0A);
const Color _lightGrey = Color(0xFFA5A5A5);
const Color _darkGrey = Color(0xFF333333);
const double _gap = 12;

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          // Keeps the phone-like proportions when run in a wide browser window.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: LayoutBuilder(
              builder: (context, c) {
                final byWidth = (c.maxWidth - _gap * 5) / 4;
                final byHeight = (c.maxHeight * 0.65 - _gap * 5) / 5;
                final size = byWidth < byHeight ? byWidth : byHeight;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _gap),
                  child: Column(
                    children: [
                      // top bar: history button
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history,
                                color: Colors.white70),
                            tooltip: "History",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HistoryScreen()),
                            ),
                          ),
                        ],
                      ),
                      // display
                      const Expanded(child: _Display()),
                      // keypad: Column of Rows
                      for (final row in Btn.rows) _buildRow(row, size),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> row, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < row.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            _CalcButton(
              label: row[i],
              width: row[i] == Btn.n0 ? size * 2 + _gap : size,
              height: size,
            ),
          ],
        ],
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display();

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // swipe left/right on the display to delete the last digit
      onHorizontalDragEnd: (_) => context.read<CalculatorProvider>().delete(),
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              calc.expressionText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 22),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                calc.displayText,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 88,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    required this.label,
    required this.width,
    required this.height,
  });

  final String label;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isOperator = Btn.operators.contains(label) || label == Btn.calculate;
    final isFunction = Btn.functions.contains(label);
    final active = context
        .select<CalculatorProvider, bool>((c) => c.isOperatorActive(label));

    Color bg = isOperator ? _orange : (isFunction ? _lightGrey : _darkGrey);
    Color fg = isFunction ? Colors.black : Colors.white;
    if (active) {
      bg = Colors.white;
      fg = _orange;
    }

    final isZero = label == Btn.n0;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onTap(context),
          child: Container(
            alignment: isZero ? Alignment.centerLeft : Alignment.center,
            padding: isZero ? EdgeInsets.only(left: height * 0.38) : null,
            child: Text(
              label,
              style: TextStyle(color: fg, fontSize: height * 0.4),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    switch (label) {
      case Btn.clr:
        calc.clear();
      case Btn.sign:
        calc.toggleSign();
      case Btn.per:
        calc.percent();
      case Btn.calculate:
        calc.calculate();
      case Btn.dot:
        calc.inputDot();
      case Btn.add || Btn.subtract || Btn.multiply || Btn.divide:
        calc.inputOperator(label);
      default:
        calc.inputDigit(label);
    }
  }
}