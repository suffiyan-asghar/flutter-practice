import 'package:flutter/material.dart';
import 'package:midterm_practice/calculator_provider.dart';
import 'package:midterm_practice/calculator_screen.dart';
import 'package:midterm_practice/history_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        // The calculator needs the history provider to store results.
        ChangeNotifierProxyProvider<HistoryProvider, CalculatorProvider>(
          create: (ctx) => CalculatorProvider(ctx.read<HistoryProvider>()),
          update: (_, history, previous) =>
              previous ?? CalculatorProvider(history),
        ),
      ],
      child: MaterialApp(
        title: 'Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const CalculatorScreen(),
      ),
    );
  }
}