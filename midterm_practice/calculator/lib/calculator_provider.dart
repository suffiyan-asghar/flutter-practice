import 'package:flutter/foundation.dart';
import 'package:midterm_practice/button_values.dart';
import 'package:midterm_practice/history_provider.dart';

/// Holds all calculator state and logic. The UI only calls these methods.
class CalculatorProvider extends ChangeNotifier {
  CalculatorProvider(this._history);

  final HistoryProvider _history;

  String _number1 = "";
  String _operand = "";
  String _number2 = "";
  bool _resultShown = false; // true right after "=" so a new digit starts fresh

  // ---------- what the UI reads ----------

  /// The big number on screen.
  String get displayText {
    final current =
        _operand.isNotEmpty && _number2.isNotEmpty ? _number2 : _number1;
    return current.isEmpty ? "0" : current;
  }

  /// Small line above the number, e.g. "12 + 5".
  String get expressionText =>
      _operand.isEmpty ? "" : "$_number1 $_operand $_number2".trim();

  /// Highlights an operator button while it is waiting for the second number.
  bool isOperatorActive(String op) => _operand == op && _number2.isEmpty;

  // ---------- input ----------

  void inputDigit(String digit) {
    _prepare();
    if (_operand.isEmpty) {
      if (_resultShown) {
        _number1 = "";
        _resultShown = false;
      }
      _number1 = _appendDigit(_number1, digit);
    } else {
      _number2 = _appendDigit(_number2, digit);
    }
    notifyListeners();
  }

  void inputDot() {
    _prepare();
    if (_operand.isEmpty) {
      if (_resultShown) {
        _number1 = "";
        _resultShown = false;
      }
      _number1 = _appendDot(_number1);
    } else {
      _number2 = _appendDot(_number2);
    }
    notifyListeners();
  }

  void inputOperator(String op) {
    _prepare();
    if (_number1.isEmpty) _number1 = "0";
    // Chained calculation: 2 + 3 × ... evaluates 2 + 3 first.
    if (_operand.isNotEmpty && _number2.isNotEmpty) {
      _evaluate();
      if (_number1 == "Error") {
        notifyListeners();
        return;
      }
    }
    _operand = op;
    _resultShown = false;
    notifyListeners();
  }

  void calculate() {
    if (_number1.isEmpty || _operand.isEmpty || _number2.isEmpty) return;
    _evaluate();
    notifyListeners();
  }

  void percent() {
    _prepare();
    if (_operand.isNotEmpty && _number2.isNotEmpty) {
      // iOS behaviour: 200 + 10% = 220, 200 × 10% = 20
      final base = double.parse(_number1);
      final value = double.parse(_number2);
      final addSub = _operand == Btn.add || _operand == Btn.subtract;
      _number2 = _format(addSub ? base * value / 100 : value / 100);
    } else if (_operand.isEmpty && _number1.isNotEmpty) {
      _number1 = _format(double.parse(_number1) / 100);
      _resultShown = true;
    }
    notifyListeners();
  }

  void toggleSign() {
    _prepare();
    if (_operand.isNotEmpty && _number2.isNotEmpty) {
      _number2 = _flip(_number2);
    } else if (_operand.isEmpty && _number1.isNotEmpty) {
      _number1 = _flip(_number1);
    }
    notifyListeners();
  }

  /// Backspace (triggered by swiping on the display).
  void delete() {
    _prepare();
    if (_operand.isNotEmpty && _number2.isNotEmpty) {
      _number2 = _chop(_number2);
    } else if (_operand.isNotEmpty) {
      _operand = "";
    } else if (_number1.isNotEmpty && !_resultShown) {
      _number1 = _chop(_number1);
    }
    notifyListeners();
  }

  void clear() {
    _reset();
    notifyListeners();
  }

  // ---------- internals ----------

  void _reset() {
    _number1 = "";
    _operand = "";
    _number2 = "";
    _resultShown = false;
  }

  /// Any input after an error starts from scratch.
  void _prepare() {
    if (_number1 == "Error") _reset();
  }

  void _evaluate() {
    final a = double.parse(_number1);
    final b = double.parse(_number2);

    final result = switch (_operand) {
      Btn.add => a + b,
      Btn.subtract => a - b,
      Btn.multiply => a * b,
      Btn.divide => b == 0 ? double.nan : a / b,
      _ => double.nan,
    };

    final text = _format(result);
    if (text != "Error") {
      _history.add("${_format(a)} $_operand ${_format(b)}", text);
    }

    _number1 = text;
    _operand = "";
    _number2 = "";
    _resultShown = true;
  }

  String _appendDigit(String current, String digit) {
    if (current.replaceAll(RegExp(r'[-.]'), '').length >= 12) return current;
    if (current == "0") return digit;
    if (current == "-0") return "-$digit";
    return current + digit;
  }

  String _appendDot(String current) {
    if (current.contains(".")) return current;
    if (current.isEmpty) return "0.";
    return "$current.";
  }

  String _flip(String s) {
    if (s == "0") return s;
    return s.startsWith("-") ? s.substring(1) : "-$s";
  }

  String _chop(String s) {
    final r = s.substring(0, s.length - 1);
    return r == "-" ? "" : r;
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return "Error";
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    final s = v.toStringAsPrecision(10);
    if (s.contains("e")) {
      final parts = s.split("e");
      return "${_trimZeros(parts[0])}e${parts[1]}";
    }
    return _trimZeros(s);
  }

  String _trimZeros(String s) {
    if (!s.contains(".")) return s;
    return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}